---
description: Project management and orchestration
---

# /soc-pm

## 1. Command Overview
The `/soc-pm` command is the "Orchestrator." It manages the high-level state of the project. It uses the PDCA (Plan-Do-Check-Act) cycle to break down complex goals into `tasks`, track progress, and unblock other agents. It is the owner of `task.md`.

## 2. Triggers & Routing
The command is the primary interface for the `pm-agent`.

| Trigger Scenario | Flag | Target Agent | Action |
| :--- | :--- | :--- | :--- |
| **New Project** | `plan` | `[pm-agent]` | Create `task.md` |
| **Progress Check** | `status` | `[pm-agent]` | Read/Update `task.md` |
| **Verify Work** | `review` | `[pm-agent]` | Check deliverables |

## 3. Usage & Arguments
```bash
/soc-pm [action] [target] [flags]
```

### Arguments
-   **`[action]`**: `plan`, `status`, `review`, `checkpoint`.
-   **`[target]`**: (Optional) Specific feature or milestone.

### Flags
-   **`--detail`**: Show full task history.

## 4. Behavioral Flow (Orchestration)

### Phase 1: Plan (The Roadmap)
1.  **Analyze**: Read User Request -> Break into Epics/Stories.
2.  **Document**: updates `task.md` with checkboxes `[ ]`.

### Phase 2: Do (Tracking)
-   Monitors tool usage.
-   Updates task status to `[/]` (In Progress) or `[x]` (Done).

### Phase 3: Check (The Audit)
-   **Review**: Did we meet the acceptance criteria?
-   **Reflect**: Use `reflexion` skill if blocked.

## 5. Output Guidelines (The Contract)

### Project Status Report
```markdown
## Project Status: [Phase]

### Progress
-   **Completed**: 3/5 Tasks (60%)
-   **Current Focus**: Implementing API Auth

### Task List
-   [x] Setup DB Schema
-   [/] **Implement Login Route** (Active)
-   [ ] Write Tests

### Blockers
-   Waiting for API Key from user.
```

## 6. Examples

### A. Initial Planning
```bash
/soc-pm plan "Build User Dashboard"
```
*Effect:* Creates `task.md` with breakdown: "Design UI", "Setup API", "Integrate Frontend".

### B. Status Update
```bash
/soc-pm status
```
*Effect:* Reads current state and summarizes what has been done vs what is left.

## 7. Dependencies & Capabilities

### Agents
-   **PM Agent**: `@[.opencode/agents/pm-agent.md]` - Self-referential.
-   **All Agents**: Delegates work to them.

### Skills
-   **Reflexion**: `@[.opencode/skills/reflexion/SKILL.md]` - For unblocking the team.

### MCP Integration
-   **`filesystem`**: Managing `task.md` and `implementation_plan.md`.

## 8. Boundaries

**Will:**
-   Manage `task.md`.
-   Delegate tasks to other agents.
-   Track overall progress.

**Will Not:**
-   **Write Code**: It manages those who write code.
-   **Solve Technical Bugs**: It assigns `[backend]` or `[quality]` to solve them.
