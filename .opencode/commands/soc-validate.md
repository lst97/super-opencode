---
description: "Requirements validation, traceability matrices, and acceptance criteria verification"
---

# /soc-validate

## 1. Command Overview

The `/soc-validate` command is the "Quality Gate" between design and implementation. It ensures requirements are complete, unambiguous, and testable before coding begins. It creates traceability matrices that map requirements to tests, designs, and implementation artifacts—ensuring nothing falls through the cracks.

## 2. Triggers & Routing

The command activates validation modes based on what needs verification.

| Trigger Scenario | Flag | Target Agent | Context Injected |
| :--- | :--- | :--- | :--- |
| **Requirements Review** | `--type requirements` | `[pm-agent]` | User Stories, Acceptance Criteria |
| **Design Validation** | `--type design` | `[architect]` | ADRs, API Contracts, Schemas |
| **Test Coverage Check** | `--type coverage` | `[quality]` | Test Plans, Code Coverage Reports |
| **Full Validation** | `--type full` | `[pm-agent]` + `[quality]` + `[architect]` | All artifacts |

## 3. Usage & Arguments

```bash
/soc-validate [target] [flags]
```

### Arguments

- **`[target]`**: The artifact to validate (e.g., "User Auth Requirements", "API v2 Design", "Sprint 5").

### Flags

- **`--type [requirements|design|coverage|full]`**: **MANDATORY**. Specifies validation scope.
- **`--strict [lenient|normal|strict]`**: Validation strictness (default: normal).
- **`--output [report|matrix|checklist]`**: Output format (default: report).
- **`--block-on-fail`**: Return non-zero exit code if validation fails (for CI/CD).

## 4. Behavioral Flow (Orchestration)

### Phase 1: Artifact Discovery

1. **Read**: Parse target requirements/design documents.
2. **Collect**: Gather related artifacts (tests, code, ADRs).
3. **Baseline**: Establish validation criteria based on `--strict` level.

### Phase 2: Validation Checks

#### Requirements Validation (`--type requirements`):
- **INVEST Check**: Are stories Independent, Negotiable, Valuable, Estimable, Small, Testable?
- **Acceptance Criteria**: Are Gherkin-style Given/When/Then statements present?
- **Ambiguity Scan**: Flag vague terms ("fast", "user-friendly", "soon").
- **Completeness**: Verify all user personas have journeys.

#### Design Validation (`--type design`):
- **ADR Completeness**: Does every major decision have an ADR?
- **API Contract**: Are request/response schemas defined?
- **Security Review**: Does design address authZ, authN, data protection?
- **Scalability**: Are load/performance targets specified?

#### Coverage Validation (`--type coverage`):
- **Traceability Matrix**: Map each requirement to test cases.
- **Coverage Gaps**: Identify requirements with no tests.
- **Orphan Tests**: Find tests that don't map to requirements.

### Phase 3: Report Generation

- **Consolidate**: Aggregate all validation findings.
- **Score**: Calculate validation score (% of criteria met).
- **Blocker Flag**: Mark items that must be resolved before implementation.
- **Export**: Generate validation report.

## 5. Output Guidelines (The Contract)

### Validation Report Template

```markdown
# Validation Report: [Target Name]

## Summary
**Validation Type**: Requirements  
**Strictness Level**: Normal  
**Overall Score**: 87% (✅ PASS / ❌ FAIL)  
**Blockers**: 2 (Must resolve before implementation)  
**Warnings**: 5 (Should address)  
**Date**: 2026-01-30

## Detailed Findings

### ✅ Passed Checks

| Check | Details |
|:-----|:--------|
| INVEST - Independent | All stories are self-contained |
| INVEST - Testable | Acceptance criteria use Gherkin syntax |
| API Contracts | All endpoints have Zod schemas |

### ⚠️ Warnings (Should Fix)

| ID | Category | Issue | Recommendation | Severity |
|:---|:---------|:------|:---------------|:--------:|
| W-001 | Ambiguity | Story US-004 says "fast response" | Define specific SLA (<200ms) | Medium |
| W-002 | Completeness | No error handling requirements | Add failure scenarios | Medium |

### 🛑 Blockers (Must Fix)

| ID | Category | Issue | Recommendation | Severity |
|:---|:---------|:------|:---------------|:--------:|
| B-001 | Security | No authentication requirements | Add auth flows and token handling | Critical |
| B-002 | Testability | US-007 lacks acceptance criteria | Add Given/When/Then scenarios | High |

## Traceability Matrix

| Requirement | Design | Test Case | Status |
|:------------|:-------|:----------|:------:|
| US-001: User login | ADR-003 | TC-001, TC-002 | ✅ Covered |
| US-002: Password reset | ADR-003 | ❌ None | ❌ Gap |
| US-003: OAuth | ADR-005 | TC-003 | ✅ Covered |

## Recommendations

1. **Immediate**: Resolve B-001 (security) before any implementation.
2. **Before Sprint**: Add acceptance criteria to US-007.
3. **Nice to Have**: Quantify performance requirements (replace "fast" with SLA).

## Sign-off

- [ ] Requirements validated
- [ ] Blockers resolved
- [ ] Ready for implementation
```

