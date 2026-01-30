#!/bin/bash
#
# Multi-Language Package Manager Detection Script (Bash 3.2 Compatible)
# Detects package managers for JavaScript, Python, Go, Rust, Java, Ruby, PHP, .NET, and more
#
# Usage:
#   ./detect-package-manager.sh [options] [language]
#
# Options:
#   --json          Output results as JSON
#   --quiet         Only output errors
#   --recommend     Show recommendation only
#   --all           Detect for all languages found
#   --help          Show this help message
#
# Language (optional, auto-detected if not specified):
#   javascript, python, go, rust, java, ruby, php, dotnet, elixir, haskell, etc.
#
# Exit codes:
#   0 - Success
#   1 - No package manager detected
#   2 - Error reading project files
#

# Colors for output (only in non-JSON mode)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
JSON_OUTPUT=false
QUIET=false
RECOMMEND_ONLY=false
DETECT_ALL=false
SPECIFIED_LANGUAGE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --json)
      JSON_OUTPUT=true
      shift
      ;;
    --quiet)
      QUIET=true
      shift
      ;;
    --recommend)
      RECOMMEND_ONLY=true
      shift
      ;;
    --all)
      DETECT_ALL=true
      shift
      ;;
    --help)
      echo "Multi-Language Package Manager Detection Script"
      echo ""
      echo "Usage: $0 [options] [language]"
      echo ""
      echo "Options:"
      echo "  --json          Output results as JSON"
      echo "  --quiet         Only output errors"
      echo "  --recommend     Show recommendation only"
      echo "  --all           Detect for all languages found"
      echo "  --help          Show this help message"
      echo ""
      echo "Languages (auto-detected if not specified):"
      echo "  javascript  - npm, yarn, pnpm, bun"
      echo "  python      - pip, poetry, uv, conda, pipenv"
      echo "  go          - go modules"
      echo "  rust        - cargo"
      echo "  java        - maven, gradle"
      echo "  ruby        - bundler"
      echo "  php         - composer"
      echo "  dotnet      - nuget"
      echo "  elixir      - mix"
      echo "  haskell     - cabal, stack"
      echo "  c/cpp       - cmake, conan, vcpkg"
      echo "  swift       - swift package manager"
      echo "  kotlin      - gradle"
      echo "  scala       - sbt"
      echo "  clojure     - leiningen, deps.edn"
      echo "  julia       - pkg"
      echo "  r           - renv, packrat"
      echo ""
      echo "Examples:"
      echo "  $0                          # Auto-detect language and PM"
      echo "  $0 --json                   # JSON output"
      echo "  $0 python                   # Detect Python PM only"
      echo "  $0 --all --json             # Detect all languages in project"
      exit 0
      ;;
    --*)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
    *)
      # Assume it's a language specification
      SPECIFIED_LANGUAGE="$1"
      shift
      ;;
  esac
done

# Logging function
log() {
  if [[ "$QUIET" == false && "$JSON_OUTPUT" == false && "$RECOMMEND_ONLY" == false ]]; then
    echo -e "$1"
  fi
}

# Error function
error() {
  if [[ "$JSON_OUTPUT" == false ]]; then
    echo -e "${RED}Error: $1${NC}" >&2
  else
    echo "{\"error\": \"$1\"}" >&2
  fi
  exit 2
}

# Get project root
PROJECT_ROOT="${PWD}"

# Initialize results list
DETECTED_LANGS=""

# ============================================
# LANGUAGE DETECTION FUNCTIONS
# Each function outputs: pm|version|method|lockfile|confidence|config|field
# ============================================

