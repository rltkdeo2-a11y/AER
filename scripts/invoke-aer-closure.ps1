[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Preflight", "Finalize")]
    [string]$Phase,

    [Parameter(Mandatory = $true)]
    [ValidateSet("Lightweight", "Standard", "Release")]
    [string]$Mode,

    [Parameter(Mandatory = $true)]
    [string]$ExpectedBaseCommit,

    [string]$Branch = "main",

    [string]$Remote = "origin",

    [string[]]$AllowedFiles,

    [string]$CommitMessage,

    [string]$ValidationScript = "scripts/validate-research-close.ps1",

    [switch]$AllowProtectedFiles,

    [switch]$Push
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host ("[AER Closure] {0}" -f $Message)
}

function ConvertTo-GitCommandLineArgument {
    param([AllowEmptyString()][string]$Argument)

    if ($null -eq $Argument) {
        throw "Git arguments cannot be null."
    }

    $escaped = [regex]::Replace($Argument, '(\\*)"', '$1$1\"')
    $trailingBackslashes = [regex]::Match($Argument, '(\\*)$').Groups[1].Value
    return '"' + $escaped + $trailingBackslashes + '"'
}

function ConvertFrom-GitOutputText {
    param([AllowEmptyString()][string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return @()
    }

    $trimmed = $Text.TrimEnd([char[]]@("`r", "`n"))
    if ([string]::IsNullOrEmpty($trimmed)) {
        return @()
    }

    return @([regex]::Split($trimmed, "\r\n|\n|\r"))
}

function Format-GitDiagnostics {
    param(
        [string[]]$StandardOutput,
        [string[]]$StandardError
    )

    $details = New-Object 'Collections.Generic.List[string]'
    if (@($StandardOutput).Count -gt 0) {
        [void]$details.Add("stdout: $($StandardOutput -join [Environment]::NewLine)")
    }
    if (@($StandardError).Count -gt 0) {
        [void]$details.Add("stderr: $($StandardError -join [Environment]::NewLine)")
    }
    if ($details.Count -eq 0) {
        return "no output"
    }
    return ($details -join [Environment]::NewLine)
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowFailure
    )

    $process = New-Object Diagnostics.Process
    $process.StartInfo = New-Object Diagnostics.ProcessStartInfo
    $process.StartInfo.FileName = "git"
    $process.StartInfo.Arguments = (@($Arguments | ForEach-Object {
        ConvertTo-GitCommandLineArgument $_
    }) -join ' ')
    $process.StartInfo.WorkingDirectory = (Get-Location).ProviderPath
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    $process.StartInfo.CreateNoWindow = $true

    if (-not $process.Start()) {
        throw "Unable to start Git."
    }

    $standardOutputTask = $process.StandardOutput.ReadToEndAsync()
    $standardErrorTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    $standardOutput = @(ConvertFrom-GitOutputText $standardOutputTask.Result)
    $standardError = @(ConvertFrom-GitOutputText $standardErrorTask.Result)
    $exitCode = $process.ExitCode
    $process.Dispose()

    if (($exitCode -ne 0) -and (-not $AllowFailure)) {
        $diagnostics = Format-GitDiagnostics -StandardOutput $standardOutput -StandardError $standardError
        throw "Git command failed (git $($Arguments -join ' ')): $diagnostics"
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        StandardOutput = $standardOutput
        StandardError = $standardError
    }
}

function Get-GitLine {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)

    $result = Invoke-Git -Arguments $Arguments
    return (($result.StandardOutput | Select-Object -First 1).ToString().Trim())
}

function Get-LocalConfig {
    param([Parameter(Mandatory = $true)][string]$Name)

    $result = Invoke-Git -Arguments @("config", "--local", "--get", $Name) -AllowFailure
    if ($result.ExitCode -eq 0) {
        return (($result.StandardOutput | Select-Object -First 1).ToString().Trim())
    }
    if ($result.ExitCode -eq 1) { return $null }
    $diagnostics = Format-GitDiagnostics -StandardOutput $result.StandardOutput -StandardError $result.StandardError
    throw "Unable to read local Git configuration '$Name'. $diagnostics"
}

function Normalize-RepositoryPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = $Path.Replace('\', '/').Trim()
    while ($normalized.StartsWith('./', [StringComparison]::Ordinal)) {
        $normalized = $normalized.Substring(2)
    }
    return $normalized
}

function Get-RepositoryRoot {
    $root = Get-GitLine -Arguments @("rev-parse", "--show-toplevel")
    if ([string]::IsNullOrWhiteSpace($root)) {
        throw "Unable to determine repository root."
    }
    return [IO.Path]::GetFullPath($root)
}

