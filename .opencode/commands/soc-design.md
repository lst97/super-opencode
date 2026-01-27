---
description: "Design system architecture, APIs, and component interfaces with comprehensive specifications"
---

# /soc-design

## 1. Command Overview
The `/soc-design` command orchestrates the creation of technical specifications, architecture diagrams, and API contracts. It transitions a project from "brainstorming" to "blueprint." It delegates specific design tasks to the `architect`, `backend`, or `frontend` agents, ensuring all designs are validated against the "Ultrathink" protocol before any code is written.

## 2. Triggers & Routing
The command routes to specialized sub-agents based on the `--type` flag.

| Trigger Scenario | Flag | Target Agent | Context Injected |
| :--- | :--- | :--- | :--- |
| **System Architecture** | `--type architecture` | `[architect]` | Scalability, Cloud Limits, ADR templates |
| **API Contract** | `--type api` | `[backend]` | REST/GraphQL patterns, Auth headers |
| **Database Schema** | `--type database` | `[backend]` | Normalization rules, Migration templates |
| **UI Component** | `--type component` | `[frontend]` | Accessibility (WCAG), Design Tokens |

## 3. Usage & Arguments
```bash
/soc-design [target] [flags]
```

### Arguments
-   **`[target]`**: The feature, system, or component to design (e.g., "User Auth", "Payment Gateway").

### Flags
-   **`--type [type]`**: **MANDATORY**. One of `architecture`, `api`, `database`, `component`.
-   **`--format [format]`**:
    -   `spec`: Textual specification with requirements (default).
    -   `diagram`: Mermaid or ASCII visualization.
    -   `code`: Interface definitions (TypeScript interfaces, SQL DDL).

## 4. Behavioral Flow (Orchestration)

### Phase 1: Context Analysis
1.  **Read**: Examines existing `task.md`, `README.md`, and any previous brainstorming artifacts.
2.  **Constraint Check**: Identifies tech stack limitations (e.g., "We are using Next.js on Vercel").

### Phase 2: Design Generation
The command prompts the target agent:
> "Agent **[Name]**, create a **[Type]** design for **[Target]**.
> Standard: **Intentional Minimalism**.
> Output: **[Format]**."

### Phase 3: Validation (Reflexion)
-   Does the design violate "Zero Trust"?
-   Is the schema normalized?
-   Are the UI components accessible?

## 5. Output Guidelines (The Contract)

### A. Architecture Decision Record (ADR)
```markdown
# ADR: [Title]
## Context
[Problem description]
## Decision
[Solution chosen]
## Consequences
[Trade-offs]
```

### B. API Specification
```typescript
interface CreateUserRequest {
  email: string; // @format email
  role?: 'admin' | 'user';
}
```

### C. Database Schema (Prisma/SQL)
```prisma
model User {
  id    String @id @default(cuid())
  email String @unique
}
```

## 6. Examples

### A. System Architecture
```bash
/soc-design user-management --type architecture --format diagram
```
*Effect:* Triggers `architect` to draw a high-level system diagram including Auth0, Postgres, and Next.js linkage.

### B. API Design
```bash
/soc-design payment-api --type api --format spec
```
*Effect:* Triggers `backend` to define `POST /api/payments` with request/response schemas and error codes.

## 7. Dependencies & Capabilities
### Agents
-   **Architecture**: `@[.opencode/agents/architect.md]` - System design and patterns.
-   **API/DB**: `@[.opencode/agents/backend.md]` - Schema and interface definitions.
-   **UI/UX**: `@[.opencode/agents/frontend.md]` - Component and interaction design.
-   **Research**: `@[.opencode/agents/researcher.md]` - Competitive analysis and best practices.

### Skills
-   **Simplification**: `@[.opencode/skills/simplification/SKILL.md]` - Ensuring designs are not over-engineered.
-   **Reflexion**: `@[.opencode/skills/reflexion/SKILL.md]` - Critiquing design decisions.

### MCP Integration
-   **`generate_image`**: Used to create UI mockups, architectural diagrams, and visual flows.
-   **`context7`**: Accessing latest documentation for chosen frameworks (e.g., "Next.js App Router patterns").
-   **`tavily`**: Researching industry standards and existing solutions.

## 8. Boundaries

**Will:**
-   Create comprehensive design specifications.
-   Generate interface definitions (contracts).
-   Validate designs against architectural constraints.

**Will Not:**
-   **Write Implementation Code**: Use `/soc-implement` for that.
-   **Deploy Infrastructure**: Use Terraform/SOC agents for that.
-   **Guess Requirements**: If ambiguous, it will ask for clarification.
