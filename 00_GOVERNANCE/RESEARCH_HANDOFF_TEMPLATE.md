# Research Handoff

Handoff ID:

RH-YYYYMMDD-NNN

Approval Status:

Draft

Closure Mode:

Lightweight | Standard | Release

Git Permission:

Analysis Only | Apply Only | Stage After Review | Commit After Review | Push After Review | Autonomous Closure

Source Research Session:

Not Assigned

---

## 1. Research Question

[연구에서 다룬 핵심 질문]

---

## 2. Approved Conclusions

- [인간 연구자가 승인한 결론]
- [승인된 범위 안의 결론만 기록]

---

## 3. Evidence Basis

### Existing Repository Evidence

- [기존 Evidence, Reasoning, Session 또는 Principle ID]

### New Evidence

- [이번 논의에서 확인된 사실·자료·관찰]

---

## 4. Scope

### Included

- [현재 결론이 적용되는 범위]

### Excluded or Not Yet Validated

- [아직 적용하지 않는 범위]

---

## 5. Limitations

- [추가 확인이 필요한 조건]
- [근거가 부족한 영역]
- [강화해서 표현하면 안 되는 주장]

---

## 6. Repository Actions

| Action | Target Path | Object ID | Instruction |
|---|---|---|---|
| Inspect Only | [path] | [ID or N/A] | [읽어야 하는 이유] |
| Create / Modify / No Change | [path] | [ID] | [수행할 최소 변경] |

When explicit paths are not known:

Action:

Derive Minimum Set

Instruction:

Inspect repository conventions and derive the smallest sufficient set inside the approved semantic and repository boundary.

### Autonomous Execution Parameters

Complete when `Git Permission: Autonomous Closure`.

Expected Base Commit:

[commit hash]

Target Branch:

main

Proposed Commit Title:

[commit title]

Push Authorized:

Yes | No

Allowed Path Boundary:

- [explicit relative path or bounded path pattern]

Protected Files Explicitly Permitted:

- None
- [explicit protected file]

---

## 7. Protected Files

Files that must not be modified unless explicitly listed above:

- BOOTSTRAP.md
- README.md
- CHANGELOG.md
- 00_GOVERNANCE/CURRENT_STATE
- 00_GOVERNANCE/SPECIFICATION.md
- 00_GOVERNANCE/OPERATION_RULES.md
- 00_GOVERNANCE/PROJECT_CHARTER.md
- 00_GOVERNANCE/RESEARCH_PHILOSOPHY.md

---

## 8. Unresolved Questions

- [현재 남겨둔 Open Problem]
- [후속 검증 대상]

---

## 9. Validation Requirements

Required:

- Git status and branch check
- expected base and remote check
- changed-file list
- approved-scope comparison
- `git diff --check`
- repository closure validation
- non-zero size for new or restored files
- filename and internal-ID consistency
- reference-path validation
- protected-file change check
- scope and limitation preservation

Additional Validation:

- [해당 연구에만 필요한 검증]

---

## 10. Completion Condition

### Autonomous Closure

The Handoff is complete when:

- the minimum approved files have been created or modified,
- all required validation has passed,
- actual changes remain inside the approved boundary,
- one Commit has been created when changes exist,
- Push has completed when authorized,
- local and remote result has been reported,
- no unauthorized Git action occurred.

A No-op result creates no empty Commit.

### Manual Closure

The Handoff is Applied when files have been modified and validated. Commit and Push require the permission stated at the top of this Handoff.
