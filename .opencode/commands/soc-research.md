---
description: Deep web research and documentation lookup
---

# /soc-research

## 1. Command Overview

The `/soc-research` command is the "Archive." It scours the web and internal docs to find definitive truth. It operates on the "Cite or Die" principle: every claim must optionally be backed by a source. It does not hallucinate; it verifies.

## 2. Triggers & Routing

The command routes to the `researcher` agent.

| Trigger Scenario | Flag | Target Agent | Tool Used |
| :--- | :--- | :--- | :--- |
| **Quick Fact** | `--depth quick` | `[researcher]` | DuckDuckGo/Tavily |
| **Docs Lookup** | `[topic]` | `[researcher]` | `context7` |
| **Deep Dive** | `--depth deep` | `[researcher]` | Recursive Search |

## 3. Usage & Arguments

```bash
/soc-research [topic] [flags]
```

### Arguments

- **`[topic]`**: The question or technology to investigate.

### Flags

- **`--depth [quick|standard|deep]`**: (Default: `standard`).
- **`--domain [url]`**: Restrict search to specific site (e.g., `github.com`).

## 4. Behavioral Flow (Orchestration)

### Phase 1: Parsing

1. **Decompose**: Break query into keywords.
2. **Select**: Choose tool (`tavily` for web, `context7` for docs).

### Phase 2: Execution (The Hunt)

- **Broad Search**: Find candidate URLs.
- **Deep Read**: Scrape content.
- **Synthesize**: Cross-reference facts to find consensus.

### Phase 3: Reporting

- Construct "Review of Literature."
- Flag conflicting info ("Source A says X, Source B says Y").

## 5. Output Guidelines (The Contract)

### Research Report

```markdown
## Research: [Topic]

### Executive Summary
[Direct Answer]

### Key Findings
1.  **[Fact 1]**: [Detail]
    *   *Source*: [Link]
2.  **[Fact 2]**: [Detail]

### Code Patterns (if applicable)
```typescript
// Verified pattern from docs
const x = new Library();
```

### Conflicting Info

- StackOverflow suggests X, but Official Docs say Y (Deprecated).

```

## 6. Examples

### A. Library Selection
```bash
/soc-research "Best React form library 2025" --depth deep
```

*Effect:* Compares React Hook Form vs TanStack Form based on bundle size and weekly downloads.

### B. Bug Hunting

```bash
/soc-research "Prisma error P2002" --domain github.com
```

*Effect:* Finds specific GitHub issues related to Unique Constraint violations.

## 7. Dependencies & Capabilities

### Agents

- **Researcher**: `@[.opencode/agents/researcher.md]` - Primary persona.

### Skills

- **Sequential Thinking**: `@[.opencode/skills/sequential-thinking/SKILL.md]` - For resolving conflicts.

### MCP Integration

- **`tavily`**: Real-time web search.
- **`context7`**: Documentation retrieval.

## 8. Boundaries

**Will:**

- Find official documentation.
- Summarize community consensus.
- Provide direct links.

**Will Not:**

- **Execute Info**: It finds the code, but does not run it.
- **Make Decisions**: It informs decisions, but `architect` decides.

## User Instruction

The user have executed the `/soc-research` command by parsing the user's arguments provided in `<user-instruction>$ARGUMENTS</user-instruction>`, then route to the researcher agent to investigate the specified topic, selecting the appropriate research depth (quick, standard, or deep) and tools (tavily for web search, context7 for documentation) based on flags and topic type, decompose the query into searchable keywords, gather information from multiple sources while cross-referencing facts to find consensus, and synthesize findings into a comprehensive research report with cited sources, key findings, code patterns, and flagging of any conflicting information.
