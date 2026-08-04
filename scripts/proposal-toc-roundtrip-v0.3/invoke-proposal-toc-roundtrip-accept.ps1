[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$WorkbookPath,
    [Parameter(Mandatory = $true)][string]$BaselinePath,
    [Parameter(Mandatory = $true)][string]$DecisionsPath,
    [Parameter(Mandatory = $true)][string]$AcceptedWorkbookPath,
    [Parameter(Mandatory = $true)][string]$AcceptedStatePath,
    [Parameter(Mandatory = $true)][string]$VerificationReportPath,
    [string]$NodeExecutable = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'),
    [string]$NodeModulesPath = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\node_modules')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$workbook = (Resolve-Path -LiteralPath $WorkbookPath).Path
$baseline = (Resolve-Path -LiteralPath $BaselinePath).Path
$decisions = (Resolve-Path -LiteralPath $DecisionsPath).Path
$node = (Resolve-Path -LiteralPath $NodeExecutable).Path
$modules = (Resolve-Path -LiteralPath $NodeModulesPath).Path
$acceptedWorkbook = [IO.Path]::GetFullPath($AcceptedWorkbookPath)
$acceptedState = [IO.Path]::GetFullPath($AcceptedStatePath)
$verificationReport = [IO.Path]::GetFullPath($VerificationReportPath)
$allPaths = @($workbook, $baseline, $decisions, $acceptedWorkbook, $acceptedState, $verificationReport)
$uniquePaths = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($item in $allPaths) {
    if (-not $uniquePaths.Add($item)) { throw 'All input and output paths must be distinct.' }
}
if ([IO.Path]::GetExtension($acceptedWorkbook) -ine '.xlsx') { throw 'AcceptedWorkbookPath must use the .xlsx extension.' }
foreach ($jsonPath in @($decisions, $acceptedState, $verificationReport)) {
    if ([IO.Path]::GetExtension($jsonPath) -ine '.json') { throw 'Decision, state, and report paths must use the .json extension.' }
}
foreach ($directory in @((Split-Path -Parent $acceptedWorkbook), (Split-Path -Parent $acceptedState), (Split-Path -Parent $verificationReport))) {
    if (-not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
}

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar)
$tempDirectory = Join-Path $tempBase ("aer-toc-roundtrip-accept-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempDirectory | Out-Null

try {
    New-Item -ItemType Junction -Path (Join-Path $tempDirectory 'node_modules') -Target $modules | Out-Null
    foreach ($name in @('aer-toc-roundtrip-engine.mjs', 'aer-toc-roundtrip-accept.mjs')) {
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination (Join-Path $tempDirectory $name)
    }
    & $node (Join-Path $tempDirectory 'aer-toc-roundtrip-accept.mjs') $workbook $baseline $decisions $acceptedWorkbook $acceptedState $verificationReport
    if ($LASTEXITCODE -ne 0) { throw "Proposal TOC acceptance engine failed with exit code $LASTEXITCODE." }
}
finally {
    $resolvedTemp = [IO.Path]::GetFullPath($tempDirectory)
    if (-not $resolvedTemp.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove non-temporary path: $resolvedTemp"
    }
    if (Test-Path -LiteralPath $resolvedTemp) { Remove-Item -LiteralPath $resolvedTemp -Recurse -Force }
}

Write-Output "PASS: accepted workbook written to $acceptedWorkbook"
Write-Output "PASS: accepted state written to $acceptedState"
Write-Output "PASS: verification report written to $verificationReport"
