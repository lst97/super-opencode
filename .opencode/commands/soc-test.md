---
description: Test generation and execution
---

# /soc-test

## 1. Command Overview
The `/soc-test` command is the "Quality Gatekeeper." It generates, runs, and reports on tests. It ensures that no code is shipped without verification. It triggers the `quality` agent to write unit, integration, or E2E tests and uses the `reviewer` agent to analyze coverage.

## 2. Triggers & Routing
The command determines the scope and tool based on the arguments.

| Trigger Scenario | Flag | Target Agent | Tool Used |
| :--- | :--- | :--- | :--- |
| **Unit Testing** | `--type unit` | `[quality]` | Jest/Vitest |
| **Integration** | `--type integration` | `[quality]` | Supertest/Pytest |
| **E2E Flows** | `--type e2e` | `[quality]` | Playwright/Cypress |
| **Coverage Check**| `--coverage` | `[reviewer]` | Istanbul/C8 |

## 3. Usage & Arguments
```bash
/soc-test [target] [flags]
```

### Arguments
-   **`[target]`**: File or directory to test (e.g., `src/utils/math.ts`).

### Flags
-   **`--type [unit|integration|e2e]`**: (Optional) Default: `unit`.
-   **`--coverage`**: Generates a coverage report.
-   **`--watch`**: Runs in watch mode (interactive).

## 4. Behavioral Flow (Orchestration)

### Phase 1: Context & Gap Analysis
1.  **Read**: Analyzes the source code in `[target]`.
2.  **Scan**: Checks for existing `.test.ts` or `_test.py` files.
3.  **Plan**: Identifies missing test cases (Edge cases, Error states, Happy path).

### Phase 2: Generation (The Writer)
The command prompts the `quality` agent:
> "Generate **[Type]** tests for **[Target]**.
> Ensure **[Coverage]**.
> Mock dependencies: **[External Services]**."

### Phase 3: Execution (The Runner)
1.  **Run**: Executes the test command (e.g., `npm test`).
2.  **Report**: Captures `stdout/stderr`.
3.  **Reflect**: If tests fail, it suggests fixes (or fixes them if in `implement` mode).

## 5. Output Guidelines (The Contract)

### Test Execution Report
```markdown
## Test Report: [Target]

### 1. Summary
-   **Status**: ❌ FAILED (2/10 failed)
-   **Time**: 1.2s

### 2. Failures
-   **Test**: `should return 400 on invalid email`
    -   **Expected**: `400`
    -   **Received**: `500`
    -   **Diagnosis**: Unhandled exception in controller.

### 3. Coverage
-   **Line**: 85%
-   **Branch**: 70% (Missing: `if (!user)`)
```

## 6. Examples

### A. Unit Test Generation
```bash
/soc-test src/utils/currency.ts --type unit
```
*Effect:* Generates `src/utils/currency.test.ts` covering rounding logic and currency codes.

### B. Integration Test
```bash
/soc-test src/api/auth --type integration
```
*Effect:* Sets up a mock database and tests the `/login` flow including DB persistence.

## 7. Dependencies & Capabilities

### Agents
-   **Quality Assurance**: `@[.opencode/agents/quality.md]` - Primary agent for test generation.
-   **Reviewer**: `@[.opencode/agents/reviewer.md]` - For evaluating test coverage and effectiveness.

### Skills
-   **Self Check**: `@[.opencode/skills/self-check/SKILL.md]` - Verifying test results against requirements.
-   **Debug Protocol**: `@[.opencode/skills/debug-protocol/SKILL.md]` - Analyzing test failures.

### MCP Integration
-   **`run_command`**: Executing test runners (Jest, Vitest, Pytest).
-   **`filesystem`**: processing integration test artifacts or coverage reports.

## 8. Boundaries

**Will:**
-   Generate standard test files using the project's framework.
-   Run tests and parse output.
-   Mock external dependencies (S3, Stripe) to prevent flake.

**Will Not:**
-   **Guarantee 100% Logic Coverage**: It covers code paths, not necessarily business intent.
-   **Debug Production**: Tests run in `test` environment only.
