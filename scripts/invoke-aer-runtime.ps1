[CmdletBinding()]
param(
    [ValidateSet('SessionStart', 'SubagentStart', 'UserPromptSubmit', 'PreToolUse', 'Verify')]
    [string]$HookEvent = 'Verify',
    [string]$RepositoryRoot,
    [switch]$RefreshRemote,
    [switch]$TestPushPermission
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object Text.UTF8Encoding($false) } catch { }

function Invoke-GitResult {
    param([string]$Root, [string[]]$Arguments)
    $priorPrompt = $env:GIT_TERMINAL_PROMPT
    $priorErrorAction = $ErrorActionPreference
    $nativePreferenceExists = Test-Path variable:PSNativeCommandUseErrorActionPreference
    if ($nativePreferenceExists) { $priorNativePreference = $PSNativeCommandUseErrorActionPreference }
    $env:GIT_TERMINAL_PROMPT = '0'
    $ErrorActionPreference = 'Continue'
    if ($nativePreferenceExists) { $PSNativeCommandUseErrorActionPreference = $false }
    try {
        $output = @(& git -C $Root @Arguments 2>&1 | ForEach-Object { $_.ToString() })
        $exitCode = $LASTEXITCODE
    }
    finally {
        $env:GIT_TERMINAL_PROMPT = $priorPrompt
        $ErrorActionPreference = $priorErrorAction
        if ($nativePreferenceExists) { $PSNativeCommandUseErrorActionPreference = $priorNativePreference }
    }
    return [pscustomobject]@{ ExitCode = $exitCode; Output = $output; Text = ($output -join [Environment]::NewLine).Trim() }
}

function Invoke-GitText {
    param([string]$Root, [string[]]$Arguments)
    $result = Invoke-GitResult -Root $Root -Arguments $Arguments
    if ($result.ExitCode -ne 0) { throw "Git command failed (git -C $Root $($Arguments -join ' ')): $($result.Text)" }
    return $result.Text
}

function Get-LocalConfig {
    param([string]$Root, [string]$Name)
    $result = Invoke-GitResult -Root $Root -Arguments @('config', '--local', '--get', $Name)
    if ($result.ExitCode -eq 0) { return $result.Text.Trim() }
    if ($result.ExitCode -eq 1) { return $null }
    throw "Unable to read local Git configuration '$Name': $($result.Text)"
}

