[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Mode,

    [string[]]$ExpectedFiles,

    [switch]$AllowProtectedFiles
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:PassCount = 0
$script:WarnCount = 0
$script:FailCount = 0
$script:InfoCount = 0

function Write-Result {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("PASS", "WARN", "FAIL", "INFO")]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    switch ($Level) {
        "PASS" { $script:PassCount++ }
        "WARN" { $script:WarnCount++ }
        "FAIL" { $script:FailCount++ }
        "INFO" { $script:InfoCount++ }
    }

    Write-Output ("[{0}] {1}" -f $Level, $Message)
}

function Invoke-GitText {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [switch]$AllowFailure
    )

    $output = & git @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    if (($exitCode -ne 0) -and (-not $AllowFailure)) {
        throw "Git command failed (git $($Arguments -join ' ')): $($output -join [Environment]::NewLine)"
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = @($output)
    }
}

function ConvertTo-NormalizedPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = $Path.Replace('\', '/').Trim()
    while ($normalized.StartsWith('./', [StringComparison]::Ordinal)) {
        $normalized = $normalized.Substring(2)
    }
    return $normalized
}

function Get-NulSeparatedGitPaths {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)

    $process = New-Object Diagnostics.Process
    $process.StartInfo = New-Object Diagnostics.ProcessStartInfo
    $process.StartInfo.FileName = "git"
    $process.StartInfo.Arguments = ($Arguments | ForEach-Object {
        if ($_ -match '[\s"]') { '"' + $_.Replace('"', '\"') + '"' } else { $_ }
    }) -join ' '
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    $process.StartInfo.CreateNoWindow = $true
    if (-not $process.Start()) {
        throw "Unable to start Git."
    }
    $bytes = New-Object byte[] 8192
    $stream = $process.StandardOutput.BaseStream
    $memory = New-Object IO.MemoryStream
    while (($read = $stream.Read($bytes, 0, $bytes.Length)) -gt 0) {
        $memory.Write($bytes, 0, $read)
    }
    $errorText = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) {
        throw "Git command failed (git $($Arguments -join ' ')): $errorText"
    }
    $text = [Text.Encoding]::UTF8.GetString($memory.ToArray())
    if ([string]::IsNullOrEmpty($text)) {
        return @()
    }
    return @($text.Split(@([char]0), [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { -not [string]::IsNullOrEmpty($_) })
}

function Get-ChangedFiles {
    $paths = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $deleted = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)

    $pathCommands = @(
        @("diff", "--name-only", "-z", "--"),
        @("diff", "--cached", "--name-only", "-z", "--"),
        @("ls-files", "--others", "--exclude-standard", "-z", "--")
    )
    foreach ($command in $pathCommands) {
        foreach ($path in (Get-NulSeparatedGitPaths -Arguments $command)) {
            [void]$paths.Add((ConvertTo-NormalizedPath $path))
        }
    }

    $deleteCommands = @(
        @("diff", "--name-only", "--diff-filter=D", "-z", "--"),
        @("diff", "--cached", "--name-only", "--diff-filter=D", "-z", "--")
    )
    foreach ($command in $deleteCommands) {
        foreach ($path in (Get-NulSeparatedGitPaths -Arguments $command)) {
            $normalized = ConvertTo-NormalizedPath $path
            [void]$paths.Add($normalized)
            [void]$deleted.Add($normalized)
        }
    }

    return [pscustomobject]@{
        Paths = @($paths | Sort-Object)
        Deleted = $deleted
    }
}

function Test-ExpectedFiles {
    param(
        [string[]]$ChangedFiles,
        [string[]]$Expected
    )

    if (($null -eq $Expected) -or ($Expected.Count -eq 0)) {
        Write-Result INFO "ExpectedFiles not specified; validating the complete changed-file list"
        return
    }

    $changedSet = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($path in $ChangedFiles) { [void]$changedSet.Add($path) }
    $expectedSet = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $missingExpectedCount = 0
    foreach ($path in $Expected) {
        $normalized = ConvertTo-NormalizedPath $path
        [void]$expectedSet.Add($normalized)
        if (-not $changedSet.Contains($normalized)) {
            $missingExpectedCount++
            Write-Result FAIL "Expected file is not in the changed-file list: $normalized"
        }
    }

    if ($missingExpectedCount -eq 0) {
        Write-Result PASS "All expected files are present in the changed-file list"
    }

    foreach ($path in $ChangedFiles) {
        if (-not $expectedSet.Contains($path)) {
            Write-Result WARN "Unexpected changed file: $path"
        }
    }
}

