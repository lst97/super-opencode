---
description: Help and command reference
---

# /soc-help

## 1. Command Overview
The `/soc-help` command is the "Librarian." It serves as the primary documentation interface for the agent system. It explains *how* to use the other commands, details what each agent does, and lists available skills. It uses the `researcher` agent to find answers within the system's own documentation.

## 2. Triggers & Routing
The command is self-contained but may use `researcher` for deep queries.

| Trigger Scenario | Flag | Target Agent | Action |
| :--- | :--- | :--- | :--- |
| **Command Syntax** | `[command]` | `[System]` | Show usage and flags |
| **Agent Roles** | `[agent]` | `[System]` | Show persona description |
| **Workflow Guide** | `[topic]` | `[researcher]` | Summarize best practices |

## 3. Usage & Arguments
```bash
/soc-help [target] [flags]
```

### Arguments
-   **`[target]`**: (Optional) Specific command (`implement`), agent (`backend`), or topic (`workflows`). Default: Shows index.

### Flags
-   **`--verbose`**: Show detailed descriptions and hidden flags.

## 4. Behavioral Flow (Orchestration)

### Phase 1: Lookup
1.  **Index**: Check if target is a known Command, Agent, or Skill.
2.  **Search**: If unknown, grep `.opencode/` documentation for keywords.

### Phase 2: Formatting
-   **Structure**: Group by Category (Workflow vs Skill).
-   **Clarity**: Show "Quick Start" snippets.

## 5. Output Guidelines (The Contract)

### Help Document
```markdown
## Help: [Target]

### Description
[Brief summary]

### Usage
`[Command Pattern]`

### Key Features
-   Feature 1
-   Feature 2

### Related Commands
-   `/related-command`
```

## 6. Examples

### A. Command Help
```bash
/soc-help implement
```
*Effect:* Displays usage for `/soc-implement`, including flags like `--agent` and `--test`.

### B. Agent Role
```bash
/soc-help backend
```
*Effect:* Shows the `backend` agent's persona, including "Prime Directives" and "Restrictions."

## 7. Dependencies & Capabilities

### Agents
-   **Researcher**: `@[.opencode/agents/researcher.md]` - For finding unstructured help.

### Skills
-   **None**: This is a read-only command.

### MCP Integration
-   **`filesystem`**: Reading documentation files.

## 8. Boundaries

**Will:**
-   Explain system capabilities.
-   List available tools.
-   Provide syntax examples.

**Will Not:**
-   **Execute Commands**: It only explains them.
-   **Hallucinate Features**: Only lists what exists in `.opencode/`.