function Resolve-Commit {
    param([Parameter(Mandatory = $true)][string]$Revision)

    $result = Invoke-Git -Arguments @("rev-parse", "--verify", "$Revision^{commit}") -AllowFailure
    if ($result.ExitCode -ne 0) {
        $diagnostics = Format-GitDiagnostics -StandardOutput $result.StandardOutput -StandardError $result.StandardError
        throw "Commit or revision cannot be resolved: $Revision. $diagnostics"
    }
    return (($result.StandardOutput | Select-Object -First 1).ToString().Trim())
}

function Test-InProgressGitOperation {
    param([Parameter(Mandatory = $true)][string]$GitDirectory)

    $markers = @(
        "MERGE_HEAD",
        "CHERRY_PICK_HEAD",
        "REVERT_HEAD",
        "BISECT_LOG",
        "rebase-apply",
        "rebase-merge"
    )

    foreach ($marker in $markers) {
        if (Test-Path -LiteralPath (Join-Path $GitDirectory $marker)) {
            throw "Git operation is already in progress: $marker"
        }
    }
}

function Update-RemoteBranch {
    param(
        [Parameter(Mandatory = $true)][string]$RemoteName,
        [Parameter(Mandatory = $true)][string]$BranchName
    )

    Write-Step "Fetching $RemoteName/$BranchName"
    Invoke-Git -Arguments @("fetch", "--quiet", $RemoteName, $BranchName) | Out-Null

    $remoteRevision = "$RemoteName/$BranchName"
    $result = Invoke-Git -Arguments @("rev-parse", "--verify", "$remoteRevision^{commit}") -AllowFailure
    if ($result.ExitCode -ne 0) {
        $diagnostics = Format-GitDiagnostics -StandardOutput $result.StandardOutput -StandardError $result.StandardError
        throw "Remote branch cannot be resolved after fetch: $remoteRevision. $diagnostics"
    }
    return (($result.StandardOutput | Select-Object -First 1).ToString().Trim())
}

function Get-ChangedFiles {
    $paths = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)

    $commands = @(
        @("diff", "--name-only", "--"),
        @("diff", "--cached", "--name-only", "--"),
        @("ls-files", "--others", "--exclude-standard", "--")
    )

    foreach ($command in $commands) {
        $result = Invoke-Git -Arguments $command
        foreach ($line in $result.StandardOutput) {
            $path = $line.ToString().Trim()
            if (-not [string]::IsNullOrWhiteSpace($path)) {
                [void]$paths.Add((Normalize-RepositoryPath $path))
            }
        }
    }

    return @($paths | Sort-Object)
}

function Assert-AllowedFiles {
    param(
        [Parameter(Mandatory = $true)][string[]]$ChangedFiles,
        [string[]]$Allowed
    )

    $allowedFiles = @($Allowed)
    if ($allowedFiles.Count -eq 0) {
        throw "AllowedFiles must be provided for Finalize."
    }

    $allowedPatterns = @($allowedFiles | ForEach-Object {
        if (-not [string]::IsNullOrWhiteSpace($_)) { Normalize-RepositoryPath $_ }
    })

    if ($allowedPatterns.Count -eq 0) {
        throw "AllowedFiles contains no usable paths or patterns."
    }

    $unexpected = New-Object 'Collections.Generic.List[string]'
    foreach ($changedPath in $ChangedFiles) {
        $matched = $false
        foreach ($pattern in $allowedPatterns) {
            if ($changedPath -like $pattern) {
                $matched = $true
                break
            }
        }
        if (-not $matched) {
            [void]$unexpected.Add($changedPath)
        }
    }

    if ($unexpected.Count -gt 0) {
        throw "Changed files exceed the approved scope: $($unexpected -join ', ')"
    }
}

function Assert-CleanWorkingTree {
    $status = Invoke-Git -Arguments @("status", "--porcelain=v1", "--untracked-files=all")
    $lines = @($status.StandardOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_.ToString()) })
    if ($lines.Count -gt 0) {
        throw "Working tree is not clean: $($lines -join [Environment]::NewLine)"
    }
}

function Assert-NoStagedChanges {
    $result = Invoke-Git -Arguments @("diff", "--cached", "--quiet", "--") -AllowFailure
    if ($result.ExitCode -eq 1) {
        throw "Staged changes already exist before Finalize."
    }
    if ($result.ExitCode -ne 0) {
        $diagnostics = Format-GitDiagnostics -StandardOutput $result.StandardOutput -StandardError $result.StandardError
        throw "Unable to inspect staged changes. $diagnostics"
    }
}

