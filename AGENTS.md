# AGENTS.md

This file provides guidance to OpenCode when working with code in this repository.

---

## 🎯 Core Principles

### 1. Evidence-Based Development
**Never guess** — always verify with official sources before implementation:
- Use **context7** MCP for official documentation lookup
- Use **tavily** search for community solutions and patterns
- Check existing code with search before implementing
- Verify assumptions against test results

### 2. Confidence-First Implementation
Check confidence **BEFORE** starting work:
- **≥90%**: Proceed with implementation
- **70-89%**: Present alternatives, investigate more
- **<70%**: STOP — ask questions, gather more context

**ROI**: Spend 100-200 tokens on confidence check to save 5,000-50,000 on wrong direction work.

### 3. Parallel-First Execution
Use **Wave → Checkpoint → Wave** pattern:
```
Wave 1: [Read file1, file2, file3] (parallel)
    ↓
Checkpoint: Analyze together
    ↓
Wave 2: [Edit file1, file2, file3] (parallel)
```
**Result**: 3.5x faster than sequential execution.

### 4. Self-Correction Protocol
When errors occur:
1. **STOP** — Never retry the same approach immediately
2. **Investigate** — Research root cause with documentation
3. **Hypothesize** — Form theory with evidence
4. **Redesign** — New approach must differ from failed one
5. **Execute** — Implement based on understanding
6. **Learn** — Document for future prevention

---

## 🛠️ Development Workflow

### Starting Any Task
1. Read AGENTS.md and relevant documentation
2. Search for existing implementations (avoid duplicates)
3. Run confidence check (see `.opencode/skills/confidence-check/`)
4. Only proceed if confidence ≥ 70%

### During Implementation
- Use parallel execution where possible
- Document non-obvious decisions inline
- Run tests frequently to catch errors early
- Checkpoint progress for complex tasks

### After Implementation
1. Validate all tests pass
2. Run self-check protocol (`.opencode/skills/self-check/`)
3. Document new patterns discovered
4. Update relevant documentation

---

## 📏 Quality Standards

### Code Quality
- All public functions need docstrings
- Use type hints where supported
- Follow project's existing patterns
- Include usage examples for complex functions

### Documentation Quality
- ✅ **Current**: Include "Last Verified" dates
- ✅ **Minimal**: Necessary information only
- ✅ **Clear**: Concrete examples included
- ✅ **Practical**: Copy-paste ready

### Testing Standards
- Write tests for new functionality
- Aim for >80% coverage on new code
- Include edge cases and error conditions
- Run full test suite before major changes

---

## 🔄 PDCA Cycle

For significant implementations, follow Plan-Do-Check-Act:

### Plan (Hypothesis)
- What are we implementing?
- Why this approach?
- What are success criteria?

### Do (Experiment)
- Execute the plan
- Track progress and deviations
- Record errors and solutions

### Check (Evaluate)
- Did we meet success criteria?
- What worked well?
- What failed?

### Act (Improve)
- Success → Extract pattern for reuse
- Failure → Document prevention checklist
- Either → Update knowledge base

---

## 🚫 Anti-Patterns

**Never do these:**
- ❌ Retry same failing approach without investigation
- ❌ "Tests pass" without showing actual output
- ❌ Implement before checking for duplicates
- ❌ Skip documentation due to time pressure
- ❌ Ignore warnings ("probably fine")
- ❌ Use "probably works" language

---

## 📁 Project Structure

```
.opencode/
├── agents/             # Specialized agent personas
├── commands/           # Slash command definitions
└── skills/             # Reusable skill modules
    ├── confidence-check/
    ├── self-check/
    └── reflexion/

AGENTS.md               # Core principles and guidelines
opencode.json           # OpenCode configuration
```

---

## 🤖 Agent System

When complex tasks require specialized expertise, delegate to appropriate agent:

| Agent | Purpose |
|-------|---------|
| **pm-agent** | Project orchestration, PDCA cycles, documentation |
| **architect** | System design, architecture, technical strategy |
| **backend** | APIs, databases, server-side logic |
| **frontend** | UI/UX, components, styling |
| **security** | Security review, threat modeling |
| **quality** | Testing, code review |
| **researcher** | Deep research, fact-checking |
| **writer** | Technical documentation |
| **reviewer** | Code review, quality assurance |
| **optimizer** | Performance optimization |

---

## 🔧 MCP Integration

The framework assumes the following MCP servers are available for optimal performance:
- **context7**: Official documentation lookup
- **serena**: Codebase analysis and navigation
- **tavily**: Web search for research
- **filesystem**: File system access
- **sequential-thinking**: Multi-step reasoning

---

*This document should be read at session start. Update it when global patterns are discovered.*
