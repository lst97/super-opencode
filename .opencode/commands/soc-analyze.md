---
description: "Orchestrator command that triggers specialized agents for code, security, and architecture review."
---

# /soc-analyze

## 1. Command Overview

The `/soc-analyze` command is the **primary entry point** for all code inspection tasks. It does not perform the analysis itself; instead, it acts as a **router**, identifying the correct specialized agent (`security`, `quality`, `architect`, or `backend`) and providing them with the necessary context and constraints.

## 2. Triggers & Routing

The command automatically routes to the best-suited agent based on the `--focus` flag or the context of the request.

| Trigger Scenario | Flag | Target Agent | Context Injected |
| :--- | :--- | :--- | :--- |
| **Security Audit** | `--focus security` | `[security]` | STRIDE model, OWASP Top 10 checklist |
| **Code Review** | `--focus quality` | `[quality]` | Test coverage stats, Linter rules |
| **System Design** | `--focus architecture` | `[architect]` | Current ADRs, Cloud constraints |
| **Database/API** | `--focus backend` | `[backend]` | Schema definitions, API contracts |
| **UI/UX Check** | `--focus frontend` | `[frontend]` | Mobile responsiveness, WCAG standards |

## 3. Usage & Arguments

```bash
/soc-analyze [target] [flags]
```

### Arguments

- **`[target]`**: (Optional) specific file, directory, or "all" (default: current context).

### Flags

- **`--focus [domain]`**: **MANDATORY** (if not implied). Forces a specific agent.
  - Options: `security`, `quality`, `architecture`, `performance`, `backend`, `frontend`.
- **`--depth [level]`**:
  - `quick`: Static checks, linting, known CVEs (Fast).
  - `deep`: Logic flow analysis, race condition checks, architectural impact (Slow, uses `sequential-thinking`).
- **`--format [type]`**:
  - `text`: Human-readable summary (default).
  - `json`: Machine-parsable output for CI/CD pipelines.

## 4. Behavioral Flow (Orchestration)

### Phase 1: Context Gathering (The "Map")

1. **Scan**: The command uses `glob` to list relevant files in `[target]`.
2. **Filter**: It excludes `node_modules`, `.git`, and lockfiles.
3. **Detect**: It identifies the stack (e.g., "Next.js + Postgres") to inform the agent.

### Phase 2: Delegation (The "Handoff")

The command constructs a specific prompt for the target agent:
> "Agent **[Name]**, perform a **[Depth]** analysis on **[Target]**.
> Context: The project is **[Stack]**.
> Constraint: Focus strictly on **[Focus Area]**.
> Output: Use the standard **Analysis Report** format."

### Phase 3: Synthesis (The "Report")

The command collates the agent's output. If multiple agents were invoked (e.g., "full audit"), it merges their JSON outputs into a single artifact.

## 5. Output Guidelines (The Contract)

All triggered agents must return data in this structure so the user (or PM) can parse it.

### Standard Analysis Report

```markdown
# Analysis Report: [Focus Area]
**Target:** `src/auth/*`
**Agent:** `security`
**Date:** 2025-10-27

## Summary
Found **2 High** severity issues and **1 Low** severity issue.

## Critical Findings
1.  **[High] SQL Injection Vulnerability**
    *   *File:* `src/auth/login.ts`
    *   *Context:* Raw string concatenation in query.
    *   *Recommendation:* Use parameterized queries (see `backend` agent guidelines).

2.  **[Medium] Missing Rate Limiting**
    *   *File:* `src/api/routes.ts`
    *   *Recommendation:* Implement middleware adapter.

## Metrics
-   **Files Scanned:** 12
-   **Coverage:** 45% (Below threshold)
```

## 6. Examples

### A. Security Scan (Deep)

```bash
/soc-analyze src/payments --focus security --depth deep
```

*Effect:* Triggers `security` agent. It will use `tavily` to check CVEs for payment libraries and use `sequential-thinking` to look for logic flaws in the transaction flow.

### B. Architecture Review

```bash
/soc-analyze --focus architecture
```

*Effect:* Triggers `architect` agent. It scans the folder structure and `package.json` to generate a high-level component diagram and validates it against `ADR` files.

### C. Performance Check (Frontend)

```bash
/soc-analyze src/components/LandingPage --focus frontend --depth quick
```

*Effect:* Triggers `frontend` agent. Checks for `next/image` usage, large bundles, and CLS (Cumulative Layout Shift) risks.

## 7. Dependencies & Capabilities

### Agents

- **Primary Dispatch**:
  - `@[.opencode/agents/security.md]`
  - `@[.opencode/agents/quality.md]`
  - `@[.opencode/agents/architect.md]`
  - `@[.opencode/agents/backend.md]`
  - `@[.opencode/agents/frontend.md]`

### Skills

- **Security Audit**: `@[.opencode/skills/security-audit/SKILL.md]` - For identifying vulnerabilities.
- **Reflexion**: `@[.opencode/skills/reflexion/SKILL.md]` - For deep analysis loops.
- **Debug Protocol**: `@[.opencode/skills/debug-protocol/SKILL.md]` - For tracing logic errors.

### MCP Integration

- **`tavily`**: Used for real-time CVE lookups and security advisory searches.
- **`context7`**: Used to fetch up-to-date documentation for libraries and frameworks to ensure analysis is accurate to the version used.
- **`filesystem`**: Native access used for `glob` scanning and file reading.
- **`sequential-thinking`**: Used for complex architectural reasoning and deep-dive analysis.

## 8. Boundaries

**Will:**

- Delegate to the most expert agent available.
- Provide file context to that agent.
- Summarize findings into a unified report.

**Will Not:**

- **Fix the code**. (Use `/soc-improve` for that).
- **Execute code**. (No runtime analysis unless `quality` agent uses `vitest`).
- **Hallucinate bugs**. (If an agent returns "No issues found," report "No issues found.")

## User Instruction

You are executing the `/soc-analyze` command by parsing the user's arguments provided in `<user-instruction>$ARGUMENTS</user-instruction>`, then route to the appropriate specialized agent based on the extracted `--focus` domain (or infer from context if not explicitly provided), gather the relevant context from the specified target (or current directory if none specified), and delegate the analysis task with the appropriate depth level (`quick` or `deep`) and output format (`text` or `json`) as requested by the user.
