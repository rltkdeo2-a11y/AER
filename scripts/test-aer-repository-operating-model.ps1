[CmdletBinding()]
param(
    [string]$CandidateCommit = 'HEAD',
    [string]$ExpectedBaseCommit = 'HEAD^'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object Text.UTF8Encoding($false) } catch { }

function GitText([string]$Root, [string[]]$Arguments) {
    $priorErrorAction = $ErrorActionPreference
    $nativePreferenceExists = Test-Path variable:PSNativeCommandUseErrorActionPreference
    if ($nativePreferenceExists) { $priorNativePreference = $PSNativeCommandUseErrorActionPreference }
    $ErrorActionPreference = 'Continue'
    if ($nativePreferenceExists) { $PSNativeCommandUseErrorActionPreference = $false }
    try { $output = @(& git -C $Root @Arguments 2>&1 | ForEach-Object { $_.ToString() }); $exitCode = $LASTEXITCODE }
    finally {
        $ErrorActionPreference = $priorErrorAction
        if ($nativePreferenceExists) { $PSNativeCommandUseErrorActionPreference = $priorNativePreference }
    }
    if ($exitCode -ne 0) { throw "git -C $Root $($Arguments -join ' ') failed: $($output -join [Environment]::NewLine)" }
    return ($output -join [Environment]::NewLine).Trim()
}

function RunPowerShell([string]$Root, [string]$Script, [string[]]$Arguments, [string]$InputText) {
    $start = New-Object Diagnostics.ProcessStartInfo
    $start.FileName = 'powershell.exe'
    $start.WorkingDirectory = $Root
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.RedirectStandardInput = $true
    $start.CreateNoWindow = $true
    $quoted = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Script) + $Arguments
    $start.Arguments = ($quoted | ForEach-Object { '"' + $_.Replace('"', '\"') + '"' }) -join ' '
    $process = New-Object Diagnostics.Process
    $process.StartInfo = $start
    if (-not $process.Start()) { throw 'Unable to start PowerShell test process.' }
    if (-not [string]::IsNullOrWhiteSpace($InputText)) { $process.StandardInput.Write($InputText) }
    $process.StandardInput.Close()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    $code = $process.ExitCode
    $process.Dispose()
    return [pscustomobject]@{ ExitCode = $code; Output = $stdout; Error = $stderr }
}

function ConfigureExecution([string]$Root, [string]$Baseline, [string]$Branch) {
    GitText $Root @('config', '--local', 'aer.repositoryRole', 'EXECUTION') | Out-Null
    GitText $Root @('config', '--local', 'aer.pushPolicy', 'DENY') | Out-Null
    GitText $Root @('config', '--local', 'aer.canonicalRemote', 'origin') | Out-Null
    GitText $Root @('config', '--local', 'aer.canonicalBranch', 'main') | Out-Null
    GitText $Root @('config', '--local', 'aer.canonicalBaseline', $Baseline) | Out-Null
    GitText $Root @('remote', 'set-url', '--push', 'origin', 'disabled://execution-repository') | Out-Null
    GitText $Root @('switch', '-c', $Branch) | Out-Null
}

