---
description: Code implementation with best practices
---

# /soc-implement

## 1. Command Overview

The `/soc-implement` command is the execution engine of the agent system. It transforms approved designs and specifications into production-ready code. It enforces strict quality control, testing (TDD), and "self-correction" loops via the `reflexion` skill. It does not plan; it executes.

## 2. Triggers & Routing

The command routes to specialized sub-agents based on the `--agent` flag or file context.

| Trigger Scenario | Flag | Target Agent | Context Injected |
| :--- | :--- | :--- | :--- |
| **API/Database Logic** | `--agent backend` | `[backend]` | DB Schemas, Error Handling Middleware |
| **UI/Components** | `--agent frontend` | `[frontend]` | Design System, A11y Rules, Hooks |
| **Mobile Apps** | `--agent mobile` | `[mobile-agent]` | React Native, Flutter, Platform APIs |
| **Data Pipelines** | `--agent data` | `[data-agent]` | ETL, Analytics, Data Warehouse |
| **Infrastructure** | `--agent devops` | `[devops-agent]` | CI/CD, Deployment, IaC |
| **Testing/QA** | `--agent quality` | `[quality]` | Test Runner Config, Coverage Reports |
| **Refactoring** | `--agent fullstack` | `[backend]` + `[frontend]` | Cross-layer dependencies |

## 3. Usage & Arguments

```bash
/soc-implement [target] [flags]
```

### Arguments

- **`[target]`**: The feature or file to implement (e.g., "Login Flow", "src/components/Button.tsx").

### Flags

- **`--agent [backend|frontend|quality]`**: **MANDATORY**. Specifies the executing persona.
- **`--test`**: (Default: true) Run capabilities tests after implementation.
- **`--document`**: (Default: true) Update associated documentation/comments.

## 4. Behavioral Flow (Orchestration)

### Phase 1: Pre-Flight (Confidence Check)

1. **Read**: Review existing code and referencing `design.md` or `requirements`.
2. **Verify**: Check for patterns (e.g., "How do existing controllers handle errors?").
3. **Gate**: If confidence < 80%, ask user/PM for clarification.

### Phase 2: Execution (The Loop)

1. **Test**: Write the test case first (TDD) if applicable.
2. **Edit**: Apply changes using `replace_file_content` or `write_to_file`.
3. **Verify**: Run the project's build/test command.
    - *If Fail*: Trigger `reflexion` skill (Why did it fail? -> Fix -> Retry).
    - *Limit*: Max 3 retries before asking for help.

### Phase 3: Post-Flight (Self Check)

- Did I leave any `console.log`?
- Are inputs sanitized?
- Did I break the build?

## 5. Output Guidelines (The Contract)

### Standard Implementation Report

```markdown
## Implementation: [Feature Name]

### 1. Changes Summary
-   **Created:** `src/features/auth/login.ts`
-   **Modified:** `src/components/navbar.tsx`

### 2. Verification
-   ✅ **Build:** Passed
-   ✅ **Tests:** 3 new tests added, all passing.
-   ✅ **Lint:** 0 errors.

### 3. Key Decisions
-   Used `zod` for validation to match existing patterns.
-   Extracted `useAuth` hook for reusability.
```

## 6. Examples

### A. Backend Feature

```bash
/soc-implement "User Registration API" --agent backend
```

*Effect:* `backend` agent writes `POST /register`, adds `UserSchema` validation, inputs into Postgres, and returns a sanitized User DTO.

### B. Frontend Component

```bash
/soc-implement "DarkMode Toggle" --agent frontend
```

*Effect:* `frontend` agent checks `tailwind.config.js`, creates a toggle component using `Radix UI` primitives (if installed) and handles local storage state.

## 7. Dependencies & Capabilities

### Agents

- **Backend**: `@[.opencode/agents/backend.md]`
- **Frontend**: `@[.opencode/agents/frontend.md]`
- **Quality**: `@[.opencode/agents/quality.md]` - For TDD and verification.

### Skills

- **Confidence Check**: `@[.opencode/skills/confidence-check/SKILL.md]` - MANDATORY step before starting.
- **Self Check**: `@[.opencode/skills/self-check/SKILL.md]` - Validation protocol after changes.
- **Debug Protocol**: `@[.opencode/skills/debug-protocol/SKILL.md]` - If implementation hits errors.
- **Package Manager**: `@[.opencode/skills/package-manager/SKILL.md]` - MANDATORY for all dependency operations.
- **Simplification**: `@[.opencode/skills/simplification/SKILL.md]` - Keeps implementations minimal.
- **Doc Sync**: `@[.opencode/skills/doc-sync/SKILL.md]` - Ensures documentation matches implementation.

### MCP Integration

- **`context7`**: For looking up exact syntax and library API usage to prevent hallucinations.
- **`filesystem`**: For determining current project structure and patterns.
- **`tavily`**: Research latest best practices and library versions.
- **`sequential-thinking`**: Step through complex implementation logic.

## 8. Boundaries

**Will:**

- Write code modules, tests, and documentation.
- Fix compilation errors it causes.
- Respect existing linters and formatters.

**Will Not:**

- **Invent Designs**: If no design exists, it will fall back to simple best practices or ask for a design.
- **Commit Violations**: Will not commit code with secrets or critical bugs.
- **Touch Forbidden Files**: (e.g., `package-lock.json` manual edits, `.env` manual edits).

## User Instruction

The user have executed the `/soc-implement` command by parsing the user's arguments provided in `<user-instruction>$ARGUMENTS</user-instruction>`, then route to the appropriate specialized agent based on the extracted `--agent` flag (backend, frontend, quality, or fullstack), perform a confidence check by reviewing existing code and patterns before starting, write test cases first following TDD principles if applicable, implement the feature or component using appropriate file operations, run the project's build and test commands for verification, trigger the reflexion skill to analyze and fix any failures with a maximum of 3 retry attempts, conduct a post-flight self-check for debugging artifacts and input sanitization, and generate an implementation report documenting changes made, verification status, and key architectural decisions.
