[CmdletBinding()]
param(
    [ValidateSet('SessionStart', 'SubagentStart', 'UserPromptSubmit', 'PreToolUse', 'Verify')]
    [string]$HookEvent = 'Verify',

    [string]$RepositoryRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try { [Console]::OutputEncoding = New-Object Text.UTF8Encoding($false) } catch { }

function Invoke-GitText {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $output = @(& git -C $Root @Arguments 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed (git -C $Root $($Arguments -join ' ')): $($output -join [Environment]::NewLine)"
    }
    return ($output -join [Environment]::NewLine).Trim()
}

function Resolve-AerRoot {
    param($Payload)

    $candidates = New-Object 'Collections.Generic.List[string]'
    if (-not [string]::IsNullOrWhiteSpace($RepositoryRoot)) {
        $candidates.Add($RepositoryRoot)
    }

    $scriptCandidate = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
    $candidates.Add($scriptCandidate)

    if (($null -ne $Payload) -and ($Payload.PSObject.Properties.Name -contains 'cwd')) {
        if (-not [string]::IsNullOrWhiteSpace([string]$Payload.cwd)) {
            $candidates.Add([string]$Payload.cwd)
        }
    }
    $candidates.Add((Get-Location).Path)

    $diagnostics = @()
    foreach ($candidate in $candidates) {
        try {
            $fullCandidate = [IO.Path]::GetFullPath($candidate)
            $root = Invoke-GitText -Root $fullCandidate -Arguments @('rev-parse', '--show-toplevel')
            if (Test-Path -LiteralPath (Join-Path $root 'AGENTS.md') -PathType Leaf) {
                return [IO.Path]::GetFullPath($root)
            }
            $diagnostics += "${fullCandidate}: AGENTS.md not found at resolved root $root"
        }
        catch {
            $diagnostics += "${candidate}: $($_.Exception.Message)"
        }
    }

    throw "Unable to resolve the AER repository root. $($diagnostics -join ' | ')"
}

function Get-BlockValue {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $pattern = '(?ms)^' + [regex]::Escape($Label) + '\s*\r?\n\s*\r?\n([^\r\n]+)'
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return 'UNKNOWN'
}

function Get-AuthorityPaths {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$CurrentState
    )

    $paths = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($path in @(
        'AGENTS.md',
        'BOOTSTRAP.md',
        '00_GOVERNANCE/CURRENT_STATE',
        '00_GOVERNANCE/RESEARCH_HANDOFF_SPEC.md',
        '00_GOVERNANCE/RESEARCH_CLOSURE_POLICY.md',
        '07_DECISIONS/DEC004_ACCEPT_FIRST_STAGE_STABILITY_OF_MINIMAL_AER_REASONING_SKELETON.md',
        '07_DECISIONS/DEC005_ADOPT_TIERED_RUNTIME_SELECTION_AND_PRODUCTION_LAYER_TRANSFORMATION.md',
        '05_EVIDENCE/EV004_SYNTHETIC_EXECUTION_INTEGRITY_AND_STRUCTURAL_DIVERSITY_VALIDATION.md',
        '05_EVIDENCE/EV005_TIERED_RUNTIME_COMPARATIVE_VALIDATION.md',
        '08_OPEN_PROBLEMS/OP001_PM_Linkage_Criteria.md',
        '09_RESEARCH_LOG/SESSION_009_CODEX_RUNTIME_MIGRATION_PILOT.md'
    )) {
        [void]$paths.Add($path)
    }

    $referencePattern = '(?m)(?<![A-Za-z0-9_])([0-9]{2}_[A-Z_]+/[A-Za-z0-9_./-]+\.md)(?![A-Za-z0-9_.-])'
    foreach ($match in [regex]::Matches($CurrentState, $referencePattern)) {
        [void]$paths.Add($match.Groups[1].Value)
    }

    $missing = @()
    foreach ($path in $paths) {
        $fullPath = Join-Path $Root ($path.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            $missing += $path
        }
    }
    if ($missing.Count -gt 0) {
        throw "Authority reference missing: $($missing -join ', ')"
    }

    return @($paths | Sort-Object)
}

function Get-AuthorityDigest {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string[]]$Paths
    )

    $lines = foreach ($path in $Paths) {
        $fullPath = Join-Path $Root ($path.Replace('/', [IO.Path]::DirectorySeparatorChar))
        $hash = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash.ToLowerInvariant()
        "$path=$hash"
    }
    $bytes = [Text.Encoding]::UTF8.GetBytes(($lines -join "`n"))
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Get-CurrentPriority {
    param([Parameter(Mandatory = $true)][string]$CurrentState)

    foreach ($pattern in @(
        '(?m)^- Next research priority:\s*(.+?)\s*$',
        '(?m)^\d+\.\s+(.+?)\s+—\s+Next priority\s*$'
    )) {
        $match = [regex]::Match($CurrentState, $pattern)
        if ($match.Success) { return $match.Groups[1].Value.Trim() }
    }
    return 'UNKNOWN'
}

