[CmdletBinding()]
param(
    [string]$StatePath,
    [string]$ContractPath,
    [string]$SchemaPath,
    [ValidateSet("Validate", "Compare", "All")]
    [string]$Mode = "All"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:PassCount = 0
$script:FailCount = 0

function Write-TestResult {
    param(
        [ValidateSet("PASS", "FAIL")][string]$Level,
        [string]$Message
    )
    if ($Level -eq "PASS") { $script:PassCount++ } else { $script:FailCount++ }
    Write-Output ("[{0}] {1}" -f $Level, $Message)
}

function Read-JsonFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "JSON file not found: $Path"
    }
    return (Get-Content -Raw -LiteralPath $Path -Encoding UTF8 | ConvertFrom-Json)
}

function ConvertTo-Clone {
    param($Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Test-UniqueValues {
    param([object[]]$Items, [string]$PropertyName, [string]$Label)
    $seen = @{}
    $errors = New-Object 'Collections.Generic.List[string]'
    foreach ($item in @($Items)) {
        $value = [string]$item.$PropertyName
        if ([string]::IsNullOrWhiteSpace($value)) {
            [void]$errors.Add("$Label has an empty $PropertyName")
        }
        elseif ($seen.ContainsKey($value)) {
            [void]$errors.Add("$Label has duplicate $PropertyName '$value'")
        }
        else {
            $seen[$value] = $true
        }
    }
    return @($errors | ForEach-Object { $_ })
}

function Test-ArrayEqual {
    param([object[]]$Left, [object[]]$Right)
    $leftText = (@($Left) | ForEach-Object { [string]$_ } | Sort-Object) -join "|"
    $rightText = (@($Right) | ForEach-Object { [string]$_ } | Sort-Object) -join "|"
    return $leftText -ceq $rightText
}

function Get-NodeChanges {
    param($State)
    $changes = New-Object 'Collections.Generic.List[object]'
    $currentById = @{}
    $baselineById = @{}
    foreach ($node in @($State.toc_nodes)) { $currentById[[string]$node.node_id] = $node }
    foreach ($node in @($State.baseline_snapshot)) { $baselineById[[string]$node.node_id] = $node }

    foreach ($baseline in @($State.baseline_snapshot)) {
        $id = [string]$baseline.node_id
        if (-not $currentById.ContainsKey($id)) {
            [void]$changes.Add([pscustomobject]@{ node_id = $id; change_type = "DELETED"; impact = "STRUCTURAL" })
            continue
        }

        $current = $currentById[$id]
        $changeType = "UNCHANGED"
        $impact = "LOCAL"
        if (($baseline.official_fixed -eq $true) -and (($current.level -ne $baseline.level) -or ([string]$current.parent_id -cne [string]$baseline.parent_id))) {
            $changeType = "OFFICIAL_STRUCTURE_BLOCK"; $impact = "STRUCTURAL"
        }
        elseif ($current.level -ne $baseline.level) {
            $changeType = "LEVEL_CHANGED"; $impact = "STRUCTURAL"
        }
        elseif ([string]$current.parent_id -cne [string]$baseline.parent_id) {
            $changeType = "REPARENTED"; $impact = "STRUCTURAL"
        }
        elseif ($current.a3_checked -ne $baseline.a3_checked) {
            $changeType = "FORMAT_CHANGED"; $impact = "REVIEW"
        }
        elseif ($current.physical_sheets -ne $baseline.physical_sheets) {
            $changeType = "PAGE_CHANGED"; $impact = "REVIEW"
        }
        elseif (-not (Test-ArrayEqual -Left @($current.requirement_ids) -Right @($baseline.requirement_ids))) {
            $changeType = "REQUIREMENT_CHANGED"; $impact = "REVIEW"
        }
        elseif ([string]$current.title -cne [string]$baseline.title) {
            $changeType = "RENAMED"; $impact = "REVIEW"
        }
        [void]$changes.Add([pscustomobject]@{ node_id = $id; change_type = $changeType; impact = $impact })
    }

    foreach ($current in @($State.toc_nodes)) {
        $id = [string]$current.node_id
        if (-not $baselineById.ContainsKey($id)) {
            [void]$changes.Add([pscustomobject]@{ node_id = $id; change_type = "NEW"; impact = "STRUCTURAL" })
        }
    }
    return @($changes | ForEach-Object { $_ })
}

function Get-StateErrors {
    param($State, $Contract)
    $errors = New-Object 'Collections.Generic.List[string]'
    $required = @(
        "contract_version", "case_id", "fixture_scope", "source_registry", "human_inputs",
        "rfp_constraints", "toc_nodes", "requirements", "mappings", "baseline_snapshot",
        "approval_state", "rpa_release"
    )
    $names = @($State.PSObject.Properties.Name)
    foreach ($name in $required) {
        if ($names -notcontains $name) { [void]$errors.Add("Missing top-level property '$name'") }
    }
    if ($errors.Count -gt 0) { return @($errors | ForEach-Object { $_ }) }

    if ([string]$State.contract_version -cne [string]$Contract.contract_version) {
        [void]$errors.Add("State contract_version does not match frozen contract version")
    }
    if ($State.rfp_constraints.page_rule -cne "EXACT") {
        [void]$errors.Add("Only EXACT page rule is valid in v0.1")
    }
    if ([int]$State.rfp_constraints.a3_multiplier -ne 2) {
        [void]$errors.Add("A3 multiplier must be 2")
    }

    foreach ($errorText in (Test-UniqueValues -Items @($State.source_registry) -PropertyName "source_id" -Label "source_registry")) { [void]$errors.Add($errorText) }
    foreach ($errorText in (Test-UniqueValues -Items @($State.toc_nodes) -PropertyName "node_id" -Label "toc_nodes")) { [void]$errors.Add($errorText) }
    foreach ($errorText in (Test-UniqueValues -Items @($State.requirements) -PropertyName "obligation_id" -Label "requirements")) { [void]$errors.Add($errorText) }
    foreach ($errorText in (Test-UniqueValues -Items @($State.mappings) -PropertyName "map_id" -Label "mappings")) { [void]$errors.Add($errorText) }
    foreach ($errorText in (Test-UniqueValues -Items @($State.baseline_snapshot) -PropertyName "node_id" -Label "baseline_snapshot")) { [void]$errors.Add($errorText) }

    $nodeById = @{}
    foreach ($node in @($State.toc_nodes)) { $nodeById[[string]$node.node_id] = $node }
    foreach ($node in @($State.toc_nodes)) {
        if ($node.level -lt 1 -or $node.level -gt 4) {
            [void]$errors.Add("Node '$($node.node_id)' has invalid level")
        }
        if ($node.level -gt 1) {
            $parentId = [string]$node.parent_id
            if ([string]::IsNullOrWhiteSpace($parentId) -or -not $nodeById.ContainsKey($parentId)) {
                [void]$errors.Add("Node '$($node.node_id)' has no valid parent")
            }
            elseif ([int]$node.level -ne ([int]$nodeById[$parentId].level + 1)) {
                [void]$errors.Add("Node '$($node.node_id)' level does not follow its parent")
            }
        }
        if ($node.leaf -eq $true) {
            if ($null -eq $node.physical_sheets -or $null -eq $node.counted_pages) {
                [void]$errors.Add("Leaf '$($node.node_id)' is missing page values")
            }
            else {
                $multiplier = if ($node.a3_checked -eq $true) { 2 } else { 1 }
                if ([int]$node.counted_pages -ne ([int]$node.physical_sheets * $multiplier)) {
                    [void]$errors.Add("Leaf '$($node.node_id)' violates the A3 page rule")
                }
            }
        }
    }

    $leafTotal = 0
    foreach ($node in @($State.toc_nodes | Where-Object { $_.leaf -eq $true })) { $leafTotal += [int]$node.counted_pages }
    if ($leafTotal -ne [int]$State.rfp_constraints.target_pages) {
        [void]$errors.Add("Leaf counted page total '$leafTotal' does not equal target '$($State.rfp_constraints.target_pages)'")
    }

    $obligationById = @{}
    foreach ($requirement in @($State.requirements)) { $obligationById[[string]$requirement.obligation_id] = $requirement }
    foreach ($mapping in @($State.mappings)) {
        if (-not $nodeById.ContainsKey([string]$mapping.target_node_id)) {
            [void]$errors.Add("Mapping '$($mapping.map_id)' targets an unknown node")
        }
        if (-not $obligationById.ContainsKey([string]$mapping.obligation_id)) {
            [void]$errors.Add("Mapping '$($mapping.map_id)' references an unknown obligation")
        }
    }
    foreach ($requirement in @($State.requirements | Where-Object { $_.destination -ne "CONTROL" })) {
        $mainCount = @($State.mappings | Where-Object { $_.obligation_id -eq $requirement.obligation_id -and $_.relation -eq "MAIN" }).Count
        if ($mainCount -ne 1) {
            [void]$errors.Add("Obligation '$($requirement.obligation_id)' has '$mainCount' MAIN mappings; expected 1")
        }
    }

    foreach ($change in (Get-NodeChanges -State $State)) {
        if ($change.change_type -eq "OFFICIAL_STRUCTURE_BLOCK") {
            [void]$errors.Add("RFP-fixed node '$($change.node_id)' changed parent or level")
        }
    }

    if ($State.human_inputs.proposal_mode -eq "CONSORTIUM" -and $State.rfp_constraints.consortium_policy -eq "PROHIBITED") {
        if ($State.approval_state.blocking_conflicts.Count -eq 0) {
            [void]$errors.Add("Prohibited consortium condition is not recorded as a blocking conflict")
        }
    }

    if ($State.rpa_release.explicit_release_required -ne $true) {
        [void]$errors.Add("RPA release must require an explicit command")
    }
    if ($State.rpa_release.state -eq "RELEASED") {
        if ($State.approval_state.llm_check -ne "PASS" -or $State.approval_state.human_check -ne "PASS" -or $State.approval_state.allocation_status -ne "COMPLETE" -or $State.approval_state.blocking_conflicts.Count -gt 0) {
            [void]$errors.Add("RPA is RELEASED without all release gates passing")
        }
        if ([string]::IsNullOrWhiteSpace([string]$State.rpa_release.released_by) -or [string]::IsNullOrWhiteSpace([string]$State.rpa_release.released_at)) {
            [void]$errors.Add("RPA release lacks actor or timestamp")
        }
    }
    return @($errors | ForEach-Object { $_ })
}

try {
    $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repositoryRoot = [IO.Path]::GetFullPath((Join-Path $scriptRoot "..\.."))
    if ([string]::IsNullOrWhiteSpace($StatePath)) { $StatePath = Join-Path $repositoryRoot "06_REASONING\contracts\proposal-toc-v0.1\case1-representative-state.json" }
    if ([string]::IsNullOrWhiteSpace($ContractPath)) { $ContractPath = Join-Path $repositoryRoot "06_REASONING\contracts\proposal-toc-v0.1\proposal-toc-contract-v0.1.json" }
    if ([string]::IsNullOrWhiteSpace($SchemaPath)) { $SchemaPath = Join-Path $repositoryRoot "06_REASONING\contracts\proposal-toc-v0.1\proposal-toc-state-v0.1.schema.json" }

    $state = Read-JsonFile -Path $StatePath
    $contract = Read-JsonFile -Path $ContractPath
    $null = Read-JsonFile -Path $SchemaPath
    Write-TestResult PASS "Contract, schema, and state JSON parse successfully"

    if ($Mode -in @("Validate", "All")) {
        $errors = @(Get-StateErrors -State $state -Contract $contract)
        if ($errors.Count -eq 0) {
            Write-TestResult PASS "Case 1 representative state satisfies v0.1 semantic invariants"
        }
        else {
            foreach ($errorText in $errors) { Write-TestResult FAIL $errorText }
        }
    }

    if ($Mode -in @("Compare", "All")) {
        $changes = @(Get-NodeChanges -State $state)
        $a3Change = @($changes | Where-Object { $_.node_id -eq "TOC-III-1-A" -and $_.change_type -eq "FORMAT_CHANGED" -and $_.impact -eq "REVIEW" })
        if ($a3Change.Count -eq 1) { Write-TestResult PASS "A3 edit is classified as FORMAT_CHANGED and REVIEW" } else { Write-TestResult FAIL "A3 edit classification regression" }

        $ownerVariant = ConvertTo-Clone -Value $state
        ($ownerVariant.toc_nodes | Where-Object { $_.node_id -eq "TOC-III-1-A" }).owner_no_llm = "PM-CHANGED"
        $ownerChanges = @(Get-NodeChanges -State $ownerVariant | ForEach-Object { "$($_.node_id):$($_.change_type):$($_.impact)" } | Sort-Object)
        $baseChanges = @($changes | ForEach-Object { "$($_.node_id):$($_.change_type):$($_.impact)" } | Sort-Object)
        if ((Test-ArrayEqual -Left $ownerChanges -Right $baseChanges)) { Write-TestResult PASS "Owner-only edit is excluded from LLM impact" } else { Write-TestResult FAIL "Owner-only edit changed LLM impact" }

        $newRowVariant = ConvertTo-Clone -Value $state
        $newNode = ConvertTo-Clone -Value $newRowVariant.toc_nodes[2]
        $newNode.node_id = "NEW-PROVISIONAL-001"
        $newNode.title = "Human Added Detail"
        $newNode.origin = "HUMAN_ADDED"
        $newNode.a3_checked = $false
        $newNode.physical_sheets = 0
        $newNode.counted_pages = 0
        $newRowVariant.toc_nodes = @($newRowVariant.toc_nodes) + @($newNode)
        $newChange = @(Get-NodeChanges -State $newRowVariant | Where-Object { $_.node_id -eq "NEW-PROVISIONAL-001" -and $_.change_type -eq "NEW" -and $_.impact -eq "STRUCTURAL" })
        if ($newChange.Count -eq 1) { Write-TestResult PASS "Inserted row is normalized as NEW and STRUCTURAL" } else { Write-TestResult FAIL "Inserted-row classification regression" }

        $releaseVariant = ConvertTo-Clone -Value $state
        $releaseVariant.rpa_release.state = "RELEASED"
        $releaseErrors = @(Get-StateErrors -State $releaseVariant -Contract $contract)
        if (@($releaseErrors | Where-Object { $_ -like "RPA is RELEASED*" }).Count -eq 1) { Write-TestResult PASS "Premature RPA release is rejected" } else { Write-TestResult FAIL "Premature RPA release was not rejected" }

        Write-Output "[INFO] Derived changes"
        $changes | Sort-Object node_id | Format-Table node_id, change_type, impact -AutoSize | Out-String | Write-Output
    }

    Write-Output ("Summary: PASS={0} FAIL={1}" -f $script:PassCount, $script:FailCount)
    if ($script:FailCount -gt 0) { exit 1 }
    Write-Output "PROPOSAL_TOC_CONTRACT_V0_1_PASS"
    exit 0
}
catch {
    Write-TestResult FAIL $_.Exception.Message
    Write-Output $_.ScriptStackTrace
    Write-Output ("Summary: PASS={0} FAIL={1}" -f $script:PassCount, $script:FailCount)
    exit 2
}
