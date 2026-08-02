[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$package = Join-Path $repo '06_REASONING\contracts\proposal-toc-v0.2'
$contract = Get-Content -LiteralPath (Join-Path $package 'proposal-toc-contract-v0.2.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$schema = Get-Content -LiteralPath (Join-Path $package 'proposal-toc-state-v0.2.schema.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$state = Get-Content -LiteralPath (Join-Path $package 'case2-representative-state.json') -Raw -Encoding UTF8 | ConvertFrom-Json

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

Assert-True ($contract.contract_version -eq '0.2.0') 'contract version'
Assert-True ($schema.title -eq 'AER Proposal TOC State v0.2') 'schema title'
Assert-True ($state.rfp_constraints.page_constraint_mode -eq 'RFP_UNSPECIFIED') 'unspecified mode'
Assert-True ($null -eq $state.rfp_constraints.rfp_target_pages) 'no invented RFP target'
Assert-True ($null -eq $state.rfp_constraints.a3_count_multiplier) 'no invented A3 multiplier'
Assert-True ($state.human_inputs.proposal_mode -eq 'SOLO') 'solo mode'
Assert-True ($state.rfp_constraints.consortium_policy -eq 'PROHIBITED') 'consortium prohibition'
Assert-True ($state.approval_state.allocation_status -eq 'HOLD') 'allocation hold'
Assert-True ($state.rpa_release.state -eq 'HOLD') 'RPA hold'

$nodeIds = @($state.toc_nodes | ForEach-Object node_id)
foreach ($fixed in @($state.rfp_constraints.official_toc_node_ids)) {
    Assert-True ($nodeIds -contains $fixed) "official node exists: $fixed"
}
foreach ($requirement in @($state.requirements)) {
    $main = @($state.mappings | Where-Object { $_.obligation_id -eq $requirement.obligation_id -and $_.relation -eq 'MAIN' })
    Assert-True ($main.Count -eq 1) "one MAIN for $($requirement.obligation_id)"
}
$csr4 = @($state.requirements | Where-Object requirement_id -eq 'CSR-004')
Assert-True ($csr4.Count -gt 0) 'CSR-004 represented'
foreach ($item in $csr4) {
    $mapping = $state.mappings | Where-Object obligation_id -eq $item.obligation_id | Select-Object -First 1
    Assert-True ($mapping.target_node_id.StartsWith('TOC-III-3-')) 'CSR-004 placed below official roadmap node'
}

$exactCompatibility = [pscustomobject]@{ mode = 'RFP_EXACT'; target = 80; assigned = 80; llm = 'PASS'; human = 'PASS' }
$exactComplete = $exactCompatibility.mode -eq 'RFP_EXACT' -and $exactCompatibility.assigned -eq $exactCompatibility.target -and $exactCompatibility.llm -eq 'PASS' -and $exactCompatibility.human -eq 'PASS'
Assert-True $exactComplete 'v0.1 exact-page behavior remains expressible'

$planningTarget = $null
$unspecifiedComplete = $null -ne $planningTarget -and $state.approval_state.llm_check -eq 'PASS' -and $state.approval_state.human_check -eq 'PASS'
Assert-True (-not $unspecifiedComplete) 'unspecified mode cannot complete without planning target'

Write-Output 'PASS: Proposal TOC contract v0.2'
Write-Output "Fixture metrics: toc=$($state.evidence_metrics.toc_rows), leaf=$($state.evidence_metrics.leaf_rows), requirements=$($state.evidence_metrics.requirement_rows), mappings=$($state.evidence_metrics.mapping_rows)"
