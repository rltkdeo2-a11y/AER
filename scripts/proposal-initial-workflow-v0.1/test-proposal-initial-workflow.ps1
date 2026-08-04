[CmdletBinding()]
param(
    [string]$NodeExecutable = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$node = (Resolve-Path -LiteralPath $NodeExecutable).Path
& $node (Join-Path $PSScriptRoot 'test-proposal-initial-workflow.mjs')
if ($LASTEXITCODE -ne 0) { throw "Proposal initial workflow unit test failed with exit code $LASTEXITCODE." }

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar)
$tempDirectory = Join-Path $tempBase ("aer-proposal-initial-workflow-test-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempDirectory | Out-Null

try {
    $payload = Join-Path $tempDirectory 'start.json'
    $state = Join-Path $tempDirectory 'state-000.json'
    $source = Join-Path $tempDirectory 'rfp.pdf'
    [IO.File]::WriteAllBytes($source, [byte[]](1, 2, 3))
    [pscustomobject]@{ case_id = 'CASE-PS-TEST'; source_paths = @($source) } |
        ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $payload -Encoding UTF8
    & (Join-Path $PSScriptRoot 'invoke-proposal-initial-workflow.ps1') -Action Start -PayloadPath $payload -OutputStatePath $state -NodeExecutable $node
    if ($LASTEXITCODE -ne 0) { throw 'PowerShell entry-point Start failed.' }
    $result = Get-Content -LiteralPath $state -Encoding UTF8 -Raw | ConvertFrom-Json
    if ($result.stage -ne 'SOURCE_INTAKE' -or $result.rpa_release -ne 'HOLD') { throw 'PowerShell entry-point state assertion failed.' }

    $collisionRejected = $false
    try {
        & (Join-Path $PSScriptRoot 'invoke-proposal-initial-workflow.ps1') -Action Start -PayloadPath $payload -OutputStatePath $payload -NodeExecutable $node
    }
    catch {
        $collisionRejected = $_.Exception.Message -like '*distinct from PayloadPath*'
    }
    if (-not $collisionRejected) { throw 'PowerShell entry point did not reject payload/output collision.' }
}
finally {
    $resolved = [IO.Path]::GetFullPath($tempDirectory)
    if (-not $resolved.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove non-temporary path: $resolved"
    }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}

Write-Output 'PASS: Proposal initial workflow PowerShell entry point'
