---
description: "Git operations with intelligent commit messages and workflow optimization"
---

# /soc-git

## 1. Command Overview
The `/soc-git` command is the "Version Controller." It wraps standard git operations with intelligence. It can analyze diffs to generate Conventional Commit messages, check for accidental secrets before pushing, and manage branching strategies.

## 2. Triggers & Routing
The command routes to the `writer` agent for message generation and `security` for pre-push checks.

| Trigger Scenario | Flag | Target Agent | Action |
| :--- | :--- | :--- | :--- |
| **Commit Message** | `--smart` | `[writer]` | Generate `feat(scope): desc` |
| **Pre-Push** | `push` | `[security]` | Scan for secrets |
| **Branching** | `branch` | `[pm-agent]` | Enforce naming conventions |

## 3. Usage & Arguments
```bash
/soc-git [operation] [args] [flags]
```

### Arguments
-   **`[operation]`**: `commit`, `push`, `pull`, `branch`, `status`, `diff`.

### Flags
-   **`--smart`**: Auto-generate messages/descriptions.
-   **`--force`**: Bypass safety checks (Use with caution).

## 4. Behavioral Flow (Orchestration)

### Phase 1: Context Analysis
1.  **Status Check**: Run `git status`.
2.  **Diff Analysis**: Run `git diff --staged`.
3.  **Safety Check**: Scan pending changes for keys/env files.

### Phase 2: Operations
-   **Commit**:
    -   If `--smart`: Feed diff to LLM -> Generate Conventional Commit.
    -   If standard: Execute `git commit -m`.
-   **Push**:
    -   Check upstream. If missing, auto-set `-u origin`.
-   **Branch**:
    -   Normalize name (e.g., `My Feature` -> `feat/my-feature`).

### Phase 3: Post-Op
-   Confirm success.
-   Show Next Step (e.g., "Ready to open PR").

## 5. Output Guidelines (The Contract)

### Git Operation Result
```markdown
## Git: [Operation]

### Status
✅ Success / ❌ Failure

### Details
-   **Branch**: `feat/user-auth`
-   **Commit**: `a1b2c3d` - "feat(auth): add login route"

### Tips
-   [ ] Run `/test` before pushing.
```

## 6. Examples

### A. Smart Commit
```bash
/soc-git commit --smart
```
*Effect:* Analyzes staged files, detects added login logic, commits with: `feat(auth): implement user login flow`.

### B. Branch Creation
```bash
/soc-git branch "Update README"
```
*Effect:* Creates and checks out `docs/update-readme` (auto-categorized).

## 7. Dependencies & Capabilities

### Agents
-   **Writer**: `@[.opencode/agents/writer.md]` - For commit messages.
-   **Security**: `@[.opencode/agents/security.md]` - For pre-commit hooks.

### Skills
-   **Security Audit**: `@[.opencode/skills/security-audit/SKILL.md]` - Scanning staged files.

### MCP Integration
-   **`run_command`**: Executing actual git binaries.
-   **`filesystem`**: Reading ignores and config.

## 8. Boundaries

**Will:**
-   Execute git commands.
-   Generate text for messages.
-   Block commits with secrets (unless `--force`).

**Will Not:**
-   **Solve Merge Conflicts**: It will report them, but user must resolve.
-   **Rewrite History**: No `rebase` or `reset --hard` without explicit user confirmation.
