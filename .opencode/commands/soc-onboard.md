---
description: "Project initialization, tech stack setup, and development environment scaffolding"
---

# /soc-onboard

## 1. Command Overview

The `/soc-onboard` command is the "Project Bootstrapper." It transforms an empty repository (or vague idea) into a fully-configured development environment ready for the first commit. It handles repository setup, tech stack selection, development environment configuration, and initial project structure scaffolding. This is always the **first command** for any new project.

## 2. Triggers & Routing

The command activates onboarding modes based on project type and maturity.

| Trigger Scenario | Flag | Target Agent | Context Injected |
| :--- | :--- | :--- | :--- |
| **New Project** | `--type new` | `[architect]` + `[pm-agent]` | Greenfield setup, Tech selection |
| **Existing Repo** | `--type existing` | `[architect]` | Analysis, Documentation, Setup |
| **Team Onboarding** | `--type team` | `[pm-agent]` | Developer guides, Standards, Workflows |
| **Tech Stack Setup** | `--type stack` | `[architect]` + `[backend]` + `[frontend]` | Framework selection, Configuration |

## 3. Usage & Arguments

```bash
/soc-onboard [project-name] [flags]
```

### Arguments

- **`[project-name]`**: Name of the project (e.g., "my-app", "api-service"). Used for repo naming, package naming, etc.

### Flags

- **`--type [new|existing|team|stack]`**: **MANDATORY**. Specifies onboarding phase.
- **`--template [template]`**: Starter template to use (e.g., "nextjs-fullstack", "express-api", "react-native").
- **`--stack [stack]`**: Tech stack preset (e.g., "typescript-react-node", "python-fastapi", "go-microservices").
- **`--package-manager [npm|yarn|pnpm|bun]`**: Package manager preference (auto-detected if not specified).
- **`--git [true|false]`**: Initialize git repository (default: true).
- **`--install`**: Automatically install dependencies after setup.
- **`--ci [provider]`**: CI/CD provider setup (e.g., "github-actions", "gitlab-ci").

## 4. Behavioral Flow (Orchestration)

### Phase 1: Analysis & Planning

#### For New Projects (`--type new`):
1. **Requirements Gathering**: Ask clarifying questions if stack/template not provided.
2. **Tech Stack Selection**: Recommend stack based on project type.
3. **Architecture Preview**: Generate high-level folder structure.
4. **Package Manager Detection**: Analyze environment and recommend best option.

#### For Existing Repos (`--type existing`):
1. **Codebase Analysis**: Parse existing structure, identify patterns.
2. **Documentation Audit**: Check for README, CONTRIBUTING, docs.
3. **Setup Verification**: Verify dependencies install, tests run, builds succeed.
4. **Gap Analysis**: Identify missing configuration files, linting, etc.

### Phase 2: Environment Setup

#### Repository Initialization:
- Create directory structure.
- Initialize git (if `--git true`).
- Create `.gitignore` appropriate for stack.
- Set up branch protection rules template.

#### Tech Stack Configuration:
- **Frontend**: React/Next.js/Vue config, Tailwind setup, TypeScript.
- **Backend**: Express/FastAPI/Gin setup, database config, API structure.
- **Shared**: ESLint, Prettier, TypeScript, Husky pre-commit hooks.
- **Testing**: Jest/Vitest/Playwright configuration.

