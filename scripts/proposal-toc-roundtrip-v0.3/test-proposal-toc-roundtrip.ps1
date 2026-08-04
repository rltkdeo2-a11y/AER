[CmdletBinding()]
param(
    [string]$NodeExecutable = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'),
    [string]$NodeModulesPath = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\node_modules')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$fixtureV01 = Join-Path $repo '06_REASONING\contracts\proposal-toc-v0.1\case1-representative-state.json'
$fixtureV02 = Join-Path $repo '06_REASONING\contracts\proposal-toc-v0.2\case2-representative-state.json'
$fixtureV03 = Join-Path $repo '06_REASONING\contracts\proposal-toc-v0.3\case3-representative-state.json'
$node = (Resolve-Path -LiteralPath $NodeExecutable).Path
$modules = (Resolve-Path -LiteralPath $NodeModulesPath).Path
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar)
$tempDirectory = Join-Path $tempBase ("aer-toc-roundtrip-test-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempDirectory | Out-Null

try {
    New-Item -ItemType Junction -Path (Join-Path $tempDirectory 'node_modules') -Target $modules | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'aer-toc-roundtrip-engine.mjs') -Destination $tempDirectory
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'aer-toc-roundtrip-accept.mjs') -Destination $tempDirectory
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'test-proposal-toc-roundtrip.mjs') -Destination $tempDirectory
    & $node (Join-Path $tempDirectory 'test-proposal-toc-roundtrip.mjs') $fixtureV01 $fixtureV02 $fixtureV03 $tempDirectory
    if ($LASTEXITCODE -ne 0) {
        throw "Proposal TOC roundtrip test failed with exit code $LASTEXITCODE."
    }

    $collisionWorkbook = Join-Path $tempDirectory 'synthetic-v03-edited.xlsx'
    $collisionBaseline = Join-Path $tempDirectory 'v03-edited-baseline.json'
    $collisionHashBefore = (Get-FileHash -LiteralPath $collisionWorkbook -Algorithm SHA256).Hash
    $collisionRejected = $false
    try {
        & (Join-Path $PSScriptRoot 'invoke-proposal-toc-roundtrip.ps1') -WorkbookPath $collisionWorkbook -BaselinePath $collisionBaseline -ReportPath $collisionWorkbook -NodeExecutable $node -NodeModulesPath $modules
    }
    catch {
        $collisionRejected = $_.Exception.Message -like '*ReportPath must be different*'
    }
    if (-not $collisionRejected) {
        throw 'ASSERTION FAILED: report/input path collision was not rejected.'
    }
    $collisionHashAfter = (Get-FileHash -LiteralPath $collisionWorkbook -Algorithm SHA256).Hash
    if ($collisionHashBefore -cne $collisionHashAfter) {
        throw 'ASSERTION FAILED: collision rejection did not preserve the input workbook.'
    }
    Write-Output 'PASS: report/input path collision is rejected'

    $extensionRejected = $false
    try {
        & (Join-Path $PSScriptRoot 'invoke-proposal-toc-roundtrip.ps1') -WorkbookPath $collisionWorkbook -BaselinePath $collisionBaseline -ReportPath (Join-Path $tempDirectory 'invalid-report.txt') -NodeExecutable $node -NodeModulesPath $modules
    }
    catch {
        $extensionRejected = $_.Exception.Message -like '*must use the .json extension*'
    }
    if (-not $extensionRejected) {
        throw 'ASSERTION FAILED: non-JSON report extension was not rejected.'
    }
    if (@(Get-ChildItem -LiteralPath $tempDirectory -File -Filter '*.tmp').Count -ne 0) {
        throw 'ASSERTION FAILED: temporary report files remain after testing.'
    }
    Write-Output 'PASS: report extension and temporary-file cleanup are enforced'
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
