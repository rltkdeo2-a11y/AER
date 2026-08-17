[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Preflight', 'Promote', 'PostVerify')]
    [string]$Phase,

    [string]$CandidateSource,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string]$CandidateCommit,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string]$ExpectedBaseCommit,

    [string]$ExpectedTitle,

    [string[]]$ExpectedFiles,

    [string]$ValidationManifest,

    [string]$Branch = 'main',

    [string]$Remote = 'origin',

    [switch]$AllowFastForwardAncestry,

    [switch]$Push
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object Text.UTF8Encoding($false) } catch { }

function Write-Step([string]$Message) { Write-Host "[AER Promotion] $Message" }

function Invoke-GitResult {
    param([string[]]$Arguments)
    $priorPrompt = $env:GIT_TERMINAL_PROMPT
    $priorErrorAction = $ErrorActionPreference
    $nativePreferenceExists = Test-Path variable:PSNativeCommandUseErrorActionPreference
    if ($nativePreferenceExists) { $priorNativePreference = $PSNativeCommandUseErrorActionPreference }
    $env:GIT_TERMINAL_PROMPT = '0'
    $ErrorActionPreference = 'Continue'
    if ($nativePreferenceExists) { $PSNativeCommandUseErrorActionPreference = $false }
    try {
        $output = @(& git @Arguments 2>&1 | ForEach-Object { $_.ToString() })
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
    param([string[]]$Arguments)
    $result = Invoke-GitResult -Arguments $Arguments
    if ($result.ExitCode -ne 0) { throw "Git command failed (git $($Arguments -join ' ')): $($result.Text)" }
    return $result.Text
}

function Get-LocalConfig([string]$Name) {
    $result = Invoke-GitResult -Arguments @('config', '--local', '--get', $Name)
    if ($result.ExitCode -eq 0) { return $result.Text.Trim() }
    if ($result.ExitCode -eq 1) { return $null }
    throw "Unable to read local Git configuration '$Name': $($result.Text)"
}

function Resolve-Commit([string]$Revision) {
    $result = Invoke-GitResult -Arguments @('rev-parse', '--verify', "$Revision`^{commit}")
    if ($result.ExitCode -ne 0) { throw "Commit cannot be resolved: $Revision. $($result.Text)" }
    return $result.Text.Trim()
}

function Get-ActualRemoteHead {
    $result = Invoke-GitResult -Arguments @('ls-remote', '--heads', $Remote, "refs/heads/$Branch")
    if ($result.ExitCode -ne 0) { throw "Actual $Remote/$Branch cannot be verified: $($result.Text)" }
    $line = @($result.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
    if ($line.Count -eq 0) { throw "Actual $Remote/$Branch does not exist." }
    return (($line[0] -split '\s+')[0]).ToLowerInvariant()
}

function Assert-CleanCanonical {
    $status = Invoke-GitText -Arguments @('status', '--porcelain=v1', '--untracked-files=all')
    if (-not [string]::IsNullOrWhiteSpace($status)) { throw "Canonical working tree is not clean: $status" }
    $branchNow = Invoke-GitText -Arguments @('branch', '--show-current')
    if ($branchNow -ne $Branch) { throw "Canonical branch '$branchNow' does not match '$Branch'." }
}

function Assert-CanonicalBoundary {
    $root = [IO.Path]::GetFullPath((Invoke-GitText -Arguments @('rev-parse', '--show-toplevel')))
    $gitDirRaw = Invoke-GitText -Arguments @('rev-parse', '--git-dir')
    $gitDir = if ([IO.Path]::IsPathRooted($gitDirRaw)) { [IO.Path]::GetFullPath($gitDirRaw) } else { [IO.Path]::GetFullPath((Join-Path $root $gitDirRaw)) }
    $commonRaw = Invoke-GitText -Arguments @('rev-parse', '--git-common-dir')
    $commonDir = if ([IO.Path]::IsPathRooted($commonRaw)) { [IO.Path]::GetFullPath($commonRaw) } else { [IO.Path]::GetFullPath((Join-Path $root $commonRaw)) }
    if ((Get-LocalConfig -Name 'aer.repositoryRole') -ne 'CANONICAL_OWNER') { throw 'Promotion requires REPOSITORY_ROLE=CANONICAL_OWNER.' }
    if ((Get-LocalConfig -Name 'aer.pushPolicy') -ne 'OWNER_ONLY') { throw 'Promotion requires aer.pushPolicy=OWNER_ONLY.' }
    if (($gitDir -ne [IO.Path]::GetFullPath((Join-Path $root '.git'))) -or ($commonDir -ne $gitDir)) {
        throw 'Canonical promotion requires its own in-tree Git directory; linked worktree or external GIT_DIR detected.'
    }
    if (Test-Path -LiteralPath (Join-Path $gitDir 'objects/info/alternates') -PathType Leaf) { throw 'Canonical repository uses object alternates.' }
    if ($env:OS -eq 'Windows_NT') {
        $acl = Get-Acl -LiteralPath $gitDir
        $broadDeny = @($acl.Access | Where-Object {
            ($_.AccessControlType.ToString() -eq 'Deny') -and
            (($_.InheritanceFlags.ToString() -ne 'None') -or (($_.FileSystemRights.ToString()) -match 'Write|Modify|FullControl|Delete'))
        })
        if ($broadDeny.Count -gt 0) { throw 'Broad recursive Deny ACE remains on canonical .git. Complete targeted owner ACL repair first.' }
    }
    Assert-CleanCanonical
}

function Get-NormalizedFiles([string]$Base, [string]$Candidate) {
    $text = Invoke-GitText -Arguments @('diff', '--name-only', "$Base..$Candidate", '--')
    if ([string]::IsNullOrWhiteSpace($text)) { return @() }
    return @($text -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Replace('\', '/').Trim() })
}

function Assert-ExactFileSet([string[]]$Actual, [string[]]$Expected) {
    if (($null -eq $Expected) -or ($Expected.Count -eq 0)) { throw 'ExpectedFiles is required for promotion.' }
    $actualSet = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
    $expectedSet = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
    foreach ($path in $Actual) { [void]$actualSet.Add($path.Replace('\', '/').Trim()) }
    foreach ($path in $Expected) { [void]$expectedSet.Add($path.Replace('\', '/').Trim()) }
    $unexpected = @($actualSet | Where-Object { -not $expectedSet.Contains($_) })
    $missing = @($expectedSet | Where-Object { -not $actualSet.Contains($_) })
    if (($unexpected.Count -gt 0) -or ($missing.Count -gt 0)) {
        throw "Changed-file set mismatch. Unexpected: $($unexpected -join ', '); Missing: $($missing -join ', ')"
    }
}

function Assert-Manifest([string[]]$ActualFiles) {
    if ([string]::IsNullOrWhiteSpace($ValidationManifest)) { throw 'ValidationManifest is required for promotion.' }
    $manifestPath = [IO.Path]::GetFullPath($ValidationManifest)
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "Validation manifest not found: $manifestPath" }
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($manifest.schemaVersion -ne 1) { throw 'Validation manifest schemaVersion must be 1.' }
    if ([string]$manifest.candidateCommit -ne $CandidateCommit) { throw 'Validation manifest candidateCommit mismatch.' }
    if ([string]$manifest.expectedBaseCommit -ne $ExpectedBaseCommit) { throw 'Validation manifest expectedBaseCommit mismatch.' }
    if ([string]$manifest.commitTitle -ne $ExpectedTitle) { throw 'Validation manifest commitTitle mismatch.' }
    Assert-ExactFileSet -Actual $ActualFiles -Expected @($manifest.changedFiles)
    $allowedPolicy = @('PASS', 'PASS_WITH_WARNINGS')
    if ($allowedPolicy -notcontains [string]$manifest.policy) { throw 'Validation manifest policy must be PASS or PASS_WITH_WARNINGS.' }
    $requiredResults = @('sourceVerify', 'gitDiffCheck', 'repositoryValidation', 'runtimeVerify', 'authorityValidation', 'gitFsck')
    $warnFound = $false
    foreach ($name in $requiredResults) {
        if (-not ($manifest.results.PSObject.Properties.Name -contains $name)) { throw "Validation result missing: $name" }
        $value = [string]$manifest.results.$name
        if ($value -eq 'WARN_ONLY') { $warnFound = $true; continue }
        if ($value -ne 'PASS') { throw "Validation result is not PASS/WARN_ONLY: $name=$value" }
    }
    if ($warnFound -and ([string]$manifest.policy -ne 'PASS_WITH_WARNINGS')) { throw 'WARN_ONLY result requires PASS_WITH_WARNINGS policy.' }
}

function Import-And-VerifyCandidate {
    if ([string]::IsNullOrWhiteSpace($CandidateSource)) { throw 'CandidateSource is required for Preflight or Promote.' }
    if (-not [IO.Path]::IsPathRooted($CandidateSource) -and ($CandidateSource -notmatch '^[A-Za-z][A-Za-z0-9+.-]*://')) {
        $script:ResolvedSource = [IO.Path]::GetFullPath($CandidateSource)
    }
    else { $script:ResolvedSource = $CandidateSource }

    if ($script:ResolvedSource -match '(?i)\.bundle$') {
        $bundle = Invoke-GitResult -Arguments @('bundle', 'verify', $script:ResolvedSource)
        if ($bundle.ExitCode -ne 0) { throw "Bundle verification failed: $($bundle.Text)" }
    }

    $candidateRef = "refs/aer/candidates/$($CandidateCommit.ToLowerInvariant())"
    $fetch = Invoke-GitResult -Arguments @('fetch', '--no-tags', $script:ResolvedSource, "$CandidateCommit`:$candidateRef")
    if ($fetch.ExitCode -ne 0) { throw "Candidate import failed: $($fetch.Text)" }
    $resolved = Resolve-Commit -Revision $candidateRef
    if ($resolved -ne $CandidateCommit.ToLowerInvariant()) { throw "Imported candidate SHA mismatch: $resolved" }

    $parents = (Invoke-GitText -Arguments @('show', '-s', '--format=%P', $resolved)).Trim()
    if ($AllowFastForwardAncestry.IsPresent) {
        $ancestry = Invoke-GitResult -Arguments @('merge-base', '--is-ancestor', $ExpectedBaseCommit, $resolved)
        if ($ancestry.ExitCode -ne 0) { throw 'Candidate is not a fast-forward descendant of ExpectedBaseCommit.' }
    }
    elseif ($parents -ne $ExpectedBaseCommit.ToLowerInvariant()) {
        throw "Candidate parent '$parents' does not equal expected base '$ExpectedBaseCommit'."
    }

    $title = Invoke-GitText -Arguments @('show', '-s', '--format=%s', $resolved)
    if ($title -ne $ExpectedTitle) { throw "Candidate title '$title' does not equal expected title '$ExpectedTitle'." }
    $actualFiles = @(Get-NormalizedFiles -Base $ExpectedBaseCommit -Candidate $resolved)
    Assert-ExactFileSet -Actual $actualFiles -Expected $ExpectedFiles
    Assert-Manifest -ActualFiles $actualFiles
    Invoke-GitText -Arguments @('diff', '--check', "$ExpectedBaseCommit..$resolved", '--') | Out-Null
    Invoke-GitText -Arguments @('fsck', '--full') | Out-Null
    return [pscustomobject]@{ Ref = $candidateRef; Sha = $resolved; Files = $actualFiles; Title = $title }
}

function Assert-BaseAuthority {
    $localHead = Resolve-Commit -Revision 'HEAD'
    if ($localHead -ne $ExpectedBaseCommit.ToLowerInvariant()) { throw "Local canonical HEAD '$localHead' does not match expected base '$ExpectedBaseCommit'." }
    $remoteHead = Get-ActualRemoteHead
    if ($remoteHead -ne $ExpectedBaseCommit.ToLowerInvariant()) { throw "Actual $Remote/$Branch '$remoteHead' does not match expected base '$ExpectedBaseCommit'." }
    return $remoteHead
}

function Invoke-PostVerify {
    Assert-CleanCanonical
    $localHead = Resolve-Commit -Revision 'HEAD'
    $remoteHead = Get-ActualRemoteHead
    if (($localHead -ne $CandidateCommit.ToLowerInvariant()) -or ($remoteHead -ne $CandidateCommit.ToLowerInvariant())) {
        throw "Postcondition failed: local=$localHead remote=$remoteHead target=$CandidateCommit"
    }
    $counts = (Invoke-GitText -Arguments @('rev-list', '--left-right', '--count', "$localHead...$remoteHead")) -split '\s+'
    if (($counts.Count -lt 2) -or ($counts[0] -ne '0') -or ($counts[1] -ne '0')) { throw "Postcondition ahead/behind is not 0/0: $($counts -join '/')" }
    Invoke-GitText -Arguments @('fsck', '--full') | Out-Null
    $runtimeScript = Join-Path ([IO.Path]::GetFullPath((Invoke-GitText -Arguments @('rev-parse', '--show-toplevel')))) 'scripts/invoke-aer-runtime.ps1'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runtimeScript -HookEvent Verify -RefreshRemote -TestPushPermission
    if ($LASTEXITCODE -ne 0) { throw "Post-promotion Runtime verification failed with exit code $LASTEXITCODE." }
    Write-Output 'Result: PROMOTION_COMPLETE'
    Write-Output "Local main: $localHead"
    Write-Output "Actual remote main: $remoteHead"
    Write-Output 'Ahead/behind: 0/0'
}

try {
    $CandidateCommit = $CandidateCommit.ToLowerInvariant()
    $ExpectedBaseCommit = $ExpectedBaseCommit.ToLowerInvariant()
    Assert-CanonicalBoundary

    if ($Phase -eq 'PostVerify') { Invoke-PostVerify; exit 0 }

    [void](Assert-BaseAuthority)
    $candidate = Import-And-VerifyCandidate
    Write-Step "Verified exact candidate $($candidate.Sha)"

    if ($Phase -eq 'Preflight') {
        Write-Output 'Result: PROMOTION_PREFLIGHT_PASS'
        Write-Output "Expected base: $ExpectedBaseCommit"
        Write-Output "Candidate: $($candidate.Sha)"
        Write-Output "Changed files: $($candidate.Files.Count)"
        exit 0
    }

    $remoteBefore = Get-ActualRemoteHead
    if ($remoteBefore -ne $ExpectedBaseCommit) { throw "Actual remote changed before fast-forward: $remoteBefore" }
    Write-Step "Fast-forwarding $Branch to exact candidate"
    Invoke-GitText -Arguments @('merge', '--ff-only', $candidate.Ref) | Out-Null
    $localAfter = Resolve-Commit -Revision 'HEAD'
    if ($localAfter -ne $CandidateCommit) { throw "Local fast-forward target mismatch: $localAfter" }

    if (-not $Push.IsPresent) {
        Write-Output 'Result: LOCAL_ONLY'
        Write-Output "Local main: $localAfter"
        Write-Output 'Push: NOT_REQUESTED'
        exit 0
    }

    Write-Step "Pushing $Branch normally to $Remote"
    $pushResult = Invoke-GitResult -Arguments @('push', $Remote, "$Branch`:$Branch")
    if ($pushResult.ExitCode -ne 0) {
        [Console]::Error.WriteLine("Push failed after local fast-forward: $($pushResult.Text)")
        Write-Output 'Result: LOCAL_ONLY'
        Write-Output "Local main: $localAfter"
        Write-Output 'Push: BLOCKED'
        exit 3
    }
    Invoke-PostVerify
}
catch {
    [Console]::Error.WriteLine('[AER Promotion] FAILED')
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