function Test-ClosureFileCount {
    param([int]$Count, [string]$ClosureMode)

    switch ($ClosureMode) {
        "Lightweight" {
            if ($Count -eq 0) { Write-Result WARN "Lightweight mode found no changed files" }
            elseif ($Count -ge 3) { Write-Result WARN "Lightweight mode normally changes no more than 2 files (found $Count)" }
            else { Write-Result PASS "Lightweight mode changed-file count is within the normal range (1-2)" }
        }
        "Standard" {
            if ($Count -lt 2) { Write-Result WARN "Standard mode normally changes 2-4 files (found $Count)" }
            elseif ($Count -ge 5) { Write-Result WARN "Standard mode normally changes no more than 4 files (found $Count)" }
            else { Write-Result PASS "Standard mode changed-file count is within the normal range (2-4)" }
        }
        "Release" { Write-Result INFO "Release mode changed-file count: $Count (no fixed upper limit)" }
    }
}

function Test-ProtectedFiles {
    param([string[]]$ChangedFiles, [string]$ClosureMode, [bool]$AllowProtected)

    $protected = @(
        "BOOTSTRAP.md", "README.md", "CHANGELOG.md", "00_GOVERNANCE/CURRENT_STATE",
        "00_GOVERNANCE/SPECIFICATION.md", "00_GOVERNANCE/OPERATION_RULES.md",
        "00_GOVERNANCE/PROJECT_CHARTER.md", "00_GOVERNANCE/RESEARCH_PHILOSOPHY.md"
    )
    $found = @($ChangedFiles | Where-Object { $protected -contains $_ })
    if ($found.Count -eq 0) {
        Write-Result PASS "No protected files modified"
        return
    }

    foreach ($path in $found) {
        if (($ClosureMode -eq "Release") -and $AllowProtected) {
            Write-Result WARN "Protected file modification allowed for Release mode: $path"
        }
        else {
            Write-Result FAIL "Protected file modified: $path"
        }
    }
}

function Test-FileSizes {
    param([string[]]$ChangedFiles, $DeletedFiles, [string]$Root)

    $zeroByteFound = $false
    foreach ($path in $ChangedFiles) {
        if ($DeletedFiles.Contains($path)) {
            Write-Result INFO "Deleted file: $path"
            continue
        }
        $fullPath = Join-Path $Root ($path.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
            if ((Get-Item -LiteralPath $fullPath).Length -eq 0) {
                $zeroByteFound = $true
                Write-Result FAIL "Zero-byte file: $path"
            }
        }
    }
    if (-not $zeroByteFound) { Write-Result PASS "No zero-byte changed files" }
}

function Read-StrictUtf8File {
    param([Parameter(Mandatory = $true)][string]$Path)

    $bytes = [IO.File]::ReadAllBytes($Path)
    $encoding = New-Object Text.UTF8Encoding($false, $true)
    $text = $encoding.GetString($bytes)
    return [pscustomobject]@{ Bytes = $bytes; Text = $text }
}