# JavaScript/TypeScript
detect_javascript() {
  local pm=""
  local ver=""
  local meth=""
  local lock=""
  local conf=0
  local cfg=""
  local field=""
  
  # Check lockfiles
  if [[ -f "${PROJECT_ROOT}/pnpm-lock.yaml" ]]; then
    pm="pnpm"; lock="pnpm-lock.yaml"; meth="lockfile"; conf=95
  elif [[ -f "${PROJECT_ROOT}/yarn.lock" ]]; then
    pm="yarn"; lock="yarn.lock"; meth="lockfile"; conf=90
  elif [[ -f "${PROJECT_ROOT}/package-lock.json" ]]; then
    pm="npm"; lock="package-lock.json"; meth="lockfile"; conf=90
  elif [[ -f "${PROJECT_ROOT}/bun.lockb" ]]; then
    pm="bun"; lock="bun.lockb"; meth="lockfile"; conf=95
  fi
  
  # Check package.json for packageManager field
  if [[ -f "${PROJECT_ROOT}/package.json" ]]; then
    field=$(cat "${PROJECT_ROOT}/package.json" 2>/dev/null | grep -o '"packageManager"[^,]*' | head -1 || true)
    if [[ -n "$field" ]]; then
      local pm_from=$(echo "$field" | grep -o 'npm\|yarn\|pnpm\|bun' | head -1 || true)
      local ver_from=$(echo "$field" | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || true)
      if [[ -n "$pm_from" ]]; then
        pm="$pm_from"; ver="$ver_from"; meth="package.json"; conf=100
      fi
    fi
  fi
  
  # Check for monorepo
  if [[ -z "$pm" ]]; then
    if [[ -f "${PROJECT_ROOT}/pnpm-workspace.yaml" || -d "${PROJECT_ROOT}/packages" ]]; then
      pm="pnpm"; meth="monorepo"; conf=80
    elif [[ -f "${PROJECT_ROOT}/package.json" ]]; then
      pm="npm"; meth="default"; conf=60
    fi
  fi
  
  # Get installed version
  if [[ -z "$ver" ]]; then
    case "$pm" in
      npm) ver=$(npm --version 2>/dev/null || echo "") ;;
      yarn) ver=$(yarn --version 2>/dev/null || echo "") ;;
      pnpm) ver=$(pnpm --version 2>/dev/null || echo "") ;;
      bun) ver=$(bun --version 2>/dev/null || echo "") ;;
    esac
  fi
  
  if [[ -n "$pm" ]]; then
    echo "javascript|$pm|$ver|$meth|$lock|$conf|$cfg|$field"
    return 0
  fi
  return 1
}

# Python
detect_python() {
  local pm=""
  local ver=""
  local meth=""
  local lock=""
  local conf=0
  local cfg=""
  
  if [[ -f "${PROJECT_ROOT}/uv.lock" ]]; then
    pm="uv"; lock="uv.lock"; meth="lockfile"; conf=95
  elif [[ -f "${PROJECT_ROOT}/poetry.lock" ]]; then
    pm="poetry"; lock="poetry.lock"; meth="lockfile"; conf=95
  elif [[ -f "${PROJECT_ROOT}/Pipfile.lock" ]]; then
    pm="pipenv"; lock="Pipfile.lock"; meth="lockfile"; conf=95
  elif [[ -f "${PROJECT_ROOT}/conda-lock.yml" || -f "${PROJECT_ROOT}/environment.yml" ]]; then
    pm="conda"; cfg="environment.yml"; meth="environment file"; conf=90
  elif [[ -f "${PROJECT_ROOT}/requirements.txt" ]]; then
    pm="pip"; lock="requirements.txt"; meth="requirements file"; conf=85
  elif [[ -f "${PROJECT_ROOT}/pyproject.toml" ]]; then
    if grep -q "\[tool.poetry\]" "${PROJECT_ROOT}/pyproject.toml" 2>/dev/null; then
      pm="poetry"; meth="pyproject.toml"; conf=90
    elif grep -q "\[tool.uv\]" "${PROJECT_ROOT}/pyproject.toml" 2>/dev/null; then
      pm="uv"; meth="pyproject.toml"; conf=90
    elif grep -q "\[build-system\]" "${PROJECT_ROOT}/pyproject.toml" 2>/dev/null; then
      pm="pip"; meth="pyproject.toml"; conf=70
    fi
  elif [[ -f "${PROJECT_ROOT}/setup.py" || -f "${PROJECT_ROOT}/setup.cfg" ]]; then
    pm="pip"; meth="legacy setup"; conf=70
  fi
  
  if [[ -z "$ver" ]]; then
    case "$pm" in
      pip) ver=$(pip --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "") ;;
      poetry) ver=$(poetry --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "") ;;
      uv) ver=$(uv --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "") ;;
      conda) ver=$(conda --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "") ;;
      pipenv) ver=$(pipenv --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "") ;;
    esac
  fi
  
  if [[ -n "$pm" ]]; then
    echo "python|$pm|$ver|$meth|$lock|$conf|$cfg|"
    return 0
  fi
  return 1
}