function Assert-ExecutionRepositoryBoundary {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$GitDirectory,
        [Parameter(Mandatory = $true)][string]$ExpectedBase
    )

    if ((Get-LocalConfig -Name "aer.repositoryRole") -ne "EXECUTION") {
        throw "Candidate closure requires REPOSITORY_ROLE=EXECUTION."
    }
    if ($Push.IsPresent) {
        throw "The execution repository cannot Push canonical history. Use owner-controlled exact-Commit promotion."
    }

    $commonDirectoryRaw = Get-GitLine -Arguments @("rev-parse", "--git-common-dir")
    $commonDirectory = if ([IO.Path]::IsPathRooted($commonDirectoryRaw)) {
        [IO.Path]::GetFullPath($commonDirectoryRaw)
    }
    else {
        [IO.Path]::GetFullPath((Join-Path $RepositoryRoot $commonDirectoryRaw))
    }
    $expectedGitDirectory = [IO.Path]::GetFullPath((Join-Path $RepositoryRoot ".git"))
    if (($GitDirectory -ne $expectedGitDirectory) -or ($commonDirectory -ne $GitDirectory)) {
        throw "Execution repository must use its own in-tree Git directory; linked worktree or external GIT_DIR detected."
    }
    if (Test-Path -LiteralPath (Join-Path $GitDirectory "objects/info/alternates") -PathType Leaf) {
        throw "Execution repository uses object alternates. A full independent object database is required."
    }
    if ((Test-Path -LiteralPath (Join-Path $GitDirectory "shallow") -PathType Leaf) -or
        (-not [string]::IsNullOrWhiteSpace($env:GIT_ALTERNATE_OBJECT_DIRECTORIES)) -or
        (-not [string]::IsNullOrWhiteSpace($env:GIT_OBJECT_DIRECTORY))) {
        throw "Execution repository is shallow or uses an external/shared object directory."
    }

    $promisor = Invoke-Git -Arguments @("config", "--local", "--get-regexp", "^remote\..*\.promisor$") -AllowFailure
    if (($promisor.ExitCode -eq 0) -or (-not [string]::IsNullOrWhiteSpace((Get-LocalConfig -Name "extensions.partialClone")))) {
        throw "Execution repository is partial or promisor-backed; a full clone is required."
    }

    $canonicalBaseline = Get-LocalConfig -Name "aer.canonicalBaseline"
    if ($canonicalBaseline -ne $ExpectedBase) {
        throw "Local aer.canonicalBaseline '$canonicalBaseline' does not match expected candidate parent '$ExpectedBase'."
    }
    if ((Get-LocalConfig -Name "aer.pushPolicy") -ne "DENY") {
        throw "Execution repository must set aer.pushPolicy=DENY."
    }

    $pushUrls = Invoke-Git -Arguments @("remote", "get-url", "--push", "--all", $Remote) -AllowFailure
    if (($pushUrls.ExitCode -ne 0) -or (@($pushUrls.StandardOutput).Count -eq 0) -or
        (@($pushUrls.StandardOutput | Where-Object { $_.ToString() -notlike "disabled://*" }).Count -gt 0)) {
        throw "Execution canonical Push URL is not explicitly disabled for remote '$Remote'."
    }
}

function Invoke-ClosureValidation {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string[]]$ChangedFiles
    )

    $scriptPath = $ValidationScript
    if (-not [IO.Path]::IsPathRooted($scriptPath)) {
        $scriptPath = Join-Path $RepositoryRoot $scriptPath
    }
    $scriptPath = [IO.Path]::GetFullPath($scriptPath)

    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        throw "Validation script not found: $scriptPath"
    }

    Write-Step "Running repository closure validation"
    $powerShellPath = [Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    if ([string]::IsNullOrWhiteSpace($powerShellPath)) {
        throw "Unable to determine the current PowerShell executable."
    }

    $expectedFileLiterals = @($ChangedFiles | ForEach-Object {
        "'" + $_.Replace("'", "''") + "'"
    })
    $validationCommand = "& '$($scriptPath.Replace("'", "''"))' -Mode '$($Mode.Replace("'", "''"))' -ExpectedFiles @($($expectedFileLiterals -join ','))"
    if ($AllowProtectedFiles.IsPresent) {
        $validationCommand += " -AllowProtectedFiles"
    }

    & $powerShellPath -NoProfile -ExecutionPolicy Bypass -Command $validationCommand
    $validationExitCode = $LASTEXITCODE
    if ($validationExitCode -ne 0) {
        throw "Repository closure validation failed with exit code $validationExitCode."
    }

    Write-Step "Running git diff --check"
    Invoke-Git -Arguments @("diff", "--check", "--") | Out-Null
}

