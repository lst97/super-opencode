---
description: Custom workflow creation and execution
---

# /soc-workflow

## 1. Command Overview

The `/soc-workflow` command is the "Factory." It allows users to create, list, and run custom sequences of agent commands. It turns a manual, multi-step process (e.g., "Check status -> Pull -> Build -> Deploy") into a single executable command.

## 2. Triggers & Routing

The command is a meta-orchestrator.

| Trigger Scenario | Flag | Action |
| :--- | :--- | :--- |
| **New Automation** | `create` | Templates a new `.md` file in `.agent/workflows/` |
| **Run Automation** | `run` | Parses and executes the steps in order |
| **List Available** | `list` | Scans directory for `.md` files |

## 3. Usage & Arguments

```bash
/soc-workflow [action] [name]
```

### Arguments

- **`[action]`**: `create`, `run`, `list`, `edit`, `delete`.
- **`[name]`**: Name of the workflow (e.g., `deploy`).

## 4. Behavioral Flow (Orchestration)

### Phase 1: Definition (Create)

1. **Template**: Creates a standard markdown file with "Steps."
2. **Define**: User fills in shell commands or agent commands (`/soc-git`, `/soc-test`).

### Phase 2: Execution (Run)

1. **Parse**: Reads the markdown.
2. **Step**: Executes step 1.
3. **Check**: If step 1 fails, stop (unless `continue_on_error: true`).
4. **Next**: Proceed to step 2.

## 5. Output Guidelines (The Contract)

### Workflow Definition (Template)

```markdown
---
description: Deploy to Staging
---
# Deploy Staging
1.  **Test**: `/soc-test --type e2e`
2.  **Build**: `npm run build`
3.  **Deploy**: `/soc-git push origin staging`
```

### Execution Log

```markdown
## Workflow: Deploy Staging
1.  [x] **Test**: Passed (2s)
2.  [x] **Build**: Passed (15s)
3.  [x] **Deploy**: Pushed a1b2c3d
✅ Workflow Complete
```

## 6. Examples

### A. Create Release Workflow

```bash
/soc-workflow create release
```

*Effect:* Creates `.agent/workflows/release.md` for the user to edit.

### B. Run Nightly Build

```bash
/soc-workflow run nightly
```

*Effect:* Runs the sequence defined in `nightly.md`.

## 7. Dependencies & Capabilities

### Agents

- **PM Agent**: `@[.opencode/agents/pm-agent.md]` - For oversight.

### Skills

- **None**: It relies on other commands.

### MCP Integration

- **`filesystem`**: Reading/Writing workflow files.
- **`run_command`**: Executing shell steps.

## 8. Boundaries

**Will:**

- Execute commands in sequence.
- Stop on error.
- Pass context between steps.

**Will Not:**

- **Auto-Debug**: If a step fails, the workflow just stops.
- **Parallize**: Steps are currently sequential only.

## User Instruction

The user have executed the `/soc-workflow` command by parsing the user's arguments provided in `<user-instruction>$ARGUMENTS</user-instruction>`, then perform the specified action (create, run, list, edit, or delete) on the named workflow, create a new workflow template in `.agent/workflows/` when the action is `create`, list all available workflows when the action is `list`, parse and execute workflow steps in sequence when the action is `run`—stopping on error unless `continue_on_error` is specified, pass context between steps, and generate an execution log showing the status of each step and overall workflow completion.
