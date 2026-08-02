[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$package = Join-Path $repo '06_REASONING\contracts\proposal-toc-v0.3'
$contract = Get-Content -LiteralPath (Join-Path $package 'proposal-toc-contract-v0.3.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$schema = Get-Content -LiteralPath (Join-Path $package 'proposal-toc-state-v0.3.schema.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$state = Get-Content -LiteralPath (Join-Path $package 'case3-representative-state.json') -Raw -Encoding UTF8 | ConvertFrom-Json

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

Assert-True ($contract.contract_version -eq '0.3.0') 'contract version'
Assert-True ($schema.title -eq 'AER Proposal TOC State v0.3') 'schema title'
Assert-True ($state.evidence_metrics.requirement_groups_observed -eq 110) 'observed requirement groups'
Assert-True ($state.evidence_metrics.official_fixed_nodes -eq 45) 'observed official nodes'

$budgets = @($state.rfp_constraints.page_budgets)
$v1 = $budgets | Where-Object page_budget_id -eq 'PB-V1-MAIN'
$appendix = $budgets | Where-Object page_budget_id -eq 'PB-V1-APPENDIX'
$v2 = $budgets | Where-Object page_budget_id -eq 'PB-V2-MAIN'
Assert-True ($v1.mode -eq 'RFP_EXACT' -and $v1.target_pages -eq 100) 'Volume 1 exact budget'
Assert-True ($appendix.mode -eq 'RFP_UNLIMITED' -and $null -eq $appendix.target_pages) 'unlimited appendix budget'
Assert-True ($v2.mode -eq 'RFP_EXACT' -and $v2.target_pages -eq 300) 'Volume 2 exact budget'

$delegations = @($state.source_relationships | ForEach-Object relation)
Assert-True ($delegations -contains 'DELEGATES_REQUIREMENT_DETAIL') 'task-spec delegation'
Assert-True ($delegations -contains 'DELEGATES_CONSORTIUM_POLICY') 'bid-notice delegation'
$notice = $state.source_registry | Where-Object source_type -eq 'BID_NOTICE'
Assert-True ($notice.status -eq 'MISSING') 'missing delegated bid notice remains explicit'
Assert-True ($state.human_inputs.proposal_mode -eq 'UNSPECIFIED') 'proposal mode not inferred'

foreach ($requirement in @($state.requirements)) {
    $main = @($state.mappings | Where-Object { $_.obligation_id -eq $requirement.obligation_id -and $_.relation -eq 'MAIN' })
    Assert-True ($main.Count -eq 1) "one MAIN for $($requirement.obligation_id)"
}
$anon = $state.content_policies | Where-Object type -eq 'FORBIDDEN_IDENTITY'
$a3 = $state.content_policies | Where-Object type -eq 'FORMAT_PROHIBITED'
Assert-True ($anon.scope_volume_id -eq 'VOL-2') 'Volume 2 anonymity scope'
Assert-True ($null -eq $state.rfp_constraints.a3_count_multiplier -and $null -ne $a3) 'A3 is prohibited rather than multiplied'
Assert-True ($state.rpa_release.state -eq 'HOLD') 'RPA hold'

$exactCompatibility = [pscustomobject]@{ mode = 'RFP_EXACT'; target = 80; assigned = 80 }
Assert-True ($exactCompatibility.mode -eq 'RFP_EXACT' -and $exactCompatibility.assigned -eq $exactCompatibility.target) 'v0.1 exact-page behavior remains expressible'
$unspecifiedCompatibility = [pscustomobject]@{ mode = 'RFP_UNSPECIFIED'; target = $null }
Assert-True ($unspecifiedCompatibility.mode -eq 'RFP_UNSPECIFIED' -and $null -eq $unspecifiedCompatibility.target) 'v0.2 unspecified-page behavior remains expressible'

Write-Output 'PASS: Proposal TOC contract v0.3'
Write-Output "Fixture evidence: fixed=$($state.evidence_metrics.official_fixed_nodes), groups=$($state.evidence_metrics.requirement_groups_observed), obligations=$($state.evidence_metrics.full_atomic_obligations)"