# Go
detect_go() {
  if [[ -f "${PROJECT_ROOT}/go.mod" || -f "${PROJECT_ROOT}/go.sum" ]]; then
    local ver=$(go version 2>/dev/null | grep -o 'go[0-9]\+\.[0-9]\+' || echo "")
    echo "go|go modules|$ver|go.mod|go.sum|95||"
    return 0
  fi
  return 1
}

# Rust
detect_rust() {
  if [[ -f "${PROJECT_ROOT}/Cargo.toml" || -f "${PROJECT_ROOT}/Cargo.lock" ]]; then
    local ver=$(cargo --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "")
    echo "rust|cargo|$ver|Cargo.toml|Cargo.lock|95||"
    return 0
  fi
  return 1
}

# Java
detect_java() {
  local pm=""
  local lock=""
  local conf=0
  
  if [[ -f "${PROJECT_ROOT}/pom.xml" ]]; then
    pm="maven"; conf=95
  elif [[ -f "${PROJECT_ROOT}/build.gradle" || -f "${PROJECT_ROOT}/build.gradle.kts" ]]; then
    pm="gradle"; conf=95
  elif [[ -f "${PROJECT_ROOT}/gradle.lockfile" ]]; then
    pm="gradle"; lock="gradle.lockfile"; conf=95
  fi
  
  if [[ -n "$pm" ]]; then
    local ver=""
    if [[ "$pm" == "maven" ]]; then
      ver=$(mvn --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "")
    else
      ver=$(gradle --version 2>/dev/null | grep "Gradle" | grep -o '[0-9]\+\.[0-9]\+' | head -1 || echo "")
    fi
    echo "java|$pm|$ver|build file|$lock|$conf||"
    return 0
  fi
  return 1
}

# Ruby
detect_ruby() {
  if [[ -f "${PROJECT_ROOT}/Gemfile" || -f "${PROJECT_ROOT}/Gemfile.lock" ]]; then
    local ver=$(bundle --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "")
    echo "ruby|bundler|$ver|Gemfile|Gemfile.lock|95||"
    return 0
  fi
  return 1
}

# PHP
detect_php() {
  if [[ -f "${PROJECT_ROOT}/composer.json" || -f "${PROJECT_ROOT}/composer.lock" ]]; then
    local ver=$(composer --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "")
    echo "php|composer|$ver|composer.json|composer.lock|95||"
    return 0
  fi
  return 1
}