try {
    try { [Console]::OutputEncoding = New-Object Text.UTF8Encoding($false) } catch { }

    $repositoryRoot = Get-RepositoryRoot
    Set-Location -LiteralPath $repositoryRoot

    $gitDirectoryRaw = Get-GitLine -Arguments @("rev-parse", "--git-dir")
    $gitDirectory = if ([IO.Path]::IsPathRooted($gitDirectoryRaw)) {
        [IO.Path]::GetFullPath($gitDirectoryRaw)
    }
    else {
        [IO.Path]::GetFullPath((Join-Path $repositoryRoot $gitDirectoryRaw))
    }

    Test-InProgressGitOperation -GitDirectory $gitDirectory

    $currentBranch = Get-GitLine -Arguments @("branch", "--show-current")
    if ($currentBranch -ne $Branch) {
        throw "Current branch '$currentBranch' does not match approved branch '$Branch'."
    }

    $expectedBase = Resolve-Commit -Revision $ExpectedBaseCommit
    $localHead = Resolve-Commit -Revision "HEAD"
    if ($localHead -ne $expectedBase) {
        throw "Local HEAD '$localHead' does not match expected base '$expectedBase'."
    }

    Assert-ExecutionRepositoryBoundary -RepositoryRoot $repositoryRoot -GitDirectory $gitDirectory -ExpectedBase $expectedBase

    if ($Phase -eq "Preflight") {
        Assert-CleanWorkingTree
        Write-Step "Preflight passed"
        Write-Output "Repository: $repositoryRoot"
        Write-Output "Branch: $Branch"
        Write-Output "Base Commit: $expectedBase"
        Write-Output "Canonical Push Boundary: DENIED"
        Write-Output "Remote authority must be rechecked by the owner promotion runner."
        exit 0
    }

    Assert-NoStagedChanges

    $changedFiles = @(Get-ChangedFiles)
    if ($changedFiles.Count -eq 0) {
        Write-Step "No repository change required"
        Write-Output "Result: NO-OP"
        Write-Output "Baseline Commit: $expectedBase"
        exit 0
    }

    Assert-AllowedFiles -ChangedFiles $changedFiles -Allowed $AllowedFiles

    if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
        throw "CommitMessage is required for Finalize when changes exist."
    }

    Invoke-ClosureValidation -RepositoryRoot $repositoryRoot -ChangedFiles $changedFiles

    Write-Step "Staging approved files"
    Invoke-Git -Arguments (@("add", "--") + $changedFiles) | Out-Null

    $stagedFilesResult = Invoke-Git -Arguments @("diff", "--cached", "--name-only", "--")
    $stagedFiles = @($stagedFilesResult.StandardOutput | ForEach-Object {
        $value = $_.ToString().Trim()
        if (-not [string]::IsNullOrWhiteSpace($value)) { Normalize-RepositoryPath $value }
    })

    $stagedSet = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($path in $stagedFiles) { [void]$stagedSet.Add($path) }

    foreach ($path in $changedFiles) {
        if (-not $stagedSet.Contains($path)) {
            throw "Approved changed file was not staged: $path"
        }
    }
    foreach ($path in $stagedFiles) {
        if ($changedFiles -notcontains $path) {
            throw "Unexpected staged file: $path"
        }
    }

    Invoke-Git -Arguments @("diff", "--cached", "--check", "--") | Out-Null

    Write-Step "Creating Commit"
    Invoke-Git -Arguments @("commit", "-m", $CommitMessage, "--") | Out-Null
    $newCommit = Resolve-Commit -Revision "HEAD"

    Write-Step "Candidate Finalize passed"
    Write-Output "Result: CANDIDATE_COMMITTED"
    Write-Output "Candidate Commit: $newCommit"
    Write-Output "Canonical Push: DENIED_BY_EXECUTION_BOUNDARY"

    $remaining = Invoke-Git -Arguments @("status", "--porcelain=v1", "--untracked-files=all")
    $remainingLines = @($remaining.StandardOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_.ToString()) })
    if ($remainingLines.Count -gt 0) {
        throw "Working tree is not clean after Finalize: $($remainingLines -join [Environment]::NewLine)"
    }

    exit 0
}
catch {
    [Console]::Error.WriteLine("[AER Closure] FAILED")
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
