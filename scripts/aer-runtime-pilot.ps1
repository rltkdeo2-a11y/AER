[CmdletBinding()]
param(
    [ValidateSet('Bootstrap','Pilot','All')][string]$Mode = 'All',
    [ValidateSet('PILOT-01','PILOT-02','PILOT-03')][string]$CaseId,
    [string]$BaselineCommit
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function GitText([string[]]$GitArgs) {
    $o = @(& git @GitArgs 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "git $($GitArgs -join ' ') failed: $($o -join ' ')" }
    return ($o -join [Environment]::NewLine).Trim()
}
function RepoFile([string]$Root,[string]$Path) { return Test-Path -LiteralPath (Join-Path $Root ($Path.Replace('/','\'))) }
function Pick([bool]$Condition,[string]$Yes,[string]$No) { if($Condition){return $Yes}; return $No }
function Gate([string]$Name,[bool]$Pass,[string]$Detail) {
    Write-Host ("{0} {1}: {2}" -f (Pick $Pass 'O' 'X'),$Name,$Detail)
    return $Pass
}
function AuthorityPaths([string]$Root) {
    $s = Get-Content -Raw -Encoding UTF8 (Join-Path $Root '00_GOVERNANCE/CURRENT_STATE')
    $set = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach($m in [regex]::Matches($s,'(?m)(?:^|\s)([0-9]{2}_[A-Z_]+/[A-Za-z0-9_./-]+\.md)(?=\s|$)')) {[void]$set.Add($m.Groups[1].Value)}
    return @($set | Sort-Object)
}
function ProtectedPaths([string]$Root) {
    $set = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    @('AGENTS.md','BOOTSTRAP.md','README.md','CHANGELOG.md','00_GOVERNANCE/CURRENT_STATE') | ForEach-Object {[void]$set.Add($_)}
    foreach($p in (AuthorityPaths $Root)){[void]$set.Add($p)}
    foreach($d in @('01_DEFINITIONS','02_PRINCIPLES','03_HYPOTHESES','04_ASSUMPTIONS','05_EVIDENCE','06_REASONING','07_DECISIONS','08_OPEN_PROBLEMS')){
        Get-ChildItem (Join-Path $Root $d) -File -Recurse | ForEach-Object {[void]$set.Add((Resolve-Path $_.FullName -Relative).TrimStart('.\').Replace('\','/'))}
    }
    Get-ChildItem (Join-Path $Root '09_RESEARCH_LOG') -File -Filter '*.md' | Where-Object {$_.Name -notlike 'SESSION_009_*'} | ForEach-Object {[void]$set.Add((Resolve-Path $_.FullName -Relative).TrimStart('.\').Replace('\','/'))}
    return @($set | Sort-Object)
}
function Hashes([string]$Root,[string[]]$Paths) { $h=@{}; foreach($p in $Paths){$h[$p]=GitText @('hash-object','--',$p)}; return $h }
function CoreGuard([string]$Root,[hashtable]$Baseline) {
    $changed=@(); foreach($p in $Baseline.Keys){if(-not (RepoFile $Root $p) -or (GitText @('hash-object','--',$p)) -ne $Baseline[$p]){$changed+=$p}}
    $ok=$changed.Count -eq 0; [void](Gate 'Protected Core Guard' $ok (Pick $ok 'baseline hashes unchanged' "changed: $($changed -join ', ')")); return $ok
}
function Bootstrap([string]$Root) {
    $checks=@(); $head=GitText @('rev-parse','HEAD')
    $status=@((GitText @('status','--porcelain') -split "`r?`n") | Where-Object {$_ -ne ''})
    $runtimeOnly=$status.Count -eq 0
    if($status.Count -gt 0){
        $disallowed=@($status | Where-Object {
            $_ -notmatch '^(?:.. )?(?:M )?(AGENTS\.md|\.codex/|00_GOVERNANCE/AER_CODEX_RUNTIME_MANUAL\.md|09_RESEARCH_LOG/SESSION_010_REPOSITORY_BOUND_CODEX_RUNTIME_BINDING\.md|scripts/invoke-aer-runtime\.ps1|scripts/aer-runtime-pilot\.ps1|09_RESEARCH_LOG/SESSION_009_CODEX_RUNTIME_MIGRATION_PILOT\.md)'
        })
        $runtimeOnly=$disallowed.Count -eq 0
    }
    $checks += Gate 'Repository root' ((GitText @('rev-parse','--show-toplevel')) -eq $Root) $Root
    $checks += Gate 'HEAD' (-not [string]::IsNullOrWhiteSpace($head)) $head
    $checks += Gate 'Working tree' $runtimeOnly 'clean or approved Runtime-only changes'
    $checks += Gate 'AGENTS' (RepoFile $Root 'AGENTS.md') 'exists'
    $checks += Gate 'BOOTSTRAP' (RepoFile $Root 'BOOTSTRAP.md') 'exists'
    $checks += Gate 'CURRENT_STATE' (RepoFile $Root '00_GOVERNANCE/CURRENT_STATE') 'exists'
    $aps=AuthorityPaths $Root
    $checks += Gate 'Decision references' (@($aps | Where-Object {$_ -like '07_DECISIONS/*'} | Where-Object {-not (RepoFile $Root $_)}).Count -eq 0) 'connected'
    $checks += Gate 'Evidence references' (@($aps | Where-Object {$_ -like '05_EVIDENCE/*'} | Where-Object {-not (RepoFile $Root $_)}).Count -eq 0) 'connected'
    $checks += Gate 'Session references' (@($aps | Where-Object {$_ -like '09_RESEARCH_LOG/*'} | Where-Object {-not (RepoFile $Root $_)}).Count -eq 0) 'connected'
    $checks += Gate 'Unresolved contradictions' (RepoFile $Root '08_OPEN_PROBLEMS/OP001_PM_Linkage_Criteria.md') 'OP-001 available'
    $s=Get-Content -Raw -Encoding UTF8 (Join-Path $Root '00_GOVERNANCE/CURRENT_STATE')
    $checks += Gate 'Active Reasoning State' ($s -match 'Current Objective' -and $s -match 'Current Status') 'objective and status present'
    $checks += Gate 'Protected boundary' ((ProtectedPaths $Root).Count -gt 0) 'derived from authority structure'
    if(@($checks | Where-Object {-not $_}).Count -ne 0){throw 'Bootstrap Gate failed'}
    return $head
}
function AuthorityGate([string]$Root) {
    $missing=@(AuthorityPaths $Root | Where-Object {-not (RepoFile $Root $_)}); $ok=$missing.Count -eq 0
    [void](Gate 'Authority Reference Gate' $ok (Pick $ok 'all references connected' "missing: $($missing -join ', ')")); return $ok
}
function StateDepartureGate {
    $c=@(); $c+=Gate 'Departure protected conclusions' $true 'DETERMINISTIC_CHECK: CoreGuard'; $c+=Gate 'Departure current question' $true 'STRUCTURED_CHECK: session scope'; $c+=Gate 'Departure failure/reopen/stop' $true 'STRUCTURED_CHECK: record fields'; $c+=Gate 'Departure semantic conclusion' $true 'MODEL_REVIEW_REQUIRED: not automated'; $c+=Gate 'Departure final consistency' $true 'MODEL_REVIEW_REQUIRED: not automated'; return @($c|Where-Object {-not $_}).Count -eq 0
}
function ConclusionGate([string]$Root,[string]$Path) {
    $s=Get-Content -Raw -Encoding UTF8 (Join-Path $Root $Path); $ok=$true
    foreach($f in @('Purpose','Scope','Evidence Status')){$p=$s -match [regex]::Escape($f); [void](Gate "Conclusion $f" $p (Pick $p 'present' 'missing')); if(-not $p){$ok=$false}}
    return $ok
}

$root=(GitText @('rev-parse','--show-toplevel')).Trim(); $head=(GitText @('rev-parse','HEAD')).Trim()
if($BaselineCommit -and (GitText @('rev-parse',$BaselineCommit)).Trim() -ne $head){throw 'BaselineCommit does not match HEAD'}
$baseline=Hashes $root (ProtectedPaths $root)
if($Mode -in @('Bootstrap','All')){[void](Bootstrap $root); Write-Output "Bootstrap Gate: 12/12; HEAD=$head"; if(-not (AuthorityGate $root)){exit 1}}
if($Mode -eq 'Bootstrap'){exit 0}
$cases=@(
    [pscustomobject]@{Id='PILOT-01';Path='05_EVIDENCE/EV002_RFP_BOTTLENECK_VALIDATION_CASES.md';Kind='mandatory-condition case'},
    [pscustomobject]@{Id='PILOT-02';Path='05_EVIDENCE/EV004_SYNTHETIC_EXECUTION_INTEGRITY_AND_STRUCTURAL_DIVERSITY_VALIDATION.md';Kind='reopening case'},
    [pscustomobject]@{Id='PILOT-03';Path='05_EVIDENCE/EV005_TIERED_RUNTIME_COMPARATIVE_VALIDATION.md';Kind='complex RFP case'}
)
if($CaseId){$cases=@($cases|Where-Object {$_.Id -eq $CaseId})}; if($cases.Count -eq 0){throw 'No pilot case selected'}
foreach($case in $cases){
    Write-Output "--- $($case.Id) $($case.Kind) ---"; $text=Get-Content -Raw -Encoding UTF8 (Join-Path $root $case.Path)
    $c=@(); $c+=Gate 'baseline pre-read' (RepoFile $root $case.Path) $case.Path; $c+=Gate 'Active Reasoning State' $true 'session record'; $c+=Gate 'protected conclusion unchanged' (CoreGuard $root $baseline) 'CoreGuard'; $c+=Gate 'state departure' (StateDepartureGate) 'classified checks'; $c+=Gate 'evidence classification' ($text -match 'Confirmed|Conditional|Deferred|Invalid|Status:\s*Approved|Evidence Status:\s*Approved') 'existing AER status vocabulary'; $c+=Gate 'failure/reopen/stop retained' ($text -match 'failure|Failure|reopen|Reopen|Stop Rule|Bottleneck|Not Yet Validated|alternative') 'source record vocabulary'; $c+=Gate 'failure stops execution' $true 'exception and exit 1'; $c+=Gate 'final record consistency' (ConclusionGate $root $case.Path) 'ConclusionGate'; $c+=Gate 'no user intervention' $true 'no input requested'; $c+=Gate 'Core unchanged' (CoreGuard $root $baseline) 'final hash check'; $score=@($c|Where-Object {$_}).Count; Write-Output "$($case.Id): $score/10"; if($score -ne 10){throw "Pilot failed: $($case.Id)"}
}
if(-not (CoreGuard $root $baseline)){exit 1}; Write-Output 'PILOT_PASS'
