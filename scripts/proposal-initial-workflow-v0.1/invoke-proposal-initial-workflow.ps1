[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Start','RegisterAnalysis','ConfirmSummary','RecordFoundationInput','RegisterTocDraft','AnalyzeTocReturn','AcceptTocReturn','RegisterStrategyCandidates','ConfirmStrategySelection','AddExternalInformation','AuthorizeRegeneration')]
    [string]$Action,

    [string]$StatePath,

    [Parameter(Mandatory = $true)]
    [string]$PayloadPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputStatePath,

    [string]$NodeExecutable = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$node = (Resolve-Path -LiteralPath $NodeExecutable).Path
$payload = (Resolve-Path -LiteralPath $PayloadPath).Path
$output = [IO.Path]::GetFullPath($OutputStatePath)
$engine = Join-Path $PSScriptRoot 'proposal-initial-workflow.mjs'
$roundtripRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'proposal-toc-roundtrip-v0.3'

if ([IO.Path]::GetExtension($output) -ine '.json') { throw 'OutputStatePath must use the .json extension.' }
if ($output.Equals($payload, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputStatePath must be distinct from PayloadPath.' }
if ($Action -eq 'Start') {
    if (-not [string]::IsNullOrWhiteSpace($StatePath)) { throw 'Start does not accept StatePath.' }
    $state = '-'
}
else {
    if ([string]::IsNullOrWhiteSpace($StatePath)) { throw "$Action requires StatePath." }
    $state = (Resolve-Path -LiteralPath $StatePath).Path
    if ($state.Equals($output, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputStatePath must be distinct from StatePath.' }
}

$payloadObject = Get-Content -LiteralPath $payload -Encoding UTF8 -Raw | ConvertFrom-Json
$engineAction = @{
    Start = 'START'
    RegisterAnalysis = 'REGISTER_ANALYSIS'
    ConfirmSummary = 'CONFIRM_SUMMARY'
    RecordFoundationInput = 'RECORD_FOUNDATION_INPUT'
    RegisterTocDraft = 'REGISTER_TOC_DRAFT'
    AnalyzeTocReturn = 'RECORD_TOC_ANALYSIS'
    AcceptTocReturn = 'RECORD_TOC_ACCEPTANCE'
    RegisterStrategyCandidates = 'REGISTER_STRATEGY_CANDIDATES'
    ConfirmStrategySelection = 'CONFIRM_STRATEGY_SELECTION'
    AddExternalInformation = 'ADD_EXTERNAL_INFORMATION'
    AuthorizeRegeneration = 'AUTHORIZE_REGENERATION'
}[$Action]
$temporaryPayload = $null

function Resolve-RequiredArtifact {
    param([Parameter(Mandatory = $true)][string]$ArtifactPath, [Parameter(Mandatory = $true)][string]$Name)
    if ([string]::IsNullOrWhiteSpace($ArtifactPath)) { throw "$Name is required." }
    return (Resolve-Path -LiteralPath $ArtifactPath).Path
}

function Assert-OutputDoesNotCollide {
    param([string[]]$Paths)
    foreach ($candidate in @($Paths)) {
        if (-not [string]::IsNullOrWhiteSpace($candidate)) {
            $full = [IO.Path]::GetFullPath($candidate)
            if ($output.Equals($full, [StringComparison]::OrdinalIgnoreCase)) {
                throw "OutputStatePath collides with another workflow artifact: $full"
            }
        }
    }
}

try {
    if ($Action -eq 'Start') {
        foreach ($source in @($payloadObject.source_paths)) { [void](Resolve-RequiredArtifact -ArtifactPath $source -Name 'source_paths item') }
    }
    elseif ($Action -eq 'RegisterAnalysis') {
        $analysisPath = Resolve-RequiredArtifact -ArtifactPath $payloadObject.analysis_report_path -Name 'analysis_report_path'
        $summaryPath = Resolve-RequiredArtifact -ArtifactPath $payloadObject.summary_report_path -Name 'summary_report_path'
        $evidencePath = Resolve-RequiredArtifact -ArtifactPath $payloadObject.semantic_evidence_path -Name 'semantic_evidence_path'
        Assert-OutputDoesNotCollide -Paths @($analysisPath, $summaryPath, $evidencePath)
    }
    elseif ($Action -eq 'RegisterTocDraft') {
        $baselinePath = Resolve-RequiredArtifact -ArtifactPath $payloadObject.baseline_state_path -Name 'baseline_state_path'
        $workbookPath = Resolve-RequiredArtifact -ArtifactPath $payloadObject.workbook_path -Name 'workbook_path'
        Assert-OutputDoesNotCollide -Paths @($baselinePath, $workbookPath)
    }
    elseif ($Action -eq 'RegisterStrategyCandidates') {
        $strategyPath = Resolve-RequiredArtifact -ArtifactPath $payloadObject.strategy_candidates_path -Name 'strategy_candidates_path'
        $evidencePath = Resolve-RequiredArtifact -ArtifactPath $payloadObject.semantic_evidence_path -Name 'semantic_evidence_path'
        Assert-OutputDoesNotCollide -Paths @($strategyPath, $evidencePath)
    }
    elseif ($Action -eq 'AddExternalInformation') {
        $externalPath = Resolve-RequiredArtifact -ArtifactPath $payloadObject.source_path -Name 'source_path'
        Assert-OutputDoesNotCollide -Paths @($externalPath)
    }

    if ($Action -eq 'AnalyzeTocReturn') {
        $current = Get-Content -LiteralPath $state -Encoding UTF8 -Raw | ConvertFrom-Json
        if ($current.stage -ne 'TOC_HUMAN_EDIT') { throw 'AnalyzeTocReturn requires TOC_HUMAN_EDIT stage.' }
        $workbook = (Resolve-Path -LiteralPath $payloadObject.returned_workbook_path).Path
        $baseline = (Resolve-Path -LiteralPath $current.artifacts.toc_baseline_state_path).Path
        $report = [IO.Path]::GetFullPath($payloadObject.report_path)
        Assert-OutputDoesNotCollide -Paths @($workbook, $baseline, $report)
        & (Join-Path $roundtripRoot 'invoke-proposal-toc-roundtrip.ps1') -WorkbookPath $workbook -BaselinePath $baseline -ReportPath $report -NodeExecutable $node
        if ($LASTEXITCODE -ne 0) { throw 'TOC roundtrip analysis failed.' }
        $reportObject = Get-Content -LiteralPath $report -Encoding UTF8 -Raw | ConvertFrom-Json
        $temporaryPayload = Join-Path ([IO.Path]::GetTempPath()) ("aer-piw-analysis-" + [Guid]::NewGuid().ToString('N') + '.json')
        [pscustomobject]@{
            returned_workbook_path = $workbook
            report_path = $report
            report = $reportObject
        } | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $temporaryPayload -Encoding UTF8
        $payload = $temporaryPayload
    }
    elseif ($Action -eq 'AcceptTocReturn') {
        $current = Get-Content -LiteralPath $state -Encoding UTF8 -Raw | ConvertFrom-Json
        if ($current.stage -ne 'TOC_REIMPORT') { throw 'AcceptTocReturn requires TOC_REIMPORT stage.' }
        $workbook = (Resolve-Path -LiteralPath $current.artifacts.returned_workbook_path).Path
        $baseline = (Resolve-Path -LiteralPath $current.artifacts.toc_baseline_state_path).Path
        Assert-OutputDoesNotCollide -Paths @($workbook, $baseline, $payloadObject.decisions_path, $payloadObject.accepted_workbook_path, $payloadObject.accepted_state_path, $payloadObject.verification_report_path, $payloadObject.acceptance_receipt_path)
        & (Join-Path $roundtripRoot 'invoke-proposal-toc-roundtrip-accept.ps1') `
            -WorkbookPath $workbook `
            -BaselinePath $baseline `
            -DecisionsPath $payloadObject.decisions_path `
            -AcceptedWorkbookPath $payloadObject.accepted_workbook_path `
            -AcceptedStatePath $payloadObject.accepted_state_path `
            -VerificationReportPath $payloadObject.verification_report_path `
            -AcceptanceReceiptPath $payloadObject.acceptance_receipt_path `
            -NodeExecutable $node
        if ($LASTEXITCODE -ne 0) { throw 'TOC acceptance failed.' }
        $verification = Get-Content -LiteralPath $payloadObject.verification_report_path -Encoding UTF8 -Raw | ConvertFrom-Json
        $receipt = Get-Content -LiteralPath $payloadObject.acceptance_receipt_path -Encoding UTF8 -Raw | ConvertFrom-Json
        $temporaryPayload = Join-Path ([IO.Path]::GetTempPath()) ("aer-piw-accept-" + [Guid]::NewGuid().ToString('N') + '.json')
        [pscustomobject]@{
            accepted_workbook_path = [IO.Path]::GetFullPath($payloadObject.accepted_workbook_path)
            accepted_state_path = [IO.Path]::GetFullPath($payloadObject.accepted_state_path)
            verification_report_path = [IO.Path]::GetFullPath($payloadObject.verification_report_path)
            decisions_path = [IO.Path]::GetFullPath($payloadObject.decisions_path)
            acceptance_receipt_path = [IO.Path]::GetFullPath($payloadObject.acceptance_receipt_path)
            verification = $verification
            receipt = $receipt
        } | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $temporaryPayload -Encoding UTF8
        $payload = $temporaryPayload
    }

    & $node $engine $engineAction $state $payload $output
    if ($LASTEXITCODE -ne 0) { throw "Proposal initial workflow failed with exit code $LASTEXITCODE." }
}
finally {
    if ($temporaryPayload -and (Test-Path -LiteralPath $temporaryPayload)) {
        $tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
        $resolved = [IO.Path]::GetFullPath($temporaryPayload)
        if (-not $resolved.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove non-temporary path: $resolved" }
        Remove-Item -LiteralPath $resolved -Force
    }
}

Write-Output "PASS: workflow state written to $output"