function Require([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
    Write-Output "PASS: $Message"
}

$source = [IO.Path]::GetFullPath((GitText (Get-Location).Path @('rev-parse', '--show-toplevel')))
$candidate = GitText $source @('rev-parse', "$CandidateCommit`^{commit}")
$base = GitText $source @('rev-parse', "$ExpectedBaseCommit`^{commit}")
$runtimeRelative = 'scripts/invoke-aer-runtime.ps1'
$promotionRelative = 'scripts/invoke-aer-promotion.ps1'
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar)
$testRoot = Join-Path $tempBase ("aer-repository-model-" + [Guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Path $testRoot | Out-Null

    $authorityRemote = Join-Path $testRoot 'authority.git'
    GitText $source @('init', '--bare', $authorityRemote) | Out-Null
    GitText $source @('push', $authorityRemote, "$candidate`:refs/heads/main") | Out-Null
    GitText $authorityRemote @('symbolic-ref', 'HEAD', 'refs/heads/main') | Out-Null

    $normal = Join-Path $testRoot 'execution-normal'
    GitText $source @('clone', '--no-local', $authorityRemote, $normal) | Out-Null
    ConfigureExecution -Root $normal -Baseline $candidate -Branch 'candidate/normal-boundary'
    $normalRuntime = RunPowerShell -Root $normal -Script (Join-Path $normal $runtimeRelative) -Arguments @('-HookEvent', 'Verify', '-RefreshRemote') -InputText $null
    if ($normalRuntime.ExitCode -ne 0) { Write-Output "NORMAL STDOUT:`n$($normalRuntime.Output)`nNORMAL STDERR:`n$($normalRuntime.Error)" }
    Require (($normalRuntime.ExitCode -eq 0) -and ($normalRuntime.Output -match 'Object database: FULL_INDEPENDENT') -and ($normalRuntime.Output -match 'AER_RUNTIME_VERIFY_PASS')) 'full independent execution clone passes'

    $shared = Join-Path $testRoot 'execution-shared'
    GitText $source @('clone', '--shared', $authorityRemote, $shared) | Out-Null
    ConfigureExecution -Root $shared -Baseline $candidate -Branch 'candidate/shared-boundary'
    $sharedRuntime = RunPowerShell -Root $shared -Script (Join-Path $shared $runtimeRelative) -Arguments @('-HookEvent', 'Verify', '-RefreshRemote') -InputText $null
    Require (($sharedRuntime.ExitCode -eq 2) -and ($sharedRuntime.Output -match 'ALTERNATES_FILE_PRESENT') -and ($sharedRuntime.Output -match 'AER_RUNTIME_VERIFY_HOLD')) 'shared clone and alternates are held'

    $advance = Join-Path $testRoot 'remote-advance'
    GitText $source @('clone', '--no-local', $authorityRemote, $advance) | Out-Null
    GitText $advance @('config', 'user.name', 'AER Test') | Out-Null
    GitText $advance @('config', 'user.email', 'aer-test@example.invalid') | Out-Null
    Set-Content -LiteralPath (Join-Path $advance 'AER_STALE_TEST.txt') -Value 'stale-baseline-test' -Encoding UTF8
    GitText $advance @('add', '--', 'AER_STALE_TEST.txt') | Out-Null
    GitText $advance @('commit', '-m', 'test: advance isolated authority') | Out-Null
    GitText $advance @('push', 'origin', 'main:main') | Out-Null
    $staleRuntime = RunPowerShell -Root $normal -Script (Join-Path $normal $runtimeRelative) -Arguments @('-HookEvent', 'Verify', '-RefreshRemote') -InputText $null
    if ($staleRuntime.ExitCode -ne 2) { Write-Output "STALE STDOUT:`n$($staleRuntime.Output)`nSTALE STDERR:`n$($staleRuntime.Error)" }
    Require (($staleRuntime.ExitCode -eq 2) -and ($staleRuntime.Output -match 'REMOTE_BASE_CHANGED_OBJECT_UNAVAILABLE')) 'stale execution baseline is held'

    $promotionRemote = Join-Path $testRoot 'promotion.git'
    GitText $source @('init', '--bare', $promotionRemote) | Out-Null
    GitText $source @('push', $promotionRemote, "$base`:refs/heads/main") | Out-Null
    GitText $promotionRemote @('symbolic-ref', 'HEAD', 'refs/heads/main') | Out-Null
    $canonical = Join-Path $testRoot 'canonical-owner'
    GitText $source @('clone', '--no-local', $promotionRemote, $canonical) | Out-Null
    GitText $canonical @('config', '--local', 'aer.repositoryRole', 'CANONICAL_OWNER') | Out-Null
    GitText $canonical @('config', '--local', 'aer.pushPolicy', 'OWNER_ONLY') | Out-Null
    GitText $canonical @('config', '--local', 'aer.canonicalRemote', 'origin') | Out-Null
    GitText $canonical @('config', '--local', 'aer.canonicalBranch', 'main') | Out-Null

    $editGate = RunPowerShell -Root $canonical -Script (Join-Path $canonical $runtimeRelative) -Arguments @('-HookEvent', 'PreToolUse') -InputText '{"cwd":"test","tool_name":"apply_patch"}'
    Require (($editGate.ExitCode -eq 0) -and ($editGate.Output -match 'permissionDecision":"deny') -and ($editGate.Output -match 'CANONICAL_OWNER')) 'canonical Agent edit is denied'

    $changedFiles = @((GitText $source @('diff', '--name-only', "$base..$candidate", '--')) -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $title = GitText $source @('show', '-s', '--format=%s', $candidate)
    $manifestPath = Join-Path $testRoot 'validation-manifest.json'
    $manifest = [ordered]@{
        schemaVersion = 1
        candidateCommit = $candidate
        expectedBaseCommit = $base
        commitTitle = $title
        changedFiles = $changedFiles
        policy = 'PASS'
        results = [ordered]@{
            sourceVerify = 'PASS'
            gitDiffCheck = 'PASS'
            repositoryValidation = 'PASS'
            runtimeVerify = 'PASS'
            authorityValidation = 'PASS'
            gitFsck = 'PASS'
        }
    }
    $manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

    $quote = {
        param([string]$Value)
        return "'" + $Value.Replace("'", "''") + "'"
    }
    $expectedLiterals = @($changedFiles | ForEach-Object { & $quote $_ })
    $promotionDriver = Join-Path $testRoot 'run-promotion.ps1'
    $promotionCommand = "& $(& $quote (Join-Path $canonical $promotionRelative)) -Phase Promote -CandidateSource $(& $quote $source) -CandidateCommit $candidate -ExpectedBaseCommit $base -ExpectedTitle $(& $quote $title) -ExpectedFiles @($($expectedLiterals -join ',')) -ValidationManifest $(& $quote $manifestPath) -Branch main -Remote origin -Push"
    Set-Content -LiteralPath $promotionDriver -Value $promotionCommand -Encoding UTF8
    $promotion = RunPowerShell -Root $canonical -Script $promotionDriver -Arguments @() -InputText $null
    Require (($promotion.ExitCode -eq 0) -and ($promotion.Output -match 'Result: PROMOTION_COMPLETE')) "isolated exact-Commit promotion passes ($($promotion.Error.Trim()))"
    Require ((GitText $canonical @('rev-parse', 'HEAD')) -eq $candidate) 'local canonical main equals candidate'
    Require ((GitText $source @('ls-remote', '--heads', $promotionRemote, 'refs/heads/main')) -match "^$candidate") 'isolated actual origin/main equals candidate'

    Write-Output 'AER_REPOSITORY_OPERATING_MODEL_TEST_PASS'
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        $resolved = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $testRoot).Path)
        if (-not $resolved.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove non-temporary test path: $resolved"
        }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
