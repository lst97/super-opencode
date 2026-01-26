---
description: Code review and quality assessment
---

# /soc-review

## 1. Command Overview
The `/soc-review` command is the "Critic." It acts as a second pair of eyes before code is merged. It checks for logic errors, security vulnerabilities (OWASP), and adherence to the "Intentional Minimalism" design philosophy.

## 2. Triggers & Routing
The command routes to specialized reviewers.

| Trigger Scenario | Flag | Target Agent | Focus |
| :--- | :--- | :--- | :--- |
| **Logic/Bugs** | `--scope full` | `[reviewer]` | Correctness |
| **Security** | `--security` | `[security]` | Injection, AuthZ |
| **Style/Lint** | `--quick` | `[reviewer]` | Formatting, Naming |

## 3. Usage & Arguments
```bash
/soc-review [target] [flags]
```

### Arguments
-   **`[target]`**: File, directory, or Pull Request ID to review.

### Flags
-   **`--scope [full|quick]`**: (Default: `full`).
-   **`--security`**: Triggers explicit security scan protocol.

## 4. Behavioral Flow (Orchestration)

### Phase 1: Context Loading
1.  **Read**: Load the target code.
2.  **Context**: Load `implementation_plan.md` (to see what was intended).

### Phase 2: Analysis (The Audit)
-   **Static Analysis**: Grep for "smells" (`any`, `eval`, `console.log`).
-   **Logic Check**: Trace variable data flow.
-   **Design Check**: Does it match the Project Persona (Minimalism)?

### Phase 3: Reporting
-   Categorize findings by Severity (Critical, Warning, Info).
-   Reject if Critical issues exist.

## 5. Output Guidelines (The Contract)

### Code Review
```markdown
## Review: [Target]

### Verdict
❌ **Changes Requested** (1 Critical Issue)

### Findings

#### 🔴 Critical: SQL Injection
-   **File**: `src/api/search.ts:15`
-   **Code**: `db.query("SELECT * FROM users WHERE name = " + req.query.name)`
-   **Fix**: Use parameterized query `$1`.

#### 🟡 Warning: Performance
-   **File**: `src/utils.ts:40`
-   **Issue**: `README.md` parsing is synchronous. Use `fs.promises`.

### Summary
Solid logic, but the SQL injection must be fixed before merge.
```

## 6. Examples

### A. Pre-Merge Review
```bash
/soc-review src/features/payments --security
```
*Effect:* Triggers `security` agent to specifically look for PCI compliance issues and raw secrets.

### B. Quick Sanity Check
```bash
/soc-review --quick
```
*Effect:* Scans changed files for obvious errors (lint, types) before commit.

## 7. Dependencies & Capabilities

### Agents
-   **Reviewer**: `@[.opencode/agents/reviewer.md]` - General code quality.
-   **Security**: `@[.opencode/agents/security.md]` - Vulnerability scanning.

### Skills
-   **Security Audit**: `@[.opencode/skills/security-audit/SKILL.md]` - Automated checking.

## 8. Boundaries

**Will:**
-   Point out specific lines of code.
-   Suggest concrete fixes.
-   Block "unsafe" code.

**Will Not:**
-   **Fix the code**: It only comments. Use `/soc-improve` to fix.
-   **Judge Aesthetics**: Unless it violates "Intentional Minimalism."
