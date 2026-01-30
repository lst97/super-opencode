# Package Manager Detection Scripts

## Overview

This folder contains the multi-language package manager detection system for OpenCode.

## Files

### `detect-package-manager.sh` (Main Script)

**Purpose**: Detect package managers for JavaScript, Python, Go, Rust, Java, Ruby, PHP, .NET, and more.

**Features**:

- Auto-detects package managers from lockfiles and config files
- Supports 16+ programming languages
- Outputs in human-readable or JSON format
- Bash 3.2+ compatible (works on macOS default bash)

**Usage**:

```bash
# Detect all languages
./detect-package-manager.sh

# Detect specific language
./detect-package-manager.sh python
./detect-package-manager.sh javascript

# JSON output
./detect-package-manager.sh --json

# Just the recommendation
./detect-package-manager.sh --recommend
```

### `README.md` (This File)

**Purpose**: Documentation for the scripts.

## Supported Languages

| Language | Package Managers | Detection Files |
|:---------|:----------------|:----------------|
| JavaScript/TypeScript | npm, yarn, pnpm, bun | package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb |
| Python | pip, poetry, uv, conda, pipenv | requirements.txt, poetry.lock, uv.lock, environment.yml, Pipfile.lock |
| Go | go modules | go.mod, go.sum |
| Rust | cargo | Cargo.toml, Cargo.lock |
| Java | maven, gradle | pom.xml, build.gradle |
| Ruby | bundler | Gemfile, Gemfile.lock |
| PHP | composer | composer.json, composer.lock |
| .NET | nuget | .csproj, .sln |
| Elixir | mix | mix.exs, mix.lock |
| Haskell | stack, cabal | stack.yaml, *.cabal |
| C/C++ | conan, vcpkg | conanfile.txt, vcpkg.json |
| Swift | swift package manager | Package.swift |
| Scala | sbt | build.sbt |
| Clojure | leiningen, tools.deps | project.clj, deps.edn |
| Julia | Pkg | Project.toml, Manifest.toml |
| R | renv, packrat | renv.lock, packrat.lock |

## Integration

### In OpenCode Agent Workflows

The skill automatically uses this script:

```bash
# From SKILL.md:
opencode/skills/package-manager/scripts/detect-package-manager.sh --json
```

### In CI/CD

```yaml
- name: Detect Package Manager
  run: |
    PM=$(opencode/skills/package-manager/scripts/detect-package-manager.sh --recommend)
    echo "PACKAGE_MANAGER=$PM" >> $GITHUB_ENV

- name: Install Dependencies
  run: ${{ env.PACKAGE_MANAGER }} install
```

## Exit Codes

| Code | Meaning |
|:----:|:--------|
| 0 | Success - Package manager(s) detected |
| 1 | No package manager detected |
| 2 | Error (invalid arguments, file read error) |

## Adding New Languages

To add support for a new language:

1. Add a `detect_<language>()` function in `detect-package-manager.sh`
2. Output format: `language|pm|version|method|lockfile|confidence|config|field`
3. Add to `detect_all()` case statement
4. Add display name to `get_lang_display()`
5. Add recommendation to `get_recommendation()`
6. Add commands to `get_commands()`

## License

Part of OpenCode - Available under project license
