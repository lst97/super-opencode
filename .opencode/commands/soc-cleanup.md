---
description: "Systematically clean up code, remove dead code, and optimize project structure"
---

# /soc-cleanup

## 1. Command Overview
The `/soc-cleanup` command is the "Janitor" of the codebase. It safely identifies and removes technical debt, unused exports, and dead code. It operates in two modes: `Safe` (conservative) and `Aggressive` (deep cleaning). Its primary directive is "Do No Harm."

## 2. Triggers & Routing
The command routes cleanup tasks based on the `--type` flag.

| Trigger Scenario | Flag | Target Agent | Tool Used |
| :--- | :--- | :--- | :--- |
| **Dead Code** | `--type code` | `[quality]` | TSPrune, Knip |
| **Unused Imports** | `--type imports` | `[quality]` | ESLint/Birome |
| **File Structure** | `--type files` | `[architect]` | Filesystem Analysis |
| **Deep Clean** | `--type all` | `[quality]` | All tools |

## 3. Usage & Arguments
```bash
/soc-cleanup [target] [flags]
```

### Arguments
-   **`[target]`**: Directory or file to clean (default: current context).

### Flags
-   **`--type [code|imports|files|all]`**: **MANDATORY**.
-   **`--safe`**: (Default) Only removes code with 0 references.
-   **`--aggressive`**: Removes code with indirect/suspect references (requires confirmation).
-   **`--preview`**: Lists changes without applying them (Dry Run).

## 4. Behavioral Flow (Orchestration)

### Phase 1: Analysis (The Scanner)
1.  **Map**: Scans `[target]` for exports and imports.
2.  **Trace**: Builds a dependency graph.
3.  **Flag**: Identifies "orphan" nodes (code with no incoming edges).

### Phase 2: Plan (The Stratagem)
-   If `safe`: Select only orphans with 0 references.
-   If `aggressive`: Select orphans + "soft" references (comments, test-only usage).

### Phase 3: Execution (The Broom)
1.  **Backup**: (Implicit) Relies on Git.
2.  **Remove**: Deletes lines/files.
3.  **Verify**: Runs build/tests. If fail -> Revert.

## 5. Output Guidelines (The Contract)

### Cleanup Report
```markdown
## Cleanup Report: [Target]

### Summary
-   **Removed**: 15 unused exports
-   **Deleted**: 2 dead files
-   **Bytes Saved**: 4.5KB

### Actions Taken
-   [x] Removed `oldFunction` from `src/utils.ts` (0 refs).
-   [x] Deleted `src/components/unused-modal.tsx`.

### Skipped (Safety Check)
-   [ ] `legacyAuth.ts` (Referenced in TODO comment).
```

## 6. Examples

### A. Safe Import Cleanup
```bash
/soc-cleanup src/ --type imports --safe
```
*Effect:* Removes unused `import` statements and sorts remaining ones.

### B. Dead Code Preview
```bash
/soc-cleanup --type code --preview
```
*Effect:* Lists all exported functions that are never imported, but does not delete them.

## 7. Dependencies & Capabilities

### Agents
-   **Quality**: `@[.opencode/agents/quality.md]` - Primary agent for code analysis.
-   **Architect**: `@[.opencode/agents/architect.md]` - For structural cleanup.

### Skills
-   **Safety Check**: `@[.opencode/skills/security-audit/SKILL.md]` - ensuring cleanup doesn't remove security gates.
-   **Reflexion**: `@[.opencode/skills/reflexion/SKILL.md]` - Recovering if cleanup breaks the build.

### MCP Integration
-   **`context7`**: Verifying if "unused" code is actually a framework entry point (e.g., Next.js pages).
-   **`filesystem`**: Moving and deleting files.

## 8. Boundaries

**Will:**
-   Remove unused imports.
-   Delete files with 0 references (in `aggressive` mode).
-   Consolidate duplicate logic (if explicitly identified).

**Will Not:**
-   **Delete "Commented Out" Code**: Unless explicitly told to.
-   **Touch Config Files**: (e.g., `tsconfig.json`) without explicit intent.
-   **Break Public APIs**: Will not remove exports from `index.ts` files in libraries.
