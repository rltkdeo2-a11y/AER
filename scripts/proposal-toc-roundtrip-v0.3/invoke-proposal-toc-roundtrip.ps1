[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$WorkbookPath,

    [Parameter(Mandatory = $true)]
    [string]$BaselinePath,

    [Parameter(Mandatory = $true)]
    [string]$ReportPath,

    [string]$NodeExecutable = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'),

    [string]$NodeModulesPath = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\node_modules')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$workbook = (Resolve-Path -LiteralPath $WorkbookPath).Path
$baseline = (Resolve-Path -LiteralPath $BaselinePath).Path
$node = (Resolve-Path -LiteralPath $NodeExecutable).Path
$modules = (Resolve-Path -LiteralPath $NodeModulesPath).Path
$report = [IO.Path]::GetFullPath($ReportPath)
$comparison = [StringComparison]::OrdinalIgnoreCase
if ($report.Equals($workbook, $comparison) -or $report.Equals($baseline, $comparison)) {
    throw 'ReportPath must be different from WorkbookPath and BaselinePath.'
}
if ([IO.Path]::GetExtension($report) -ine '.json') {
    throw 'ReportPath must use the .json extension.'
}
$reportDirectory = Split-Path -Parent $report
if (-not (Test-Path -LiteralPath $reportDirectory)) {
    New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
}

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar)
$tempDirectory = Join-Path $tempBase ("aer-toc-roundtrip-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempDirectory | Out-Null

try {
    New-Item -ItemType Junction -Path (Join-Path $tempDirectory 'node_modules') -Target $modules | Out-Null
    $engine = Join-Path $tempDirectory 'aer-toc-roundtrip-engine.mjs'
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'aer-toc-roundtrip-engine.mjs') -Destination $engine
    & $node $engine $workbook $baseline $report
    if ($LASTEXITCODE -ne 0) {
        throw "Proposal TOC roundtrip engine failed with exit code $LASTEXITCODE."
    }
}
finally {
    $resolvedTemp = [IO.Path]::GetFullPath($tempDirectory)
    if (-not $resolvedTemp.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove non-temporary path: $resolvedTemp"
    }
    if (Test-Path -LiteralPath $resolvedTemp) {
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
    }
}

Write-Output "PASS: report written to $report"