function Resolve-AerRoot {
    param($Payload)
    $candidates = New-Object 'Collections.Generic.List[string]'
    if (-not [string]::IsNullOrWhiteSpace($RepositoryRoot)) { $candidates.Add($RepositoryRoot) }
    $candidates.Add([IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')))
    if (($null -ne $Payload) -and ($Payload.PSObject.Properties.Name -contains 'cwd')) {
        if (-not [string]::IsNullOrWhiteSpace([string]$Payload.cwd)) { $candidates.Add([string]$Payload.cwd) }
    }
    $candidates.Add((Get-Location).Path)
    $diagnostics = @()
    foreach ($candidate in $candidates) {
        try {
            $fullCandidate = [IO.Path]::GetFullPath($candidate)
            $root = Invoke-GitText -Root $fullCandidate -Arguments @('rev-parse', '--show-toplevel')
            if (Test-Path -LiteralPath (Join-Path $root 'AGENTS.md') -PathType Leaf) { return [IO.Path]::GetFullPath($root) }
            $diagnostics += "${fullCandidate}: AGENTS.md not found at resolved root $root"
        }
        catch { $diagnostics += "${candidate}: $($_.Exception.Message)" }
    }
    throw "Unable to resolve the AER repository root. $($diagnostics -join ' | ')"
}

function Resolve-GitPath {
    param([string]$Root, [string]$Path)
    if ([IO.Path]::IsPathRooted($Path)) { return [IO.Path]::GetFullPath($Path) }
    return [IO.Path]::GetFullPath((Join-Path $Root $Path))
}

function Test-CommitExists {
    param([string]$Root, [string]$Revision)
    if ([string]::IsNullOrWhiteSpace($Revision)) { return $false }
    return (Invoke-GitResult -Root $Root -Arguments @('cat-file', '-e', "$Revision`^{commit}")).ExitCode -eq 0
}

function Test-IsAncestor {
    param([string]$Root, [string]$Ancestor, [string]$Descendant)
    $result = Invoke-GitResult -Root $Root -Arguments @('merge-base', '--is-ancestor', $Ancestor, $Descendant)
    if ($result.ExitCode -eq 0) { return $true }
    if ($result.ExitCode -eq 1) { return $false }
    throw "Unable to compare ancestry '$Ancestor' -> '$Descendant': $($result.Text)"
}

function Get-BlockValue {
    param([string]$Text, [string]$Label)
    $match = [regex]::Match($Text, ('(?ms)^' + [regex]::Escape($Label) + '\s*\r?\n\s*\r?\n([^\r\n]+)'))
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return 'UNKNOWN'
}

function Get-AuthorityPaths {
    param([string]$Root, [string]$CurrentState)
    $paths = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($path in @(
        'AGENTS.md', 'BOOTSTRAP.md', '00_GOVERNANCE/CURRENT_STATE',
        '00_GOVERNANCE/RESEARCH_HANDOFF_SPEC.md', '00_GOVERNANCE/RESEARCH_CLOSURE_POLICY.md',
        '07_DECISIONS/DEC004_ACCEPT_FIRST_STAGE_STABILITY_OF_MINIMAL_AER_REASONING_SKELETON.md',
        '07_DECISIONS/DEC005_ADOPT_TIERED_RUNTIME_SELECTION_AND_PRODUCTION_LAYER_TRANSFORMATION.md',
        '05_EVIDENCE/EV004_SYNTHETIC_EXECUTION_INTEGRITY_AND_STRUCTURAL_DIVERSITY_VALIDATION.md',
        '05_EVIDENCE/EV005_TIERED_RUNTIME_COMPARATIVE_VALIDATION.md',
        '08_OPEN_PROBLEMS/OP001_PM_Linkage_Criteria.md',
        '09_RESEARCH_LOG/SESSION_009_CODEX_RUNTIME_MIGRATION_PILOT.md'
    )) { [void]$paths.Add($path) }
    $referencePattern = '(?m)(?<![A-Za-z0-9_])([0-9]{2}_[A-Z_]+/[A-Za-z0-9_./-]+\.md)(?![A-Za-z0-9_.-])'
    foreach ($match in [regex]::Matches($CurrentState, $referencePattern)) { [void]$paths.Add($match.Groups[1].Value) }
    $missing = @()
    foreach ($path in $paths) {
        $fullPath = Join-Path $Root ($path.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { $missing += $path }
    }
    if ($missing.Count -gt 0) { throw "Authority reference missing: $($missing -join ', ')" }
    return @($paths | Sort-Object)
}

function Get-AuthorityDigest {
    param([string]$Root, [string[]]$Paths)
    $lines = foreach ($path in $Paths) {
        $fullPath = Join-Path $Root ($path.Replace('/', [IO.Path]::DirectorySeparatorChar))
        "$path=$((Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash.ToLowerInvariant())"
    }
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [Text.Encoding]::UTF8.GetBytes(($lines -join "`n"))
        return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally { $sha.Dispose() }
}

function Get-CurrentPriority {
    param([string]$CurrentState)
    foreach ($pattern in @('(?m)^- Next research priority:\s*(.+?)\s*$', '(?m)^\d+\.\s+(.+?)\s+—\s+Next priority\s*$')) {
        $match = [regex]::Match($CurrentState, $pattern)
        if ($match.Success) { return $match.Groups[1].Value.Trim() }
    }
    return 'UNKNOWN'
}

function Get-RemoteHead {
    param([string]$Root, [string]$Remote, [string]$Branch, [bool]$QueryActual)
    if ($QueryActual) {
        $result = Invoke-GitResult -Root $Root -Arguments @('ls-remote', '--heads', $Remote, "refs/heads/$Branch")
        if ($result.ExitCode -ne 0) { return [pscustomobject]@{ Sha = $null; Source = 'ACTUAL_REMOTE_UNVERIFIED'; Detail = $result.Text } }
        $line = @($result.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
        if ($line.Count -eq 0) { return [pscustomobject]@{ Sha = $null; Source = 'ACTUAL_REMOTE_MISSING'; Detail = 'branch not found' } }
        return [pscustomobject]@{ Sha = ($line[0] -split '\s+')[0]; Source = 'ACTUAL_REMOTE'; Detail = 'ls-remote' }
    }
    $tracking = Invoke-GitResult -Root $Root -Arguments @('rev-parse', '--verify', "refs/remotes/$Remote/$Branch`^{commit}")
    if ($tracking.ExitCode -eq 0) { return [pscustomobject]@{ Sha = $tracking.Text.Trim(); Source = 'LOCAL_TRACKING_REF'; Detail = 'actual remote not queried' } }
    return [pscustomobject]@{ Sha = $null; Source = 'NOT_CHECKED'; Detail = 'use -RefreshRemote for actual remote' }
}

function Get-AclBoundary {
    param([string]$GitDirectory)
    if ($env:OS -ne 'Windows_NT') { return [pscustomobject]@{ Owner = 'NOT_WINDOWS'; BroadDenyCount = 0; DenyIdentities = @(); Status = 'NOT_APPLICABLE' } }
    try {
        $acl = Get-Acl -LiteralPath $GitDirectory
        $broad = @($acl.Access | Where-Object {
            ($_.AccessControlType.ToString() -eq 'Deny') -and
            (($_.InheritanceFlags.ToString() -ne 'None') -or (($_.FileSystemRights.ToString()) -match 'Write|Modify|FullControl|Delete'))
        })
        $identities = @($broad | ForEach-Object { $_.IdentityReference.Value } | Sort-Object -Unique)
        $status = if ($broad.Count -eq 0) { 'NO_BROAD_DENY_DETECTED' } else { 'BROAD_DENY_DETECTED' }
        return [pscustomobject]@{ Owner = $acl.Owner; BroadDenyCount = $broad.Count; DenyIdentities = $identities; Status = $status }
    }
    catch { return [pscustomobject]@{ Owner = 'UNVERIFIED'; BroadDenyCount = -1; DenyIdentities = @(); Status = "ACL_UNVERIFIED: $($_.Exception.Message)" } }
}

function New-Binding {
    param([string]$Root)
    $currentState = Get-Content -Raw -Encoding UTF8 (Join-Path $Root '00_GOVERNANCE/CURRENT_STATE')
    $authorityPaths = Get-AuthorityPaths -Root $Root -CurrentState $currentState
    $digest = Get-AuthorityDigest -Root $Root -Paths $authorityPaths
    $head = Invoke-GitText -Root $Root -Arguments @('rev-parse', 'HEAD')
    $branch = Invoke-GitText -Root $Root -Arguments @('branch', '--show-current')
    $statusText = Invoke-GitText -Root $Root -Arguments @('status', '--porcelain=v1', '--untracked-files=all')
    $changedPaths = @($statusText -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    $roleValue = Get-LocalConfig -Root $Root -Name 'aer.repositoryRole'
    $role = if ([string]::IsNullOrWhiteSpace($roleValue)) { 'UNDECLARED' } else { $roleValue.ToUpperInvariant() }
    $remote = Get-LocalConfig -Root $Root -Name 'aer.canonicalRemote'
    if ([string]::IsNullOrWhiteSpace($remote)) { $remote = 'origin' }
    $canonicalBranch = Get-LocalConfig -Root $Root -Name 'aer.canonicalBranch'
    if ([string]::IsNullOrWhiteSpace($canonicalBranch)) { $canonicalBranch = 'main' }

    $gitDir = Resolve-GitPath -Root $Root -Path (Invoke-GitText -Root $Root -Arguments @('rev-parse', '--git-dir'))
    $commonDir = Resolve-GitPath -Root $Root -Path (Invoke-GitText -Root $Root -Arguments @('rev-parse', '--git-common-dir'))
    $expectedGitDir = [IO.Path]::GetFullPath((Join-Path $Root '.git'))
    $objectIssues = New-Object 'Collections.Generic.List[string]'
    if ($gitDir -ne $expectedGitDir) { $objectIssues.Add('EXTERNAL_GIT_DIR_OR_LINKED_WORKTREE') }
    if ($commonDir -ne $gitDir) { $objectIssues.Add('SHARED_COMMON_DIR_OR_LINKED_WORKTREE') }
    if (Test-Path -LiteralPath (Join-Path $gitDir 'objects/info/alternates') -PathType Leaf) { $objectIssues.Add('ALTERNATES_FILE_PRESENT') }
    if (-not [string]::IsNullOrWhiteSpace($env:GIT_ALTERNATE_OBJECT_DIRECTORIES)) { $objectIssues.Add('GIT_ALTERNATE_OBJECT_DIRECTORIES_SET') }
    if (-not [string]::IsNullOrWhiteSpace($env:GIT_OBJECT_DIRECTORY)) { $objectIssues.Add('GIT_OBJECT_DIRECTORY_SET') }
    if (Test-Path -LiteralPath (Join-Path $gitDir 'shallow') -PathType Leaf) { $objectIssues.Add('SHALLOW_REPOSITORY') }
    $promisor = Invoke-GitResult -Root $Root -Arguments @('config', '--local', '--get-regexp', '^remote\..*\.promisor$')
    if (($promisor.ExitCode -eq 0) -or (-not [string]::IsNullOrWhiteSpace((Get-LocalConfig -Root $Root -Name 'extensions.partialClone')))) { $objectIssues.Add('PARTIAL_OR_PROMISOR_REPOSITORY') }
    $objectDbStatus = if ($objectIssues.Count -eq 0) { 'FULL_INDEPENDENT' } else { 'HOLD: ' + ($objectIssues -join ', ') }

    $remoteHead = Get-RemoteHead -Root $Root -Remote $remote -Branch $canonicalBranch -QueryActual $RefreshRemote.IsPresent
    $baseline = if ($role -eq 'EXECUTION') { Get-LocalConfig -Root $Root -Name 'aer.canonicalBaseline' } else { $remoteHead.Sha }
    $aheadBehind = 'UNAVAILABLE'
    if (($null -ne $remoteHead.Sha) -and (Test-CommitExists -Root $Root -Revision $remoteHead.Sha)) {
        $counts = (Invoke-GitText -Root $Root -Arguments @('rev-list', '--left-right', '--count', "$head...$($remoteHead.Sha)")) -split '\s+'
        if ($counts.Count -ge 2) { $aheadBehind = "ahead=$($counts[0]); behind=$($counts[1])" }
    }

    $holds = New-Object 'Collections.Generic.List[string]'
    $promotionHolds = New-Object 'Collections.Generic.List[string]'
    if (@('CANONICAL_OWNER', 'EXECUTION') -notcontains $role) { $holds.Add('REPOSITORY_ROLE_UNDECLARED_OR_INVALID') }
    foreach ($issue in $objectIssues) { $holds.Add($issue) }
    $pushPolicy = Get-LocalConfig -Root $Root -Name 'aer.pushPolicy'
    $pushUrlsResult = Invoke-GitResult -Root $Root -Arguments @('remote', 'get-url', '--push', '--all', $remote)
    $pushUrls = if ($pushUrlsResult.ExitCode -eq 0) { @($pushUrlsResult.Output) } else { @() }
    $pushBoundary = 'UNVERIFIED'
    $baselineStatus = 'UNVERIFIED'

    if ($role -eq 'EXECUTION') {
        if ($branch -eq $canonicalBranch) { $holds.Add('EXECUTION_ON_CANONICAL_BRANCH') }
        if ([string]::IsNullOrWhiteSpace($baseline) -or (-not (Test-CommitExists -Root $Root -Revision $baseline))) { $holds.Add('EXECUTION_CANONICAL_BASELINE_MISSING_OR_UNKNOWN') }
        if (($pushPolicy -ne 'DENY') -or (@($pushUrls).Count -eq 0) -or (@($pushUrls | Where-Object { $_ -notlike 'disabled://*' }).Count -gt 0)) {
            $holds.Add('EXECUTION_CANONICAL_PUSH_BOUNDARY_NOT_DENIED')
        }
        else { $pushBoundary = 'DENIED_BY_LOCAL_CONFIG_AND_PUSH_URL' }

        if (($null -eq $remoteHead.Sha) -or (-not (Test-CommitExists -Root $Root -Revision $remoteHead.Sha))) {
            $baselineStatus = 'REMOTE_UNVERIFIED'
            $promotionHolds.Add('ACTUAL_REMOTE_BASE_UNVERIFIED')
        }
        elseif ($baseline -eq $remoteHead.Sha) { $baselineStatus = 'CURRENT' }
        elseif (Test-IsAncestor -Root $Root -Ancestor $baseline -Descendant $remoteHead.Sha) {
            $baselineStatus = 'STALE_EXECUTION_BASELINE'
            $holds.Add('STALE_EXECUTION_BASELINE')
        }
        elseif (Test-IsAncestor -Root $Root -Ancestor $remoteHead.Sha -Descendant $baseline) {
            $allowPending = Get-LocalConfig -Root $Root -Name 'aer.allowPendingPredecessor'
            $predecessor = Get-LocalConfig -Root $Root -Name 'aer.predecessorCandidate'
            if (($allowPending -eq 'true') -and ($predecessor -eq $baseline)) {
                $baselineStatus = 'PENDING_PREDECESSOR_VERIFIED'
                $promotionHolds.Add('PROMOTE_PREDECESSOR_FIRST')
            }
            else {
                $baselineStatus = 'BASELINE_AHEAD_OF_REMOTE'
                $holds.Add('UNAPPROVED_BASELINE_AHEAD_OF_REMOTE')
            }
        }
        else {
            $baselineStatus = 'DIVERGENT'
            $holds.Add('EXECUTION_BASELINE_DIVERGENT')
        }
    }
    elseif ($role -eq 'CANONICAL_OWNER') {
        if ($branch -ne $canonicalBranch) { $holds.Add('CANONICAL_OWNER_NOT_ON_CANONICAL_BRANCH') }
        if ($changedPaths.Count -gt 0) { $holds.Add('CANONICAL_OWNER_WORKTREE_DIRTY') }
        if ($pushPolicy -ne 'OWNER_ONLY') { $holds.Add('CANONICAL_PUSH_POLICY_NOT_OWNER_ONLY') }
        if ($TestPushPermission.IsPresent) {
            $pushTest = Invoke-GitResult -Root $Root -Arguments @('push', '--dry-run', '--porcelain', $remote, "refs/heads/$canonicalBranch`:refs/heads/$canonicalBranch")
            if ($pushTest.ExitCode -eq 0) { $pushBoundary = 'OWNER_DRY_RUN_PASS_AT_CURRENT_HEAD' }
            else { $pushBoundary = 'OWNER_DRY_RUN_FAILED: ' + $pushTest.Text; $promotionHolds.Add('CANONICAL_PUSH_PERMISSION_NOT_VERIFIED') }
        }
        else { $pushBoundary = 'OWNER_CONTROLLED_NOT_TESTED' }

        if ($null -eq $remoteHead.Sha) { $baselineStatus = 'REMOTE_UNVERIFIED'; $promotionHolds.Add('ACTUAL_REMOTE_BASE_UNVERIFIED') }
        elseif ($head -eq $remoteHead.Sha) { $baselineStatus = 'CURRENT' }
        elseif ((Test-CommitExists -Root $Root -Revision $remoteHead.Sha) -and (Test-IsAncestor -Root $Root -Ancestor $head -Descendant $remoteHead.Sha)) {
            $baselineStatus = 'STALE_CANONICAL'; $holds.Add('STALE_CANONICAL_REPOSITORY')
        }
        elseif ((Test-CommitExists -Root $Root -Revision $remoteHead.Sha) -and (Test-IsAncestor -Root $Root -Ancestor $remoteHead.Sha -Descendant $head)) {
            $baselineStatus = 'LOCAL_AHEAD'; $holds.Add('CANONICAL_LOCAL_AHEAD_OUTSIDE_PROMOTION_RUNNER')
        }
        else { $baselineStatus = 'DIVERGENT_OR_REMOTE_OBJECT_UNAVAILABLE'; $holds.Add('CANONICAL_AUTHORITY_DIVERGENT') }
    }

    $aclBoundary = Get-AclBoundary -GitDirectory $gitDir
    if (($role -eq 'CANONICAL_OWNER') -and ($aclBoundary.BroadDenyCount -gt 0)) { $holds.Add('BROAD_GIT_DENY_PRESENT') }

    return [pscustomobject]@{
        Root = $Root; Role = $role; Head = $head; Branch = $branch; CanonicalRemote = $remote; CanonicalBranch = $canonicalBranch
        RemoteHead = if ($null -eq $remoteHead.Sha) { 'UNVERIFIED' } else { $remoteHead.Sha }
        RemoteHeadSource = $remoteHead.Source; RemoteDetail = $remoteHead.Detail; AheadBehind = $aheadBehind
        CanonicalBaseline = if ([string]::IsNullOrWhiteSpace($baseline)) { 'UNDECLARED' } else { $baseline }
        BaselineStatus = $baselineStatus
        CandidateBranch = if ($role -eq 'EXECUTION') { $branch } else { 'NOT_APPLICABLE' }
        CandidateCommit = if ($role -eq 'EXECUTION') { $head } else { 'NOT_APPLICABLE' }
        CandidateState = if ($role -ne 'EXECUTION') { 'NOT_APPLICABLE' } elseif ($changedPaths.Count -eq 0) { 'EXACT_HEAD_FROZEN' } else { 'WORKING_DELTA_NOT_FROZEN' }
        DirtyCount = $changedPaths.Count
        DirtySummary = if ($changedPaths.Count -eq 0) { 'clean' } else { ($changedPaths | Select-Object -First 8) -join '; ' }
        GitDirectory = $gitDir; CommonDirectory = $commonDir; ObjectDatabase = $objectDbStatus; PushBoundary = $pushBoundary
        AclOwner = $aclBoundary.Owner; AclStatus = $aclBoundary.Status
        AclDenyIdentities = if (@($aclBoundary.DenyIdentities).Count -eq 0) { 'none' } else { @($aclBoundary.DenyIdentities) -join ', ' }
        BoundaryStatus = if ($holds.Count -eq 0) { 'PASS' } else { 'HOLD' }; HoldReasons = @($holds)
        PromotionStatus = if (($holds.Count -eq 0) -and ($promotionHolds.Count -eq 0)) { 'READY_FOR_ROLE' } else { 'HOLD' }
        PromotionHoldReasons = @($promotionHolds); Digest = $digest; AuthorityCount = $authorityPaths.Count
        RepositoryVersion = Get-BlockValue -Text $currentState -Label 'Repository Version'
        ResearchVersion = Get-BlockValue -Text $currentState -Label 'Research State Version'
        CurrentPhase = Get-BlockValue -Text $currentState -Label 'Current Phase'
        CurrentStatus = Get-BlockValue -Text $currentState -Label 'Current Status'
        CurrentPriority = Get-CurrentPriority -CurrentState $currentState
    }
}

function Get-FullContext {
    param($Binding)
    $holdText = if ($Binding.HoldReasons.Count -eq 0) { 'none' } else { $Binding.HoldReasons -join ', ' }
    $promotionHoldText = if ($Binding.PromotionHoldReasons.Count -eq 0) { 'none' } else { $Binding.PromotionHoldReasons -join ', ' }
    return @"
AER_RUNTIME_BINDING_V2
Authority validation: PASS ($($Binding.AuthorityCount) sources; digest $($Binding.Digest.Substring(0, 16)))
Repository: $($Binding.Root)
REPOSITORY_ROLE = $($Binding.Role)
Repository boundary: $($Binding.BoundaryStatus); HOLD reasons: $holdText
Branch/HEAD: $($Binding.Branch) / $($Binding.Head)
origin/main: $($Binding.RemoteHead) [$($Binding.RemoteHeadSource)]
Ahead/behind: $($Binding.AheadBehind)
Canonical baseline: $($Binding.CanonicalBaseline) [$($Binding.BaselineStatus)]
Candidate branch/Commit: $($Binding.CandidateBranch) / $($Binding.CandidateCommit) [$($Binding.CandidateState)]
Object database: $($Binding.ObjectDatabase)
Push permission boundary: $($Binding.PushBoundary)
Git metadata ACL: owner=$($Binding.AclOwner); $($Binding.AclStatus); deny identities=$($Binding.AclDenyIdentities)
Promotion readiness: $($Binding.PromotionStatus); HOLD reasons: $promotionHoldText
Working tree: $($Binding.DirtySummary)
Versions: $($Binding.RepositoryVersion); $($Binding.ResearchVersion)
Current phase: $($Binding.CurrentPhase)
Current status: $($Binding.CurrentStatus)
Current priority: $($Binding.CurrentPriority)

Execution contract:
1. The repository is the SSOT for validated assets; origin/main is the remote canonical authority.
2. EXECUTION may create and validate an exact candidate Commit but has no canonical Push authority.
3. CANONICAL_OWNER is read-only to Agent/Codex and is used only by the owner promotion procedure.
4. The exact candidate Commit SHA is both validation unit and promotion unit; do not recreate it.
5. Stale, divergent, shared-object, undeclared-role, or dirty-canonical state is HOLD.
6. This binding grants no semantic approval and no authority outside the approved Handoff scope.
"@.Trim()
}

function Get-CheckpointContext {
    param($Binding)
    return "AER_RUNTIME_CHECKPOINT_V2 role=$($Binding.Role); boundary=$($Binding.BoundaryStatus); HEAD=$($Binding.Head); origin_main=$($Binding.RemoteHead); baseline=$($Binding.CanonicalBaseline); working_tree=$($Binding.DirtyCount). Classify CONTINUE/REVISE/REOPEN/NEW_SCOPE. This checkpoint grants no repository-write or canonical-promotion authority."
}

function Write-HookContext {
    param([string]$EventName, [string]$Context)
    Write-Output (@{ hookSpecificOutput = @{ hookEventName = $EventName; additionalContext = $Context } } | ConvertTo-Json -Depth 5 -Compress)
}

function Write-HookFailure {
    param([string]$EventName, [string]$Reason)
    switch ($EventName) {
        'SessionStart' { Write-Output (@{ continue = $false; stopReason = $Reason; systemMessage = $Reason } | ConvertTo-Json -Compress) }
        'UserPromptSubmit' { Write-Output (@{ decision = 'block'; reason = $Reason } | ConvertTo-Json -Compress) }
        'PreToolUse' { Write-Output (@{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $Reason } } | ConvertTo-Json -Depth 5 -Compress) }
        'SubagentStart' { Write-HookContext -EventName 'SubagentStart' -Context "AER_RUNTIME_BINDING_FAILED: $Reason. Do not form or apply a repository conclusion." }
        default { [Console]::Error.WriteLine($Reason) }
    }
}

try {
    $inputText = [Console]::In.ReadToEnd()
    $payload = $null
    if (-not [string]::IsNullOrWhiteSpace($inputText)) { $payload = $inputText | ConvertFrom-Json }
    $root = Resolve-AerRoot -Payload $payload
    $binding = New-Binding -Root $root
    if ($HookEvent -eq 'PreToolUse') {
        if ($binding.Role -eq 'CANONICAL_OWNER') {
            Write-HookFailure -EventName $HookEvent -Reason 'STOP: Agent/Codex may not edit the CANONICAL_OWNER repository. Use an independent EXECUTION clone.'
            exit 0
        }
        if ($binding.BoundaryStatus -ne 'PASS') {
            Write-HookFailure -EventName $HookEvent -Reason ("HOLD: repository boundary failed: " + ($binding.HoldReasons -join ', '))
            exit 0
        }
    }
    switch ($HookEvent) {
        'SessionStart' { Write-HookContext -EventName $HookEvent -Context (Get-FullContext -Binding $binding) }
        'SubagentStart' { Write-HookContext -EventName $HookEvent -Context (Get-FullContext -Binding $binding) }
        'UserPromptSubmit' { Write-HookContext -EventName $HookEvent -Context (Get-CheckpointContext -Binding $binding) }
        'PreToolUse' { Write-HookContext -EventName $HookEvent -Context ((Get-CheckpointContext -Binding $binding) + ' Compare the edit with the approved candidate scope.') }
        'Verify' {
            Write-Output (Get-FullContext -Binding $binding)
            if ($binding.BoundaryStatus -eq 'PASS') { Write-Output 'AER_RUNTIME_VERIFY_PASS'; exit 0 }
            Write-Output 'AER_RUNTIME_VERIFY_HOLD'
            exit 2
        }
    }
}
catch {
    Write-HookFailure -EventName $HookEvent -Reason ("AER Runtime binding failed: " + $_.Exception.Message + " | " + $_.ScriptStackTrace)
    exit 1
}
