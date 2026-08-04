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

    $analysis = Join-Path $tempDirectory 'analysis.json'
    $summary = Join-Path $tempDirectory 'summary.md'
    $proof = Join-Path $tempDirectory 'analysis-proof.json'
    $registerPayload = Join-Path $tempDirectory 'register-analysis.json'
    $summaryState = Join-Path $tempDirectory 'state-001.json'
    Set-Content -LiteralPath $analysis -Value '{"analysis":"synthetic"}' -Encoding UTF8
    Set-Content -LiteralPath $summary -Value '# Synthetic summary' -Encoding UTF8
    $proofObject = [ordered]@{
        proof_contract_version = '0.1.0'
        artifact_type = 'RFP_ANALYSIS'
        case_id = 'CASE-PS-TEST'
        source_inputs = @([ordered]@{ path = $source; sha256 = (Get-FileHash -Algorithm SHA256 $source).Hash })
        authority = [ordered]@{ digest = 'authority-digest'; repository_head = 'repository-head'; runtime = 'AER_CORE' }
        runtime_selection = [ordered]@{ core_required = $true; reason = 'material judgment' }
        core_evidence = [ordered]@{
            problem_definition_present = $true
            facts_assumptions_unknowns_separated = $true
            reasoning_links_present = $true
            bottleneck_six_fields_present = $true
            solution_hypothesis_present = $true
            direct_validation = 'PASS_CONDITIONAL'
            opposing_review = 'REVIEWED'
            whole_process_impact = 'REVIEWED'
            global_consistency = 'PASS_CONDITIONAL'
            closure_outcome = 'PASS_CONDITIONAL'
        }
        outputs = @(
            [ordered]@{ path = $analysis; sha256 = (Get-FileHash -Algorithm SHA256 $analysis).Hash },
            [ordered]@{ path = $summary; sha256 = (Get-FileHash -Algorithm SHA256 $summary).Hash }
        )
    }
    $proofObject | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $proof -Encoding UTF8
    [ordered]@{ analysis_report_path = $analysis; summary_report_path = $summary; semantic_evidence_path = $proof } |
        ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $registerPayload -Encoding UTF8
    & (Join-Path $PSScriptRoot 'invoke-proposal-initial-workflow.ps1') -Action RegisterAnalysis -StatePath $state -PayloadPath $registerPayload -OutputStatePath $summaryState -NodeExecutable $node
    if ($LASTEXITCODE -ne 0) { throw 'PowerShell entry-point RegisterAnalysis failed.' }
    $registered = Get-Content -LiteralPath $summaryState -Encoding UTF8 -Raw | ConvertFrom-Json
    if ($registered.stage -ne 'SUMMARY_CONFIRMATION' -or $registered.semantic_execution.analysis.runtime -ne 'AER_CORE') {
        throw 'PowerShell entry-point RegisterAnalysis semantic evidence assertion failed.'
    }

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
