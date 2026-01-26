---
description: Code improvement and optimization
---

# /soc-improve

## 1. Command Overview
The `/soc-improve` command is the "Optimizer." Unlike `implement` (which builds new things) or `cleanup` (which removes dead things), `improve` makes existing *working* code *better*. It focuses on performance, readability, security, and quality benchmarks.

## 2. Triggers & Routing
The command routes to specialized agents based on the `--focus` flag.

| Trigger Scenario | Flag | Target Agent | Goal |
| :--- | :--- | :--- | :--- |
| **Performance** | `--focus perf` | `[architect]` | Reduce latency/memory |
| **Code Quality** | `--focus quality` | `[quality]` | Refactor/Clean Clean |
| **Security Hardening** | `--focus security` | `[security]` | Patch vulnerabilities |
| **UX Polish** | `--focus ux` | `[frontend]` | A11y, animations |

## 3. Usage & Arguments
```bash
/soc-improve [target] [flags]
```

### Arguments
-   **`[target]`**: File or component to optimize.

### Flags
-   **`--focus [perf|quality|security|ux]`**: **MANDATORY**.
-   **`--metric [target]`**: Optional goal (e.g., `< 100ms`).

## 4. Behavioral Flow (Orchestration)

### Phase 1: Benchmark (The Baseline)
1.  **Measure**: Analyze current state (LOC, Complexity, or approximate Perf).
2.  **Identify**: Find bottlenecks or anti-patterns.

### Phase 2: Plan (The Upgrade)
-   Propose specific refactors.
-   Estimate impact (e.g., "Replacing nested loop will reduce O(n^2) to O(n)").

### Phase 3: Execute (The Refactor)
1.  **Edit**: Apply changes safely.
2.  **Verify**: Ensure tests still pass (Regression Check).
3.  **Compare**: Show Before vs After stats.

## 5. Output Guidelines (The Contract)

### Improvement Report
```markdown
## Improvement: [Target]

### Focus: [Focus Area]

### Changes Applied
1.  **Refactor**: Extracted `LargeComponent` into 3 sub-components.
2.  **Performance**: Memoized calculation of expensive value.

### Metrics
| Metric | Before | After | Delta |
| :--- | :--- | :--- | :--- |
| **Complexity** | 15 | 8 | -47% |
| **Lines** | 200 | 120 | -40% |

### Verification
✅ Tests Passed
```

## 6. Examples

### A. Performance Tuning
```bash
/soc-improve src/utils/sort.ts --focus perf
```
*Effect:* Replaces bubble sort with quicksort or uses a native method.

### B. Security Hardening
```bash
/soc-improve src/api/user.ts --focus security
```
*Effect:* Adds input validation (Zod) and rate limiting to an existing endpoint.

## 7. Dependencies & Capabilities

### Agents
-   **Architect**: `@[.opencode/agents/architect.md]` - Performance strategy.
-   **Quality**: `@[.opencode/agents/quality.md]` - Code structure.
-   **Security**: `@[.opencode/agents/security.md]` - Hardening.

### Skills
-   **Reflexion**: `@[.opencode/skills/reflexion/SKILL.md]` - Ensuring improvements don't break logic.

### MCP Integration
-   **`context7`**: Checking for modern language features (e.g., utilizing new node.js APIs).

## 8. Boundaries

**Will:**
-   Refactor code structure.
-   Optimize algorithms.
-   Add comments/documentation.

**Will Not:**
-   **Change Behavior**: The external API/output must remain identical (unless fixing a bug).
-   **Delete Features**: Use `/soc-cleanup` for removal.
