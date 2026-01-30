---
description: Code explanation and understanding
---

# /soc-explain

## 1. Command Overview

The `/soc-explain` command is the "Tutor." It translates complex code, errors, or concepts into natural language. It adapts its depth to the user's needs, from simple analogies to expert technical deep-dives. It generates documentation that can be saved.

## 2. Triggers & Routing

The command uses the `writer` agent effectively to synthesize information.

| Trigger Scenario | Flag | Target Agent | Style |
| :--- | :--- | :--- | :--- |
| **High Level** | `--depth simple` | `[writer]` | Analogies, non-technical |
| **Standard** | `--depth detailed` | `[writer]` | Code logic, flow, syntax |
| **Deep Dive** | `--depth expert` | `[architect]` | Memory, performance, edge cases |

## 3. Usage & Arguments

```bash
/soc-explain [target] [flags]
```

### Arguments

- **`[target]`**: Code snippet, file path, error message, or concept (e.g., "Dependency Injection").

### Flags

- **`--depth [simple|detailed|expert]`**: (Default: `detailed`).
- **`--context [file]`**: Add extra context for better explanation.

## 4. Behavioral Flow (Orchestration)

### Phase 1: Analysis

1. **Parse**: Is the target a file, a string, or a concept?
2. **Context**: If it's an error, where did it come from? If it's code, what language?

### Phase 2: Synthesis (The Lesson)

- **Analogy**: "Think of a Promise like a pizza buzzer..."
- **Technical**: "It wraps the value in a microtask queue..."
- **Example**: "Here is how you use it:"

### Phase 3: Formatting

- Structure with clear Headers.
- Use Code Blocks for syntax.
- Highlight "Key Takeaways."

## 5. Output Guidelines (The Contract)

### Explanation Document

```markdown
## Explanation: [Topic]

### Summary
[1-2 sentences. The TL;DR.]

### Conceptual Analogy (If Simple)
[Mundane comparison]

### Technical Breakdown
-   **Component A**: Does X.
-   **Component B**: Does Y.

### Code Example
```javascript
// Before
badCode()

// After (corrected/explained)
goodCode()
```

### Key Takeaways

1. [Point 1]
2. [Point 2]

```

## 6. Examples

### A. Async/Await (Expert)
```bash
/soc-explain "How Node Event Loop works" --depth expert
```

*Effect:* Explains Phases (Timers, Poll, Check), Microtasks vs Macrotasks, and `process.nextTick`.

### B. Error Parsing

```bash
/soc-explain "TypeError: Cannot read property 'map' of undefined"
```

*Effect:* Explains that the array is missing, helps identify the source variable, suggests Optional Chaining (`?.`).

## 7. Dependencies & Capabilities

### Agents

- **Writer**: `@[.opencode/agents/writer.md]` - Primary explainer.
- **Architect**: `@[.opencode/agents/architect.md]` - For system-level concepts.

### Skills

- **Simplification**: `@[.opencode/skills/simplification/SKILL.md]` - To de-jargonize complex topics.

### MCP Integration

- **`context7`**: Fetching official docs to cite sources.
- **`read_file`**: Reading the full content of the file being explained.

## 8. Boundaries

**Will:**

- Explain *why* code works.
- Suggest *best practices*.
- Debug *logic* errors via explanation.

**Will Not:**

- **Write the Fix**: It explains the fix; `/soc-implement` writes it.
- **Execute Code**: It analyzes static text.

## User Instruction

The user have executed the `/soc-explain` command by parsing the user's arguments provided in `<user-instruction>$ARGUMENTS</user-instruction>`, then analyze the specified target (code snippet, file path, error message, or concept) to determine its type and context, route to the appropriate agent based on depth level—writer agent for simple analogies and detailed explanations, or architect agent for expert-level system concepts—adapt the explanation style to match the requested depth (simple with analogies, detailed with code logic, or expert with performance and edge cases), incorporate additional context files if provided via `--context`, and generate a structured explanation document with summary, technical breakdown, code examples, and key takeaways.