function Test-MarkdownIntegrity {
    param([string[]]$ChangedFiles, $DeletedFiles, [string]$Root)

    $markdownFiles = @($ChangedFiles | Where-Object { $_ -match '(?i)\.md$' -and -not $DeletedFiles.Contains($_) })
    if ($markdownFiles.Count -eq 0) {
        Write-Result PASS "No existing changed Markdown files require integrity checks"
        return
    }

    foreach ($path in $markdownFiles) {
        $fullPath = Join-Path $Root ($path.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { continue }
        try {
            $content = Read-StrictUtf8File $fullPath
            Write-Result PASS "Markdown is valid UTF-8: $path"
        }
        catch {
            Write-Result FAIL "Markdown is not valid UTF-8: $path ($($_.Exception.Message))"
            continue
        }

        if ([string]::IsNullOrWhiteSpace($content.Text)) {
            Write-Result FAIL "Markdown file is empty: $path"
        }
        else {
            Write-Result PASS "Markdown file is non-empty: $path"
        }

        $trailingLines = @()
        $lines = [regex]::Split($content.Text, "\r\n|\n|\r")
        for ($index = 0; $index -lt $lines.Count; $index++) {
            if ($lines[$index] -match '[ \t]+$') { $trailingLines += ($index + 1) }
        }
        if ($trailingLines.Count -gt 0) {
            Write-Result FAIL "Trailing whitespace in ${path} at line(s): $($trailingLines -join ', ')"
        }
        else {
            Write-Result PASS "No trailing whitespace: $path"
        }

        $hasFinalNewline = ($content.Bytes.Length -gt 0) -and (($content.Bytes[-1] -eq 10) -or ($content.Bytes[-1] -eq 13))
        if ($hasFinalNewline) { Write-Result PASS "Markdown ends with a newline: $path" }
        else { Write-Result FAIL "Markdown does not end with a newline: $path" }
    }
}

function Test-GitDiffChecks {
    foreach ($arguments in @(@("diff", "--check"), @("diff", "--cached", "--check"))) {
        $result = Invoke-GitText -Arguments $arguments -AllowFailure
        $label = "git $($arguments -join ' ')"
        if ($result.ExitCode -eq 0) { Write-Result PASS "$label passed" }
        else { Write-Result FAIL "$label failed: $($result.Output -join '; ')" }
    }
}

function Test-InternalIds {
    param([string[]]$ChangedFiles, $DeletedFiles, [string]$Root)

    foreach ($path in ($ChangedFiles | Where-Object { $_ -match '(?i)\.md$' -and -not $DeletedFiles.Contains($_) })) {
        $name = [IO.Path]::GetFileName($path)
        $expectedPattern = $null
        if ($name -match '^(PR|EV|RS|DEC|OP)(\d{3})_.*\.md$') {
            $labels = @{ PR = "Principle"; EV = "Evidence"; RS = "Reasoning"; DEC = "Decision"; OP = "Open Problem" }
            $expectedPattern = '(?im)^\s*' + [regex]::Escape($labels[$matches[1]]) + '\s+ID:\s*' + $matches[1] + '-' + $matches[2] + '\s*$'
        }
        elseif ($name -match '^SESSION_(\d{3})_.*\.md$') {
            $id = "SESSION-$($matches[1])"
            $expectedPattern = '(?im)(^\s*Session\s+ID:\s*' + [regex]::Escape($id) + '\s*$|\b' + [regex]::Escape($id) + '\b)'
        }
        if ($null -eq $expectedPattern) { continue }

        $fullPath = Join-Path $Root ($path.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { continue }
        try { $text = (Read-StrictUtf8File $fullPath).Text }
        catch { continue }
        if ($text -match $expectedPattern) { Write-Result PASS "Filename and internal ID are consistent: $path" }
        else { Write-Result FAIL "Missing or inconsistent internal ID: $path" }
    }
}

function Test-RepositoryReferences {
    param([string[]]$ChangedFiles, $DeletedFiles, [string]$Root)

    $prefixes = '00_GOVERNANCE|01_DEFINITIONS|02_PRINCIPLES|03_HYPOTHESES|04_ASSUMPTIONS|05_EVIDENCE|06_REASONING|07_DECISIONS|08_OPEN_PROBLEMS|09_RESEARCH_LOG|10_ARCHIVE|scripts'
    $pathPattern = '(?<![A-Za-z0-9_])(?:' + $prefixes + ')/[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*'
    foreach ($path in ($ChangedFiles | Where-Object { $_ -match '(?i)\.md$' -and -not $DeletedFiles.Contains($_) })) {
        $fullPath = Join-Path $Root ($path.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { continue }
        try { $lines = [regex]::Split((Read-StrictUtf8File $fullPath).Text, "\r\n|\n|\r") }
        catch { continue }
        foreach ($line in $lines) {
            if ($line -match '(?i)AER_WORKING/|example|example path|planned|future|external workspace|outside (the )?repository|\uC608\uC2DC|\uD5A5\uD6C4|\uC608\uC815|\uC678\uBD80\s+\uC791\uC5C5') { continue }
            foreach ($match in [regex]::Matches($line, $pathPattern)) {
                $reference = $match.Value.TrimEnd('.', ',', ':', ';')
                $referencePath = Join-Path $Root ($reference.Replace('/', [IO.Path]::DirectorySeparatorChar))
                if (-not (Test-Path -LiteralPath $referencePath)) {
                    Write-Result WARN "Repository reference does not exist: $reference (in $path)"
                }
            }
        }
    }
    Write-Result INFO "Repository reference checks are warning-only"
}

function Test-DeletedResearchObjects {
    param($DeletedFiles)

    $researchPrefix = '^(01_DEFINITIONS|02_PRINCIPLES|03_HYPOTHESES|04_ASSUMPTIONS|05_EVIDENCE|06_REASONING|07_DECISIONS|08_OPEN_PROBLEMS|09_RESEARCH_LOG)/'
    $found = $false
    foreach ($path in $DeletedFiles) {
        if ($path -match $researchPrefix) {
            $found = $true
            Write-Result WARN "Deleted research object: $path"
        }
    }
    if (-not $found) { Write-Result PASS "No deleted research objects detected" }
}

try {
    if (@("Lightweight", "Standard", "Release") -notcontains $Mode) {
        throw "Invalid Mode '$Mode'. Allowed values: Lightweight, Standard, Release."
    }

    try { [Console]::OutputEncoding = New-Object Text.UTF8Encoding($false) } catch { }
    $rootResult = Invoke-GitText -Arguments @("rev-parse", "--show-toplevel") -AllowFailure
    if ($rootResult.ExitCode -ne 0) {
        throw "The current path is not inside a Git repository."
    }
    $repositoryRoot = [IO.Path]::GetFullPath(($rootResult.Output | Select-Object -First 1).ToString().Trim())
    Set-Location -LiteralPath $repositoryRoot

    $changes = Get-ChangedFiles
    Write-Output "[AER Research Close Validation]"
    Write-Output ""
    Write-Output "Mode: $Mode"
    Write-Output "Repository: $repositoryRoot"
    Write-Output "Changed files: $($changes.Paths.Count)"
    Write-Output ""
    Write-Result PASS "Git repository detected"
    foreach ($path in $changes.Paths) { Write-Result INFO "Changed file: $path" }
    Write-Output ""

    Test-ExpectedFiles -ChangedFiles $changes.Paths -Expected $ExpectedFiles
    Test-ClosureFileCount -Count $changes.Paths.Count -ClosureMode $Mode
    Test-ProtectedFiles -ChangedFiles $changes.Paths -ClosureMode $Mode -AllowProtected $AllowProtectedFiles.IsPresent
    Test-FileSizes -ChangedFiles $changes.Paths -DeletedFiles $changes.Deleted -Root $repositoryRoot
    Test-MarkdownIntegrity -ChangedFiles $changes.Paths -DeletedFiles $changes.Deleted -Root $repositoryRoot
    Test-GitDiffChecks
    Test-InternalIds -ChangedFiles $changes.Paths -DeletedFiles $changes.Deleted -Root $repositoryRoot
    Test-RepositoryReferences -ChangedFiles $changes.Paths -DeletedFiles $changes.Deleted -Root $repositoryRoot
    Test-DeletedResearchObjects -DeletedFiles $changes.Deleted

    Write-Output ""
    Write-Output "Summary:"
    Write-Output "PASS: $script:PassCount"
    Write-Output "WARN: $script:WarnCount"
    Write-Output "FAIL: $script:FailCount"
    Write-Output ""
    if ($script:FailCount -gt 0) {
        Write-Output "Validation Result: FAILED"
        exit 1
    }
    Write-Output "Validation Result: PASSED"
    exit 0
}
catch {
    [Console]::Error.WriteLine("[AER Research Close Validation]")
    [Console]::Error.WriteLine("[FAIL] Script error: $($_.Exception.Message)")
    [Console]::Error.WriteLine("Validation Result: ERROR")
    exit 2
}
