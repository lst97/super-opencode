# Pull Request

## 📝 Type of Change

- [ ] **feat**: New feature (non-breaking change which adds functionality)
- [ ] **fix**: Bug fix (non-breaking change which fixes an issue)
- [ ] **refactor**: Code change that neither fixes a bug nor adds a feature
- [ ] **perf**: Performance improvement
- [ ] **docs**: Documentation only change
- [ ] **chore**: Build process or auxiliary tool change
- [ ] **⚠️ BREAKING CHANGE**: Fix or feature that would cause existing functionality to not work as expected

## 📦 Component

<!-- Select all that apply -->
- [ ] **CLI/Installer** (`super-opencode` command)
- [ ] **Package Manager Detection** (`detect-pm` command, scripts in `.opencode/skills/package-manager/`)
- [ ] **Agents** (pm-agent, architect, backend, frontend, security, quality, etc.)
- [ ] **Skills** (confidence-check, self-check, security-audit, simplification, etc.)
- [ ] **Commands** (/soc-implement, /soc-design, /soc-brainstorm, etc.)
- [ ] **Documentation** (README, AGENTS.md, SKILL.md, npm publishing guide)
- [ ] **CI/CD** (GitHub Actions workflows)
- [ ] **Other**

## 📝 Description

<!-- Describe the changes made. Link to related issues using #issue_number. -->

### Summary
<!-- Provide a clear and concise summary of the changes -->

### Motivation
<!-- Why is this change needed? What problem does it solve? -->

### Implementation Details
<!-- How did you implement this? Any design decisions worth noting? -->

## 🧪 Verification

### Core Checks

- [ ] **Confidence Check**: I have verified this approach aligns with the architecture and AGENTS.md principles.
- [ ] **Self-Check**: I have followed the self-check skill requirements (build, lint, validation).
- [ ] **Manual Test**: I have run `pnpm build` and `node dist/cli.js --help` locally.
- [ ] **Lint Check**: I have run `pnpm lint` and all checks pass.
- [ ] **Security Review**: I have reviewed the `security-audit` skill checklist.

### Component-Specific Checks

#### If changing Package Manager Detection (`detect-pm`)

- [ ] Tested with JavaScript/TypeScript projects (npm, yarn, pnpm, bun)
- [ ] Tested with Python projects (pip, poetry, uv, conda, pipenv)
- [ ] Tested with other languages (Go, Rust, Java, etc.)
- [ ] Verified JSON output format (`detect-pm --json`)
- [ ] Verified recommendation output (`detect-pm --recommend`)
- [ ] Tested bash 3.2 compatibility (macOS default)

#### If changing Agents or Skills

- [ ] Updated corresponding `.md` files in `.opencode/agents/` or `.opencode/skills/`
- [ ] Verified agent references correct skills
- [ ] Cross-references between agents are consistent

#### If changing Commands

- [ ] Updated corresponding `.md` file in `.opencode/commands/`
- [ ] Verified command references correct agents and skills
- [ ] Checked for consistency with other commands

#### If changing Documentation

- [ ] Proofread for typos and clarity
- [ ] Verified all links work
- [ ] Checked markdown formatting

#### If changing CI/CD

- [ ] Tested workflow syntax (use `act` or GitHub Actions validator)
- [ ] Verified secrets and environment variables are correct
- [ ] Tested on fork or test repository if possible

## 📸 Screenshots / Evidence

<!-- Attach screenshots if this changes UI or CLI output -->

### Before (if applicable)
<!-- What did it look like before? -->

### After
<!-- What does it look like now? -->

```
Paste CLI output or relevant logs here
```

## 📋 Testing Notes

<!-- How did you test this? What scenarios did you cover? -->

### Tested On

- [ ] macOS (bash 3.2+, zsh)
- [ ] Linux (Ubuntu, etc.)
- [ ] Windows (Git Bash, WSL, PowerShell)

### Test Cases
<!-- List specific test cases you ran -->
1.
2.
3.

## 🔗 Related Issues

<!-- Link to any related issues using #issue_number -->
Closes #
Fixes #
Relates to #

## 📚 Documentation Updates

<!-- If this changes documentation, note what was updated -->
- [ ] No documentation changes needed
- [ ] README.md updated
- [ ] AGENTS.md updated
- [ ] SKILL.md updated
- [ ] NPM_PUBLISHING_GUIDE.md updated
- [ ] Other documentation updated (please specify)

## ⚠️ Breaking Changes

<!-- If applicable, describe any breaking changes and migration path -->
- [ ] No breaking changes
- [ ] Breaking changes (requires major version bump)
  - **Migration Guide**:

## 🚀 Deployment Notes

<!-- Any special considerations for deployment? -->
- [ ] Standard deployment (no special steps)
- [ ] Requires environment secret update
- [ ] Requires npm publish after merge
- [ ] Other (please specify)
