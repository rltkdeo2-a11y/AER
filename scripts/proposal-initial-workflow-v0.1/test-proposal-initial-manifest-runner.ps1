[CmdletBinding()]
param(
    [string]$NodeExecutable = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'),
    [string]$NodeModulesPath = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\node_modules')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$fixture = Join-Path $repo '06_REASONING\contracts\proposal-toc-v0.3\case3-representative-state.json'
$node = (Resolve-Path -LiteralPath $NodeExecutable).Path
$modules = (Resolve-Path -LiteralPath $NodeModulesPath).Path
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar)
$tempDirectory = Join-Path $tempBase ("aer-proposal-manifest-runner-test-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempDirectory | Out-Null

try {
    New-Item -ItemType Junction -Path (Join-Path $tempDirectory 'node_modules') -Target $modules | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'proposal-initial-manifest-runner.mjs') -Destination $tempDirectory
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'test-proposal-initial-manifest-runner.mjs') -Destination $tempDirectory
    Copy-Item -LiteralPath (Join-Path $repo 'scripts\proposal-toc-roundtrip-v0.3\aer-toc-roundtrip-engine.mjs') -Destination $tempDirectory
    & $node (Join-Path $tempDirectory 'test-proposal-initial-manifest-runner.mjs') $fixture $tempDirectory $repo
    if ($LASTEXITCODE -ne 0) { throw "Proposal initial manifest runner test failed with exit code $LASTEXITCODE." }
}
finally {
    $resolvedTemp = [IO.Path]::GetFullPath($tempDirectory)
    if (-not $resolvedTemp.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove non-temporary path: $resolvedTemp"
    }
    if (Test-Path -LiteralPath $resolvedTemp) { Remove-Item -LiteralPath $resolvedTemp -Recurse -Force }
}