#### Package Manager Setup (via `package-manager` skill):
- Detect available package managers (npm, yarn, pnpm, bun).
- Check version compatibility.
- Create lockfile (respecting user's preference).
- Configure workspace if monorepo detected.

### Phase 3: Documentation & Templates

- **README.md**: Project description, setup instructions, scripts.
- **CONTRIBUTING.md**: PR process, coding standards, commit conventions.
- **AGENTS.md**: OpenCode configuration for the project (this is crucial!).
- **LICENSE**: Template license file.
- **.env.example**: Environment variable template.

### Phase 4: Verification

- Run initial build to verify setup.
- Run linting to ensure configuration valid.
- Run tests (should pass with 0 tests initially).
- Generate onboarding completion report.

## 5. Output Guidelines (The Contract)

### Project Structure Output

```
my-app/
├── .github/
│   └── workflows/
│       └── ci.yml              # CI/CD pipeline
├── .husky/                     # Git hooks
│   └── pre-commit
├── .opencode/                  # OpenCode configuration
│   ├── agents/
│   │   └── custom-agent.md
│   └── memory/
│       └── patterns.md
├── docs/
│   ├── ADR/                    # Architecture Decision Records
│   ├── api/
│   └── setup.md
├── src/
│   ├── components/             # UI components
│   ├── lib/                    # Utilities, helpers
│   ├── hooks/                  # Custom React hooks
│   ├── types/                  # TypeScript types
│   └── app/                    # App routes/pages
├── tests/
│   ├── unit/
│   └── e2e/
├── .env.example
├── .eslintrc.js
├── .gitignore
├── .prettierrc
├── AGENTS.md                   # OpenCode project guide
├── CONTRIBUTING.md
├── LICENSE
├── package.json
├── README.md
├── tsconfig.json
└── vite.config.ts
```

### Onboarding Report Template

```markdown
# Project Onboarding Report: [Project Name]

## Summary
**Type**: New Project  
**Template**: nextjs-fullstack  
**Stack**: TypeScript + React + Next.js + Node.js  
**Package Manager**: pnpm (v8.15.0)  
**Status**: ✅ COMPLETE

## Tech Stack Details

### Frontend
- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript 5.3
- **Styling**: Tailwind CSS + shadcn/ui
- **State**: Zustand + React Query
- **Testing**: Vitest + React Testing Library + Playwright

### Backend
- **Runtime**: Node.js 20 LTS
- **Framework**: Next.js API Routes
- **Database**: PostgreSQL (Prisma ORM)
- **Auth**: NextAuth.js
- **Validation**: Zod

### DevOps
- **CI/CD**: GitHub Actions
- **Linting**: ESLint + Prettier
- **Hooks**: Husky + lint-staged
- **Type Checking**: TypeScript strict mode

## Package Manager Selection
**Selected**: pnpm  
**Rationale**: 
- ✅ Disk space efficient (content-addressable store)
- ✅ Fast installation (parallelized)
- ✅ Strict dependency resolution (prevents phantom deps)
- ✅ Workspace support built-in
- ✅ Lockfile reliable and deterministic

**Alternatives Considered**:
- npm: Slower, larger node_modules
- yarn: Good but pnpm preferred for monorepos
- bun: Fast but newer, less ecosystem maturity

## Generated Files

### Configuration
- ✅ package.json (with scripts)
- ✅ tsconfig.json (strict mode)
- ✅ tailwind.config.ts
- ✅ next.config.js
- ✅ .eslintrc.js (recommended + typescript)
- ✅ .prettierrc (consistent formatting)
- ✅ vite.config.ts (for vitest)
- ✅ playwright.config.ts

### Project Structure
- ✅ src/app/ (Next.js app router)
- ✅ src/components/ui/ (shadcn base)
- ✅ src/lib/ (utilities)
- ✅ src/hooks/ (custom hooks)
- ✅ src/types/ (global types)
- ✅ tests/unit/ (Vitest tests)
- ✅ tests/e2e/ (Playwright tests)

### Documentation
- ✅ README.md (setup, scripts, structure)
- ✅ CONTRIBUTING.md (PR process, standards)
- ✅ AGENTS.md (OpenCode configuration)
- ✅ LICENSE (MIT)
- ✅ .env.example (environment variables)

### OpenCode Integration
- ✅ .opencode/agents/ (custom agent definitions)
- ✅ .opencode/memory/ (project patterns)

## Verification Results

| Check | Command | Status |
|:------|:--------|:------:|
| Dependencies Install | pnpm install | ✅ |
| Type Check | pnpm typecheck | ✅ |
| Lint | pnpm lint | ✅ |
| Build | pnpm build | ✅ |
| Test | pnpm test | ✅ (0 tests) |

## Next Steps

1. **Configure Environment**: Copy `.env.example` to `.env.local` and fill in values.
2. **Database Setup**: Run `pnpm db:setup` to initialize PostgreSQL.
3. **First Feature**: Use `/soc-brainstorm` to plan your first feature.
4. **Team Onboarding**: Share this repo—team members just run `pnpm install`.

## Quick Commands

```bash
# Development
pnpm dev              # Start dev server
pnpm test             # Run unit tests
pnpm test:e2e         # Run E2E tests

# Code Quality
pnpm lint             # Run ESLint
pnpm lint:fix         # Fix auto-fixable issues
pnpm format           # Run Prettier
pnpm typecheck        # TypeScript check

# Database
pnpm db:generate      # Generate Prisma client
pnpm db:migrate       # Run migrations
pnpm db:studio        # Open Prisma Studio
```
```

## 6. Examples

### A. New Full-Stack Project

```bash
/soc-onboard "my-saas-app" --type new --template nextjs-fullstack --package-manager pnpm --ci github-actions
```

*Effect:* Creates complete Next.js 14 project with TypeScript, Tailwind, Prisma, PostgreSQL, NextAuth, testing setup, CI/CD, and OpenCode configuration.

### B. API-Only Project

```bash
/soc-onboard "payment-api" --type new --stack express-typescript --package-manager npm
```

*Effect:* Sets up Express.js API with TypeScript, Zod validation, Prisma ORM, Swagger docs, and testing framework.

### C. Existing Repository Analysis

```bash
/soc-onboard "legacy-project" --type existing
```

*Effect:* Analyzes existing codebase, identifies tech stack, verifies setup, and generates missing configuration files and documentation.

### D. Team Onboarding Guide

```bash
/soc-onboard "team-setup" --type team
```

*Effect:* Creates comprehensive team onboarding documentation: development standards, PR process, architecture overview, and troubleshooting guides.

## 7. Dependencies & Capabilities

### Agents

- **Architecture Lead**: `[architect]` - Tech stack selection and project structure.
- **PM Coordinator**: `[pm-agent]` - Documentation standards and team workflows.
- **Backend Setup**: `[backend]` - Server configuration, database setup.
- **Frontend Setup**: `[frontend]` - UI framework configuration, styling.

### Skills

- **Package Manager**: `@[.opencode/skills/package-manager/SKILL.md]` - **MANDATORY** for detecting and configuring the optimal package manager.
- **Confidence Check**: `@[.opencode/skills/confidence-check/SKILL.md]` - Validates setup choices.
- **Self Check**: `@[.opencode/skills/self-check/SKILL.md]` - Verifies everything works after setup.

### MCP Integration

- **`tavily`**: Research latest framework versions and best practices.
- **`context7`**: Access framework documentation for setup instructions.
- **`filesystem`**: Create directory structure and files.

## 8. Boundaries

**Will:**

- Initialize new projects with complete tech stack.
- Analyze and document existing repositories.
- Set up development environments with proper tooling.
- Configure package managers (auto-detect or user preference).
- Generate project documentation (README, CONTRIBUTING, AGENTS.md).
- Verify setup by running builds and tests.

**Will Not:**

- **Deploy to Production**: Only sets up local development environment.
- **Write Business Logic**: Creates scaffolding only—no feature implementation.
- **Choose Without Consent**: Recommends stack but asks for confirmation.
- **Override Existing Files**: Warns and backs up before overwriting.
- **Skip Verification**: Always runs checks to ensure setup works.

## User Instruction

The user have executed the `/soc-onboard` command by parsing the user's arguments provided in `<user-instruction>$ARGUMENTS</user-instruction>`, then route to the appropriate onboarding type (new, existing, team, or stack), for new projects: gather requirements, recommend and confirm tech stack, for existing projects: analyze codebase structure and configuration, use the `package-manager` skill to detect and configure the optimal package manager (never assume npm), create complete directory structure with configuration files, set up linting, testing, and CI/CD tooling, generate all documentation (README, CONTRIBUTING, AGENTS.md), initialize git repository with appropriate .gitignore, verify setup by running install, build, lint, and test commands, and generate comprehensive onboarding report with next steps and quick commands.