### Quick Checklist Output

```markdown
## Validation Checklist: [Target]

### Requirements
- [x] All stories follow INVEST principles
- [x] Acceptance criteria present
- [ ] No ambiguous language (2 found)
- [x] User personas defined

### Design
- [x] ADRs for major decisions
- [ ] API contracts complete (1 missing)
- [x] Security considerations documented

### Test Coverage
- [x] Traceability matrix created
- [ ] 100% requirement coverage (87% actual)
- [x] Orphan tests identified

**Result**: ⚠️ PARTIAL - Address 3 items before proceeding
```

## 6. Examples

### A. Requirements Validation

```bash
/soc-validate "User Authentication Epic" --type requirements --strict strict
```

*Effect:* Validates all user stories in the auth epic against INVEST principles, flags ambiguous language, and ensures acceptance criteria follow Gherkin syntax.

### B. Full Project Validation

```bash
/soc-validate "v2.0 Release" --type full --output matrix --block-on-fail
```

*Effect:* Runs comprehensive validation across requirements, design, and test coverage. Generates a traceability matrix and exits with error code if blockers found (for CI/CD gates).

### C. Design-Only Check

```bash
/soc-validate "Payment API Design" --type design --output checklist
```

*Effect:* Validates the payment API design has complete ADRs, proper schemas, security considerations, and scalability plans. Outputs a quick checklist format.

## 7. Dependencies & Capabilities

### Agents

- **Orchestrator**: `[pm-agent]` - Requirements validation and acceptance criteria review.
- **Technical Validator**: `[architect]` - Design and ADR validation.
- **Quality Validator**: `[quality]` - Test coverage and traceability analysis.

### Skills

- **Confidence Check**: `@[.opencode/skills/confidence-check/SKILL.md]` - Ensures validation criteria are clear.
- **Security Audit**: `@[.opencode/skills/security-audit/SKILL.md]` - Validates security requirements.
- **Self Check**: `@[.opencode/skills/self-check/SKILL.md]` - Validates validation process itself (meta!).

### MCP Integration

- **`read_file`**: Parse requirements, designs, and test files.
- **`grep`**: Search for patterns (e.g., "TODO", "FIXME", ambiguous terms).
- **`sequential-thinking`**: Analyze complex requirement dependencies.

## 8. Boundaries

**Will:**

- Validate requirements against industry standards (INVEST, SMART, Gherkin).
- Create traceability matrices linking requirements to tests and designs.
- Flag ambiguous or incomplete requirements.
- Block implementation if critical gaps found (with `--block-on-fail`).

**Will Not:**

- **Auto-Fix Issues**: Identifies problems but doesn't rewrite requirements.
- **Write Tests**: Validates test coverage exists, but doesn't create tests.
- **Override Business Decisions**: Flags concerns but doesn't change requirements without user approval.
- **Validate Implementation**: Checks design/requirements only—use `/soc-review` for code review.

## User Instruction

The user have executed the `/soc-validate` command by parsing the user's arguments provided in `<user-instruction>$ARGUMENTS</user-instruction>`, then route to the appropriate validation type (requirements, design, coverage, or full), read and parse the target artifacts (requirements documents, ADRs, test files), apply validation checks based on strictness level (INVEST, Gherkin, ambiguity detection, coverage analysis), identify blockers that must be resolved before implementation, generate a comprehensive validation report with traceability matrix, output findings in the requested format (report, matrix, or checklist), and if `--block-on-fail` is set, signal failure when blockers are present.