# .NET
detect_dotnet() {
  local found=false
  for f in "${PROJECT_ROOT}"/*.csproj "${PROJECT_ROOT}"/*.fsproj "${PROJECT_ROOT}"/*.vbproj; do
    [[ -f "$f" ]] && found=true && break
  done
  
  if [[ "$found" == true || -n "$(ls "${PROJECT_ROOT}"/*.sln 2>/dev/null)" || -f "${PROJECT_ROOT}/packages.config" ]]; then
    local ver=$(dotnet --version 2>/dev/null || echo "")
    echo "dotnet|nuget|$ver|project file|packages.lock.json|90||"
    return 0
  fi
  return 1
}

# Elixir
detect_elixir() {
  if [[ -f "${PROJECT_ROOT}/mix.exs" || -f "${PROJECT_ROOT}/mix.lock" ]]; then
    local ver=$(mix --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "")
    echo "elixir|mix|$ver|mix.exs|mix.lock|95||"
    return 0
  fi
  return 1
}

# Haskell
detect_haskell() {
  local pm=""
  local lock=""
  
  if [[ -f "${PROJECT_ROOT}/stack.yaml" || -f "${PROJECT_ROOT}/stack.yaml.lock" ]]; then
    pm="stack"; lock="stack.yaml.lock"
  else
    for f in "${PROJECT_ROOT}"/*.cabal; do
      [[ -f "$f" ]] && pm="cabal" && lock="cabal.project.freeze" && break
    done
  fi
  
  if [[ -n "$pm" ]]; then
    local ver=""
    if [[ "$pm" == "stack" ]]; then
      ver=$(stack --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "")
    else
      ver=$(cabal --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "")
    fi
    echo "haskell|$pm|$ver|config file|$lock|90||"
    return 0
  fi
  return 1
}

# C/C++
detect_cpp() {
  local pm=""
  
  if [[ -f "${PROJECT_ROOT}/conanfile.txt" || -f "${PROJECT_ROOT}/conanfile.py" ]]; then
    pm="conan"
  elif [[ -f "${PROJECT_ROOT}/vcpkg.json" ]]; then
    pm="vcpkg"
  fi
  
  if [[ -n "$pm" ]]; then
    echo "cpp|$pm||config file||85||"
    return 0
  fi
  return 1
}

# Swift
detect_swift() {
  if [[ -f "${PROJECT_ROOT}/Package.swift" || -f "${PROJECT_ROOT}/Package.resolved" ]]; then
    local ver=$(swift --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+' | head -1 || echo "")
    echo "swift|swift package manager|$ver|Package.swift|Package.resolved|95||"
    return 0
  fi
  return 1
}

# Scala
detect_scala() {
  if [[ -f "${PROJECT_ROOT}/build.sbt" ]]; then
    local ver=""
    if command -v sbt &> /dev/null; then
      ver=$(sbt sbtVersion 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "")
    fi
    echo "scala|sbt|$ver|build.sbt||95||"
    return 0
  fi
  return 1
}

# Clojure
detect_clojure() {
  local pm=""
  
  if [[ -f "${PROJECT_ROOT}/project.clj" ]]; then
    pm="leiningen"
  elif [[ -f "${PROJECT_ROOT}/deps.edn" ]]; then
    pm="tools.deps"
  fi
  
  if [[ -n "$pm" ]]; then
    echo "clojure|$pm||project file||90||"
    return 0
  fi
  return 1
}

# Julia
detect_julia() {
  if [[ -f "${PROJECT_ROOT}/Project.toml" || -f "${PROJECT_ROOT}/Manifest.toml" || -f "${PROJECT_ROOT}/JuliaProject.toml" ]]; then
    local ver=$(julia --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "")
    echo "julia|Pkg|$ver|Project.toml|Manifest.toml|95||"
    return 0
  fi
  return 1
}

# R
detect_r() {
  if [[ -f "${PROJECT_ROOT}/renv.lock" || -d "${PROJECT_ROOT}/renv" || -f "${PROJECT_ROOT}/packrat.lock" ]]; then
    local pm="renv"
    [[ -f "${PROJECT_ROOT}/packrat.lock" ]] && pm="packrat"
    echo "r|$pm||lockfile|${pm}.lock|95||"
    return 0
  fi
  return 1
}

# ============================================
# DETECT ALL LANGUAGES
# ============================================
detect_all() {
  local result=""
  
  if [[ -n "$SPECIFIED_LANGUAGE" ]]; then
    # Detect specific language only
    case "$SPECIFIED_LANGUAGE" in
      javascript|js|node|nodejs) result=$(detect_javascript) ;;
      python|py) result=$(detect_python) ;;
      go|golang) result=$(detect_go) ;;
      rust|rs) result=$(detect_rust) ;;
      java) result=$(detect_java) ;;
      ruby|rb) result=$(detect_ruby) ;;
      php) result=$(detect_php) ;;
      dotnet|csharp|cs|fsharp|fs|vb) result=$(detect_dotnet) ;;
      elixir|ex|exs) result=$(detect_elixir) ;;
      haskell|hs|cabal|stack) result=$(detect_haskell) ;;
      cpp|c++|c|conan|vcpkg|cmake) result=$(detect_cpp) ;;
      swift) result=$(detect_swift) ;;
      scala) result=$(detect_scala) ;;
      clojure|clj) result=$(detect_clojure) ;;
      julia|jl) result=$(detect_julia) ;;
      r) result=$(detect_r) ;;
      *) error "Unknown language: $SPECIFIED_LANGUAGE" ;;
    esac
    [[ -n "$result" ]] && DETECTED_LANGS="$result"
  else
    # Auto-detect all languages
    result=$(detect_javascript); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_python); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_go); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_rust); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_java); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_ruby); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_php); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_dotnet); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_elixir); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_haskell); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_cpp); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_swift); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_scala); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_clojure); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_julia); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
    result=$(detect_r); [[ -n "$result" ]] && DETECTED_LANGS="${DETECTED_LANGS}${DETECTED_LANGS:+,}$result"
  fi
}

# ============================================
# OUTPUT FORMATTING
# ============================================
get_lang_display() {
  case "$1" in
    javascript) echo "JavaScript/TypeScript" ;;
    python) echo "Python" ;;
    go) echo "Go" ;;
    rust) echo "Rust" ;;
    java) echo "Java" ;;
    ruby) echo "Ruby" ;;
    php) echo "PHP" ;;
    dotnet) echo ".NET" ;;
    elixir) echo "Elixir" ;;
    haskell) echo "Haskell" ;;
    cpp) echo "C/C++" ;;
    swift) echo "Swift" ;;
    scala) echo "Scala" ;;
    clojure) echo "Clojure" ;;
    julia) echo "Julia" ;;
    r) echo "R" ;;
  esac
}

get_recommendation() {
  local lang=$1 pm=$2
  case "$lang" in
    javascript)
      case "$pm" in
        npm) echo "npm is a safe, universal choice. Consider migrating to pnpm for better performance." ;;
        yarn) echo "yarn is reliable. For new projects, consider pnpm for disk efficiency." ;;
        pnpm) echo "pnpm is excellent—fast, disk-efficient, and strict. Perfect choice." ;;
        bun) echo "bun is very fast but newer. Ensure your team is comfortable with it." ;;
      esac
      ;;
    python)
      case "$pm" in
        pip) echo "pip is the standard. Consider poetry or uv for modern Python projects." ;;
        poetry) echo "poetry provides excellent dependency resolution and packaging." ;;
        uv) echo "uv is extremely fast and modern. Great for performance-critical projects." ;;
        conda) echo "conda is ideal for data science and scientific computing." ;;
        pipenv) echo "pipenv combines pip and virtualenv. Consider poetry for new projects." ;;
      esac
      ;;
    go) echo "Go modules is the standard. Ensure you have go.mod committed." ;;
    rust) echo "Cargo is Rust's excellent package manager. Crates.io has great ecosystem coverage." ;;
    java)
      case "$pm" in
        maven) echo "Maven is stable and widely used. Great for enterprise projects." ;;
        gradle) echo "Gradle offers flexibility and performance. Popular for Android and modern Java." ;;
      esac
      ;;
    ruby) echo "Bundler is the standard. Ensure Gemfile.lock is committed for reproducibility." ;;
    php) echo "Composer is excellent. Packagist has great package coverage." ;;
    dotnet) echo "NuGet is the standard for .NET. Ensure packages.lock.json for reproducibility." ;;
    elixir) echo "Mix is powerful. Hex.pm has excellent Elixir package ecosystem." ;;
    haskell)
      case "$pm" in
        stack) echo "Stack is recommended for reproducible builds and LTS snapshots." ;;
        cabal) echo "Cabal is the traditional choice. Consider stack for easier setup." ;;
      esac
      ;;
    cpp)
      case "$pm" in
        conan) echo "Conan is modern and cross-platform. Great for C++ dependency management." ;;
        vcpkg) echo "vcpkg has excellent Microsoft ecosystem integration." ;;
      esac
      ;;
    swift) echo "Swift Package Manager is modern and well-integrated with Xcode." ;;
    scala) echo "sbt is the standard. Maven Central has good Scala coverage." ;;
    clojure)
      case "$pm" in
        leiningen) echo "Leiningen is mature and widely used in Clojure community." ;;
        tools.deps) echo "tools.deps is modern and simpler. Consider for new projects." ;;
      esac
      ;;
    julia) echo "Julia's Pkg is excellent. General registry has good coverage." ;;
    r)
      case "$pm" in
        renv) echo "renv is the modern standard for R reproducibility." ;;
        packrat) echo "packrat is older. Consider migrating to renv." ;;
      esac
      ;;
  esac
}

get_commands() {
  local lang=$1 pm=$2
  case "$lang" in
    javascript)
      case "$pm" in
        npm) echo "install:npm ci|add:npm install|add_dev:npm install --save-dev|run:npm run|exec:npx" ;;
        yarn) echo "install:yarn install --frozen-lockfile|add:yarn add|add_dev:yarn add --dev|run:yarn|exec:yarn dlx" ;;
        pnpm) echo "install:pnpm install --frozen-lockfile|add:pnpm add|add_dev:pnpm add -D|run:pnpm|exec:pnpm dlx" ;;
        bun) echo "install:bun install|add:bun add|add_dev:bun add -d|run:bun run|exec:bunx" ;;
      esac
      ;;
    python)
      case "$pm" in
        pip) echo "install:pip install -r requirements.txt|add:pip install|add_dev:pip install|run:python|exec:python" ;;
        poetry) echo "install:poetry install|add:poetry add|add_dev:poetry add --group dev|run:poetry run|exec:poetry run" ;;
        uv) echo "install:uv sync|add:uv add|add_dev:uv add --dev|run:uv run|exec:uv run" ;;
        conda) echo "install:conda env create -f environment.yml|add:conda install|add_dev:conda install|run:conda run|exec:conda run" ;;
        pipenv) echo "install:pipenv install|add:pipenv install|add_dev:pipenv install --dev|run:pipenv run|exec:pipenv run" ;;
      esac
      ;;
    go) echo "install:go mod download|add:go get|add_dev:go get|run:go run|exec:go run" ;;
    rust) echo "install:cargo fetch|add:cargo add|add_dev:cargo add --dev|run:cargo run|exec:cargo run" ;;
    java)
      case "$pm" in
        maven) echo "install:mvn dependency:resolve|add:pom.xml edit|add_dev:pom.xml edit|run:mvn exec:java|exec:mvn exec:java" ;;
        gradle) echo "install:gradle dependencies|add:build.gradle edit|add_dev:build.gradle edit|run:gradle run|exec:gradle run" ;;
      esac
      ;;
    ruby) echo "install:bundle install|add:bundle add|add_dev:bundle add --group development|run:bundle exec|exec:bundle exec" ;;
    php) echo "install:composer install|add:composer require|add_dev:composer require --dev|run:php|exec:php" ;;
    dotnet) echo "install:dotnet restore|add:dotnet add package|add_dev:dotnet add package|run:dotnet run|exec:dotnet run" ;;
    elixir) echo "install:mix deps.get|add:mix deps.add|add_dev:mix deps.add|run:mix run|exec:mix run" ;;
    haskell)
      case "$pm" in
        stack) echo "install:stack build|add:stack add|add_dev:stack add|run:stack run|exec:stack exec" ;;
        cabal) echo "install:cabal build|add:cabal add|add_dev:cabal add|run:cabal run|exec:cabal exec" ;;
      esac
      ;;
    cpp)
      case "$pm" in
        conan) echo "install:conan install|add:conanfile.txt edit|add_dev:conanfile.txt edit|run:cmake|exec:cmake" ;;
        vcpkg) echo "install:vcpkg install|add:vcpkg add|add_dev:vcpkg add|run:cmake|exec:cmake" ;;
      esac
      ;;
    swift) echo "install:swift package resolve|add:Package.swift edit|add_dev:Package.swift edit|run:swift run|exec:swift run" ;;
    scala) echo "install:sbt update|add:build.sbt edit|add_dev:build.sbt edit|run:sbt run|exec:sbt run" ;;
    clojure)
      case "$pm" in
        leiningen) echo "install:lein deps|add:project.clj edit|add_dev:project.clj edit|run:lein run|exec:lein exec" ;;
        tools.deps) echo "install:clj -P|add:deps.edn edit|add_dev:deps.edn edit|run:clj -M|exec:clj -X" ;;
      esac
      ;;
    julia) echo "install:julia -e 'using Pkg; Pkg.instantiate()'|add:julia -e 'using Pkg; Pkg.add()'|add_dev:julia -e 'using Pkg; Pkg.add()'|run:julia|exec:julia" ;;
    r)
      case "$pm" in
        renv) echo "install:renv::restore()|add:renv::install()|add_dev:renv::install()|run:Rscript|exec:Rscript" ;;
        packrat) echo "install:packrat::restore()|add:packrat::install()|add_dev:packrat::install()|run:Rscript|exec:Rscript" ;;
      esac
      ;;
  esac
}

# Output JSON format
output_json() {
  local first=true
  echo "{"
  echo "  \"project_root\": \"${PROJECT_ROOT}\","
  echo "  \"languages\": ["
  
  # Parse each detected language
  local IFS=','
  for entry in $DETECTED_LANGS; do
    [[ -z "$entry" ]] && continue
    
    if [[ "$first" == false ]]; then
      echo ","
    fi
    first=false
    
    # Parse pipe-delimited fields
    local IFS='|'
    local fields=($entry)
    local lang="${fields[0]}"
    local pm="${fields[1]}"
    local ver="${fields[2]}"
    local meth="${fields[3]}"
    local lock="${fields[4]}"
    local conf="${fields[5]}"
    local cfg="${fields[6]}"
    local field="${fields[7]}"
    
    local rec=$(get_recommendation "$lang" "$pm" | sed 's/"/\\"/g')
    local cmds=$(get_commands "$lang" "$pm")
    
    echo "    {"
    echo "      \"language\": \"$lang\","
    echo "      \"package_manager\": \"$pm\","
    echo "      \"version\": \"${ver:-}\","
    echo "      \"detection_method\": \"$meth\","
    echo "      \"confidence\": ${conf:-0},"
    echo "      \"lockfile\": \"${lock:-}\","
    echo "      \"config_file\": \"${cfg:-}\","
    echo "      \"package_manager_field\": \"${field:-}\","
    echo "      \"recommendation\": \"$rec\","
    echo -n "      \"commands\": {"
    
    # Parse commands
    local IFS='|'
    local cmd_array=($cmds)
    local first_cmd=true
    for cmd in "${cmd_array[@]}"; do
      local key=$(echo "$cmd" | cut -d':' -f1)
      local val=$(echo "$cmd" | cut -d':' -f2)
      if [[ "$first_cmd" == false ]]; then
        echo -n ", "
      fi
      first_cmd=false
      echo -n "\"$key\": \"$val\""
    done
    echo -n "}"
    echo ""
    echo -n "    }"
  done
  
  echo ""
  echo "  ]"
  echo "}"
}

# Output human-readable format
output_human() {
  if [[ "$RECOMMEND_ONLY" == true ]]; then
    # Get first language's package manager
    local first_entry=$(echo "$DETECTED_LANGS" | cut -d',' -f1)
    echo "$first_entry" | cut -d'|' -f2
    return
  fi
  
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║   Multi-Language Package Manager Detection Report          ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  echo "Project: ${PROJECT_ROOT}"
  echo ""
  
  if [[ -z "$DETECTED_LANGS" ]]; then
    echo "${RED}No package managers detected for any language!${NC}"
    echo ""
    echo "This project may be new or use an unsupported build system."
    return
  fi
  
  # Parse each detected language
  local IFS=','
  for entry in $DETECTED_LANGS; do
    [[ -z "$entry" ]] && continue
    
    # Parse pipe-delimited fields
    local IFS='|'
    local fields=($entry)
    local lang="${fields[0]}"
    local pm="${fields[1]}"
    local ver="${fields[2]}"
    local meth="${fields[3]}"
    local lock="${fields[4]}"
    local conf="${fields[5]}"
    
    local display=$(get_lang_display "$lang")
    local rec=$(get_recommendation "$lang" "$pm")
    
    echo "${CYAN}${display}${NC}"
    echo "  ${GREEN}Recommended: ${pm}${NC}"
    [[ -n "$ver" ]] && echo "  Version: ${ver}"
    echo "  Detection: ${meth}"
    echo "  Confidence: ${conf}%"
    [[ -n "$lock" ]] && echo "  Lockfile: ${lock}"
    echo ""
    echo "  ${BLUE}Recommendation:${NC}"
    echo "    ${rec}"
    echo ""
    
    # Show commands
    local cmds=$(get_commands "$lang" "$pm")
    echo "  ${BLUE}Quick Commands:${NC}"
    local IFS='|'
    local cmd_array=($cmds)
    for cmd in "${cmd_array[@]}"; do
      local key=$(echo "$cmd" | cut -d':' -f1)
      local val=$(echo "$cmd" | cut -d':' -f2)
      printf "    %-12s %s\n" "${key}:" "$val"
    done
    echo ""
  done
}

# ============================================
# MAIN EXECUTION
# ============================================
main() {
  detect_all
  
  if [[ -z "$DETECTED_LANGS" ]]; then
    if [[ "$JSON_OUTPUT" == true ]]; then
      echo '{"languages": [], "error": "No package managers detected"}'
    else
      error "No package managers detected for any language"
    fi
    exit 1
  fi
  
  if [[ "$JSON_OUTPUT" == true ]]; then
    output_json
  else
    output_human
  fi
  
  exit 0
}

# Run
main
