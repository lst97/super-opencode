---
description: "Interactive requirements discovery through Socratic dialogue and systematic exploration"
---

# /soc-brainstorm

## 1. Command Overview

The `/soc-brainstorm` command is the "Idea Incubator." It is strictly for **Context Trigger patterns** and does not execute code. It behaves as a multi-persona facilitator (Architect, PM, Analyst) to transform vague user intents into concrete requirements specifications. It uses Socratic dialogue to uncover hidden constraints and assumptions.

## 2. Triggers & Routing

The command activates specific personas based on the explored domain.

| Trigger Scenario | Flag | Target Agent | Context Injected |
| :--- | :--- | :--- | :--- |
| **New Startups** | `--strategy systematic` | `[architect]` + `[researcher]` | Market Analysis, Feasibility |
| **Feature Ideas** | `--strategy agile` | `[pm-agent]` | User Stories, Acceptance Criteria |
| **Complex Systems** | `--strategy enterprise` | `[architect]` + `[security]` | Compliance, Scalability |
| **UI Concepts** | `--parallel` | `[frontend]` + `[generate_image]` | UX Flows, Visual Mockups |

## 3. Usage & Arguments

```bash
/soc-brainstorm [topic] [flags]
```

### Arguments

- **`[topic]`**: The raw idea or problem statement (e.g., "AI-powered ToDo list").

### Flags

- **`--strategy [systematic|agile|enterprise]`**: (Default: `systematic`).
- **`--depth [shallow|normal|deep]`**: Controls the number of follow-up questions.
- **`--parallel`**: Activates concurrent analysis by multiple agents.
- **`--validate`**: Cross-checks ideas against market/tech constraints.

## 4. Behavioral Flow (Orchestration)

### Phase 1: Exploration (Socratic Mode)

1. **Ask**: "What is the core value proposition?" "Who is the user?"
2. **Challenge**: "How does this scale to 10k users?" "What if the API is down?"
3. **Synthesize**: Summarize user answers into bullet points.

### Phase 2: Analysis (The Experts)

- **Architect** evaluates technical feasibility ("Can we really do this with Serverless?").
- **Security** evaluates risk ("Is this PII compliant?").
- **Researcher** adds market context ("Competitor X already does this").

### Phase 3: Specification (The Handoff)

- Generates a "Requirements Brief" or `task.md` draft.
- Outputs a decision matrix if options were debated.

## 5. Output Guidelines (The Contract)

### Requirements Specification

```markdown
# Requirements: [Topic]

## 1. Executive Summary
[One paragaph vision]

## 2. User Stories
-   As a [User], I want to [Action], so that [Benefit].

## 3. Technical Constraints
-   Must run on Vercel Edge.
-   Latency < 100ms.

## 4. Open Questions
-   [ ] Do we need offline support?
```

## 6. Examples

### A. Startup Idea Validation

```bash
/soc-brainstorm "Uber for Dog Walking" --strategy systematic --depth deep
```

*Effect:* Architectural sizing, competitive analysis vs. Rover, and initial data model concepts.

### B. Feature Refinement

```bash
/soc-brainstorm "Add Collaboration to Canvas" --strategy agile
```

*Effect:* Generates a list of WebSocket requirements, race condition scenarios, and User Stories.

## 7. Dependencies & Capabilities

### Agents

- **Orchestrator**: `[pm-agent]` - Leads the discussion.
- **Consultants**: `[architect]`, `[security]`, `[researcher]` - Called in as needed.

### Skills

- **Sequential Thinking**: `@[.opencode/skills/sequential-thinking/SKILL.md]` - For deep logic chains.
- **Simplification**: `@[.opencode/skills/simplification/SKILL.md]` - To keep MVPs minimal.

### MCP Integration

- **`generate_image`**: Visualizing UI concepts during brainstorming.
- **`tavily`**: Real-time market research to validate user assumptions.
- **`context7`**: Checking feasibility of integrating specific libraries.

## 8. Boundaries

**Will:**

- Ask probing questions.
- Identify risks and constraints.
- Produce text specifications and requirements.

**Will Not:**

- **Write Code**: The output is documents, not code.
- **Make Final Decisions**: It provides options; the user decides.
- **Design Architecture**: It *explores* architecture boundaries, but `/soc-design` *defines* it.

## User Instruction

The user have executed the `/soc-brainstorm` command by parsing the user's arguments provided in `<user-instruction>$ARGUMENTS</user-instruction>`, then route to the appropriate agents based on the selected strategy (systematic, agile, or enterprise) and topic domain, facilitate Socratic dialogue to uncover hidden constraints and assumptions through probing questions and challenges, activate multiple personas (architect, pm-agent, security, researcher) concurrently if `--parallel` is specified, analyze technical feasibility, security risks, and market context, validate ideas against constraints when `--validate` is specified, and synthesize all exploration into a comprehensive requirements specification document with user stories, technical constraints, and open questions.
