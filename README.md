# Super-OpenCode Framework

A comprehensive agent framework and installer for the OpenCode CLI ecosystem, designed to streamline development workflows with specialized agents, reusable skills, and structured command patterns.

## Overview

Super-OpenCode provides a structured framework for AI-assisted software development, featuring:

- **Specialized Agent Personas**: Pre-configured agents for different domains (Backend, Frontend, Architecture, Security, QA, etc.)
- **Reusable Skills**: Modular capabilities for confidence checking, self-correction, debugging, and more
- **Slash Commands**: Pre-built workflows for common development tasks
- **MCP Integration**: Built-in support for Model Context Protocol servers
- **Quality Standards**: Enforced best practices and documentation standards

## Installation

### Prerequisites

- Node.js 18+ 
- npm, pnpm, or yarn

### Quick Install

```bash
npm install -g super-opencode
```

Then run the interactive installer:

```bash
super-opencode
```

The installer will guide you through:
1. Choosing installation scope (global or project)
2. Selecting components to install (agents, commands, skills, core)
3. Configuring optional MCP servers (Context7, Serena, Tavily, etc.)

### Manual Install

After npm install, the framework files will be available at:
- **Global**: `~/.opencode/`
- **Project**: `./opencode.json` in your project directory

## Features

### Agent System

Super-OpenCode includes specialized agents for different domains:

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

### Skills Framework

Reusable capabilities that agents can invoke:

- **confidence-check**: Pre-execution risk assessment
- **self-check**: Post-implementation validation
- **security-audit**: OWASP Top 10 vulnerability detection
- **reflexion**: Post-action analysis and learning
- **debug-protocol**: Root cause analysis workflow
- **simplification**: Complexity reduction

### Slash Commands

Pre-built workflows for common tasks:

- `/soc-implement` - Code implementation with best practices
- `/soc-design` - System design and architecture
- `/soc-test` - Test generation and execution
- `/soc-research` - Deep research and documentation
- `/soc-review` - Code review and quality checks
- `/soc-brainstorm` - Idea generation and problem-solving
- `/soc-analyze` - Codebase analysis
- `/soc-cleanup` - Code cleanup and refactoring
- `/soc-explain` - Code explanation
- `/soc-workflow` - PDCA workflow management
- `/soc-pm` - Project management tasks
- `/soc-git` - Git operations
- `/soc-improve` - Continuous improvement
- `/soc-help` - Help and documentation

### MCP Server Integration

The framework supports configuration of various MCP servers:

**Recommended (Core)**:
- Context7 - Official documentation lookup
- Serena - Codebase analysis and navigation
- Tavily Search - Web search for research
- Filesystem - File system access
- Sequential Thinking - Multi-step reasoning

**Optional**:
- GitHub - GitHub API integration
- SQLite - Database operations
- Chrome DevTools - Browser debugging
- Playwright - Browser automation

## Project Structure

```
super-opencode/
├── src/
│   └── cli.ts              # Main installer CLI
├── .opencode/
│   ├── agents/             # Agent persona definitions
│   │   ├── architect.md
│   │   ├── backend.md
│   │   ├── frontend.md
│   │   └── ...
│   ├── commands/           # Slash command definitions
│   │   ├── soc-implement.md
│   │   ├── soc-design.md
│   │   └── ...
│   └── skills/             # Reusable skill modules
│       ├── confidence-check/
│       ├── self-check/
│       ├── security-audit/
│       └── ...
├── AGENTS.md               # Core principles and guidelines
├── package.json
├── tsconfig.json
└── biome.json              # Linting configuration
```

## Usage

### After Installation

1. **Read AGENTS.md** - This file contains core principles, development workflows, and quality standards
2. **Configure MCP Servers** - Set up the MCP servers you need for your workflow
3. **Use Slash Commands** - Invoke the appropriate command for your task

### Example Workflows

#### Implement a Feature
```bash
/soc-implement "User Authentication" --agent backend
```

#### Design a System
```bash
/soc-design "Microservices Architecture"
```

#### Code Review
```bash
/soc-review
```

#### Research
```bash
/soc-research "Best practices for React state management"
```

## Development Workflow

Super-OpenCode enforces a structured development approach:

### 1. Evidence-Based Development
- Always verify with official sources
- Use context7 MCP for documentation lookup
- Check existing code before implementing
- Never guess or make assumptions

### 2. Confidence-First Implementation
- Check confidence before starting work
- **≥90%**: Proceed with implementation
- **70-89%**: Investigate more, present alternatives
- **<70%**: STOP - ask questions, gather context

### 3. Parallel-First Execution
- Use Wave → Checkpoint → Wave pattern
- Batch read operations together
- Analyze together before editing
- 3.5x faster than sequential execution

### 4. Self-Correction Protocol
When errors occur:
1. STOP - Don't retry immediately
2. INVESTIGATE - Research root cause
3. HYPOTHESIZE - Form theory with evidence
4. REDESIGN - New approach
5. EXECUTE - Implement based on understanding
6. LEARN - Document for prevention

## Configuration

### OpenCode Configuration

After installation, configuration is stored in:
- **Global**: `~/.config/opencode/opencode.json`
- **Project**: `./opencode.json`

### MCP Server Configuration

MCP servers are configured in the `mcp` section of your config:

```json
{
  "mcp": {
    "context7": {
      "type": "local",
      "command": ["npx", "-y", "@upstash/context7-mcp"]
    },
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/path/to/project"]
    }
  }
}
```

## Quality Standards

### Code Quality
- All public functions require docstrings
- Use type hints where supported
- Follow existing project patterns
- Include usage examples for complex functions

### Documentation Quality
- Current with "Last Verified" dates
- Minimal but necessary information
- Clear with concrete examples
- Practical and copy-paste ready

### Testing Standards
- Write tests for new functionality
- Aim for >80% code coverage
- Include edge cases and error conditions
- Run full test suite before major changes

## Building and Development

```bash
# Install dependencies
npm install

# Build
npm run build

# Lint
npm run lint

# Format
npm run format
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Read AGENTS.md to understand the framework philosophy
2. Follow existing code patterns and quality standards
3. Add tests for new functionality
4. Update documentation as needed
5. Submit pull requests with clear descriptions

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Credits

Created by [lst97](https://github.com/lst97)

## Related Links

- [OpenCode CLI](https://opencode.ai)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [MCP Server Registry](https://github.com/modelcontextprotocol/servers)

---

*Built with ❤️ for the AI-assisted development community*
