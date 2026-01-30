---
name: 🐛 Bug Report
about: Create a report to help us improve Super-OpenCode
title: "[BUG] "
labels: ["bug", "needs triage"]
assignees: ''
---

## 🐛 Bug Description
<!-- A clear and concise description of what the bug is. -->

## 📦 Component
<!-- Which part of Super-OpenCode is affected? -->
- [ ] **CLI/Installer** (`super-opencode` command)
- [ ] **Package Manager Detection** (`detect-pm` command)
- [ ] **Agents** (pm-agent, architect, backend, frontend, etc.)
- [ ] **Skills** (confidence-check, self-check, security-audit, etc.)
- [ ] **Slash Commands** (/soc-implement, /soc-design, etc.)
- [ ] **Documentation** (README, AGENTS.md, SKILL.md)
- [ ] **Other**

## 🚦 Impact
<!-- How critical is this? -->
- [ ] **High**: Blocks usage entirely or causes data loss
- [ ] **Medium**: Significant annoyance or partial breakage
- [ ] **Low**: Minor visual glitch or edge case

## 🐞 Reproduction Steps

1. **Run command**:

   ```bash
   # e.g., detect-pm --json
   # e.g., super-opencode
   ```

2. **Select option**: ...
3. **Observe error**: ...

### Minimal Reproduction
<!-- If applicable, provide the simplest case that reproduces the issue -->
```bash
# Paste minimal commands here
```

## 🖥️ Environment

### System Information

- **OS**: [e.g. Windows 11, macOS Sequoia, Ubuntu 22.04]
- **OS Version**: [e.g. 22.04, 14.2.1]
- **Architecture**: [e.g. x64, ARM64]

### Runtime Information

- **Node Version**: [e.g. 20.10.0] (`node -v`)
- **npm Version**: [e.g. 10.2.3] (`npm -v`)
- **Package Version**: [e.g. 1.2.0] (`super-opencode --version` or from package.json)

### Terminal Information

- **Terminal**: [e.g. PowerShell, iTerm2, GNOME Terminal, VS Code integrated]
- **Shell**: [e.g. bash, zsh, fish, PowerShell]
- **Shell Version**: [e.g. 5.2.15] (`bash --version` or `$PSVersionTable.PSVersion`)

### Package Manager Context (if using detect-pm)
<!-- If the bug involves package manager detection, please provide: -->
- **Project Language(s)**: [e.g. JavaScript, Python, Go, Rust, Java]
- **Package Manager(s) Used**: [e.g. pnpm, poetry, cargo, maven]
- **Lockfile(s) Present**: [e.g. pnpm-lock.yaml, poetry.lock, Cargo.lock]
- **Project Structure**: [e.g. Monorepo with packages/, Single project]

## 📸 Evidence
<!-- Screenshots, logs, or stack traces. Please use code blocks for logs. -->

### Error Output

```
Paste error messages, stack traces, or console output here
```

### Screenshots
<!-- If applicable, add screenshots to help explain your problem -->

### Additional Context
<!-- Add any other context about the problem here -->

## ✅ Expected Behavior
<!-- What did you expect to happen? -->

## ❌ Actual Behavior
<!-- What actually happened? -->

## 🔍 Troubleshooting Already Tried
<!-- What have you already tried to resolve the issue? -->
- [ ] Reinstalled package: `npm install -g super-opencode`
- [ ] Cleared cache: `npm cache clean --force`
- [ ] Checked permissions: [e.g. sudo, admin rights]
- [ ] Tested on different terminal/shell
- [ ] Tested on different Node version
- [ ] Checked for existing issues

## 💡 Potential Fix
<!-- Do you have a hypothesis or a fix in mind? -->

## 📋 Checklist
<!-- Please verify the following before submitting: -->
- [ ] I have searched existing issues to ensure this is not a duplicate
- [ ] I have provided all the information requested above
- [ ] I have tested with the latest version of Super-OpenCode
- [ ] I can reproduce this bug consistently