function New-Binding {
    param([Parameter(Mandatory = $true)][string]$Root)

    $currentStatePath = Join-Path $Root '00_GOVERNANCE/CURRENT_STATE'
    $currentState = Get-Content -Raw -Encoding UTF8 $currentStatePath
    $authorityPaths = Get-AuthorityPaths -Root $Root -CurrentState $currentState
    $digest = Get-AuthorityDigest -Root $Root -Paths $authorityPaths
    $head = Invoke-GitText -Root $Root -Arguments @('rev-parse', 'HEAD')
    $branch = Invoke-GitText -Root $Root -Arguments @('branch', '--show-current')
    $statusText = Invoke-GitText -Root $Root -Arguments @('status', '--porcelain=v1', '--untracked-files=all')
    $changedPaths = @($statusText -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    return [pscustomobject]@{
        Root = $Root
        Head = $head
        Branch = $branch
        DirtyCount = $changedPaths.Count
        DirtySummary = if ($changedPaths.Count -eq 0) { 'clean' } else { ($changedPaths | Select-Object -First 8) -join '; ' }
        Digest = $digest
        AuthorityCount = $authorityPaths.Count
        RepositoryVersion = Get-BlockValue -Text $currentState -Label 'Repository Version'
        ResearchVersion = Get-BlockValue -Text $currentState -Label 'Research State Version'
        CurrentPhase = Get-BlockValue -Text $currentState -Label 'Current Phase'
        CurrentStatus = Get-BlockValue -Text $currentState -Label 'Current Status'
        CurrentPriority = Get-CurrentPriority -CurrentState $currentState
    }
}

function Get-FullContext {
    param([Parameter(Mandatory = $true)]$Binding)

    return @"
AER_RUNTIME_BINDING_V1
Authority validation: PASS ($($Binding.AuthorityCount) sources; digest $($Binding.Digest.Substring(0, 16)))
Repository: $($Binding.Root)
Branch/HEAD: $($Binding.Branch) / $($Binding.Head)
Working tree: $($Binding.DirtySummary)
Versions: $($Binding.RepositoryVersion); $($Binding.ResearchVersion)
Current phase: $($Binding.CurrentPhase)
Current status: $($Binding.CurrentStatus)
Current priority: $($Binding.CurrentPriority)

Execution contract:
1. The repository is the SSOT. Conversation, memory, and re-derived conclusions are not authority.
2. Before substantive reasoning, establish an Active Reasoning State containing objective, official baseline, confirmed conclusions, assumptions/unknowns, open question, mutable scope, stop/reopen conditions, and progress pointer.
3. Classify material new input as CONTINUE, REVISE, REOPEN, or NEW_SCOPE. Never silently treat an approved conclusion as a new finding.
4. On State Departure, stop the affected conclusion, reload the authority source, record the conflict, and resume only from the corrected state.
5. Use AER Core for materially complex judgment. Add B or C only under DEC-005 triggers; do not add a Core rule for an execution defect.
6. This binding authorizes no repository change. Repository application still requires an Approved Handoff, explicit Closure Mode, approved scope, and the applicable Git permission.
"@.Trim()
}

function Get-CheckpointContext {
    param([Parameter(Mandatory = $true)]$Binding)

    return "AER_RUNTIME_CHECKPOINT_V1 digest=$($Binding.Digest.Substring(0, 16)); HEAD=$($Binding.Head); working_tree=$($Binding.DirtyCount). Classify this prompt as CONTINUE/REVISE/REOPEN/NEW_SCOPE against the Active Reasoning State. Preserve official conclusions and limitations; reload authority on conflict. This checkpoint grants no repository-write authority."
}

function Write-HookContext {
    param(
        [Parameter(Mandatory = $true)][string]$EventName,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $result = @{
        hookSpecificOutput = @{
            hookEventName = $EventName
            additionalContext = $Context
        }
    }
    Write-Output ($result | ConvertTo-Json -Depth 5 -Compress)
}

function Write-HookFailure {
    param(
        [Parameter(Mandatory = $true)][string]$EventName,
        [Parameter(Mandatory = $true)][string]$Reason
    )

    switch ($EventName) {
        'SessionStart' {
            Write-Output (@{ continue = $false; stopReason = $Reason; systemMessage = $Reason } | ConvertTo-Json -Compress)
        }
        'UserPromptSubmit' {
            Write-Output (@{ decision = 'block'; reason = $Reason } | ConvertTo-Json -Compress)
        }
        'PreToolUse' {
            $result = @{
                hookSpecificOutput = @{
                    hookEventName = 'PreToolUse'
                    permissionDecision = 'deny'
                    permissionDecisionReason = $Reason
                }
            }
            Write-Output ($result | ConvertTo-Json -Depth 5 -Compress)
        }
        'SubagentStart' {
            Write-HookContext -EventName 'SubagentStart' -Context "AER_RUNTIME_BINDING_FAILED: $Reason. Do not form or apply a repository conclusion."
        }
        default {
            [Console]::Error.WriteLine($Reason)
            exit 1
        }
    }
}

try {
    $inputText = [Console]::In.ReadToEnd()
    $payload = $null
    if (-not [string]::IsNullOrWhiteSpace($inputText)) {
        $payload = $inputText | ConvertFrom-Json
    }

    $root = Resolve-AerRoot -Payload $payload
    $binding = New-Binding -Root $root

    switch ($HookEvent) {
        'SessionStart' { Write-HookContext -EventName $HookEvent -Context (Get-FullContext -Binding $binding) }
        'SubagentStart' { Write-HookContext -EventName $HookEvent -Context (Get-FullContext -Binding $binding) }
        'UserPromptSubmit' { Write-HookContext -EventName $HookEvent -Context (Get-CheckpointContext -Binding $binding) }
        'PreToolUse' {
            $context = (Get-CheckpointContext -Binding $binding) + ' Before this edit, compare the target path and semantics with the user-authorized repository scope.'
            Write-HookContext -EventName $HookEvent -Context $context
        }
        'Verify' {
            Write-Output (Get-FullContext -Binding $binding)
            Write-Output 'AER_RUNTIME_VERIFY_PASS'
        }
    }
}
catch {
    Write-HookFailure -EventName $HookEvent -Reason ("AER Runtime binding failed: " + $_.Exception.Message)
}
