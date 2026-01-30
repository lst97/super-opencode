---
description: "Deployment orchestration, release management, and infrastructure provisioning"
---

# /soc-deploy

## 1. Command Overview

The `/soc-deploy` command is the "Release Commander." It orchestrates the entire deployment pipeline—from environment provisioning to production release. It ensures deployments are repeatable, safe, and observable. It integrates CI/CD workflows, infrastructure as code, and rollback procedures to minimize deployment risk.

## 2. Triggers & Routing

The command activates deployment modes based on target environment and strategy.

| Trigger Scenario | Flag | Target Agent | Context Injected |
| :--- | :--- | :--- | :--- |
| **Environment Setup** | `--action provision` | `[devops-agent]` | Cloud Provider, Regions, Resources |
| **CI/CD Pipeline** | `--action pipeline` | `[devops-agent]` | Build Steps, Tests, Gates |
| **Production Deploy** | `--action deploy` | `[devops-agent]` + `[security]` | Release Checklist, Rollback Plan |
| **Rollback** | `--action rollback` | `[devops-agent]` | Previous Stable Version |
| **Monitoring Setup** | `--action monitor` | `[devops-agent]` | Alerts, Dashboards, SLOs |

## 3. Usage & Arguments

```bash
/soc-deploy [target] [flags]
```

### Arguments

- **`[target]`**: Deployment target (e.g., "staging", "production", "v2.1.0", "infrastructure").

### Flags

- **`--action [provision|pipeline|deploy|rollback|monitor]`**: **MANDATORY**. Specifies deployment phase.
- **`--environment [dev|staging|prod]`**: Target environment (required for deploy/rollback).
- **`--strategy [blue-green|canary|rolling|recreate]`**: Deployment strategy (default: rolling).
- **`--version [semver]`**: Version tag to deploy (e.g., "v2.1.0").
- **`--dry-run`**: Simulate deployment without executing (validate configuration).
- **`--skip-tests`**: Skip test execution in pipeline (emergency use only).
- **`--auto-rollback`**: Automatically rollback on health check failure.

## 4. Behavioral Flow (Orchestration)

### Phase 1: Pre-Flight Checks

1. **Validate**: Check all required flags and configurations.
2. **Health Check**: Verify current environment status.
3. **Permission Check**: Ensure deployment credentials are valid.
4. **Gate Check**: Verify all pre-deployment requirements met (tests passed, approvals granted).

### Phase 2: Deployment Execution

#### Environment Provisioning (`--action provision`):
- Generate Terraform/CloudFormation configs.
- Create resource groups/VPCs.
- Set up databases, caches, queues.
- Configure networking and security groups.
- Output infrastructure state files.

#### Pipeline Configuration (`--action pipeline`):
- Define build stages (lint → test → build → scan).
- Configure artifact storage.
- Set up deployment gates (manual approval for prod).
- Integrate security scanning (SAST, dependency check).
- Configure notifications (Slack, email).

#### Production Deploy (`--action deploy`):
- **Blue-Green**: Deploy to new environment, run smoke tests, switch traffic.
- **Canary**: Deploy to 5% of traffic, monitor metrics, gradually increase.
- **Rolling**: Replace instances one by one with health checks.
- **Recreate**: Stop old version, start new version (downtime acceptable).

#### Rollback (`--action rollback`):
- Identify previous stable version.
- Execute rollback strategy (reverse of deployment).
- Verify system health post-rollback.
- Generate incident report.

### Phase 3: Post-Deployment

- **Verification**: Run smoke tests and health checks.
- **Monitoring**: Activate alerts and dashboards.
- **Notification**: Notify team of deployment status.
- **Documentation**: Update deployment log and runbooks.

## 5. Output Guidelines (The Contract)

### Deployment Report Template

```markdown
# Deployment Report: [Version] → [Environment]

## Summary
**Action**: Production Deploy  
**Version**: v2.1.0  
**Strategy**: Blue-Green  
**Status**: ✅ SUCCESS / ❌ FAILED / ⚠️ ROLLBACK  
**Duration**: 12 minutes  
**Started**: 2026-01-30 14:30 UTC  
**Completed**: 2026-01-30 14:42 UTC

## Pre-Deployment Checklist
- [x] All tests passing (CI/CD green)
- [x] Security scan passed (0 critical, 2 medium)
- [x] Database migrations reviewed
- [x] Rollback plan documented
- [x] On-call engineer notified

## Deployment Steps

| Step | Action | Status | Duration |
|:-----|:-------|:------:|:--------:|
| 1 | Provision green environment | ✅ | 3m |
| 2 | Deploy v2.1.0 to green | ✅ | 2m |
| 3 | Run smoke tests | ✅ | 2m |
| 4 | Database migration | ✅ | 1m |
| 5 | Switch traffic (blue→green) | ✅ | 30s |
| 6 | Verify production health | ✅ | 3m |
| 7 | Decommission blue | ✅ | 1m |

## Health Checks

| Check | Target | Actual | Status |
|:------|:-------|:-------|:------:|
| Response Time | <200ms | 145ms | ✅ |
| Error Rate | <0.1% | 0.02% | ✅ |
| CPU Usage | <70% | 45% | ✅ |
| Memory Usage | <80% | 62% | ✅ |

## Rollback Information
**Previous Version**: v2.0.8  
**Rollback Command**: `/soc-deploy rollback --environment prod --version v2.0.8`  
**Estimated Rollback Time**: 5 minutes  
**Rollback Triggered**: No

## Post-Deployment Actions
- [x] Monitoring dashboards verified
- [x] Error logs checked (no anomalies)
- [x] Team notified in #deployments
- [x] Runbooks updated
- [ ] Post-deploy review scheduled (24h)

## Issues & Notes
- Minor: 2 medium-severity dependency warnings (non-blocking)
- Note: Database migration required brief read-only mode (45s)
```

### Pipeline Configuration Output

```yaml
# .github/workflows/deploy.yml (Generated)
name: Deploy Pipeline

on:
  push:
    tags: ['v*']

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint
        run: npm run lint
      - name: Type Check
        run: npm run typecheck
      
  test:
    runs-on: ubuntu-latest
    needs: validate
    steps:
      - name: Unit Tests
        run: npm test
      - name: Coverage
        run: npm run test:coverage
        
  security:
    runs-on: ubuntu-latest
    needs: validate
    steps:
      - name: SAST Scan
        uses: github/codeql-action@v2
      - name: Dependency Check
        run: npm audit --audit-level moderate
        
  deploy:
    runs-on: ubuntu-latest
    needs: [test, security]
    environment: production
    steps:
      - name: Deploy to Production
        run: |
          /soc-deploy prod --action deploy --version ${{ github.ref_name }}
```

## 6. Examples

### A. Production Deployment

```bash
/soc-deploy production --action deploy --version v2.1.0 --strategy blue-green --auto-rollback
```

*Effect:* Deploys v2.1.0 to production using blue-green strategy with automatic rollback on health check failure.

### B. Infrastructure Provisioning

```bash
/soc-deploy "staging-infrastructure" --action provision --provider aws --region us-east-1
```

*Effect:* Provisions all staging environment infrastructure on AWS us-east-1 (VPC, databases, caches, load balancers).

### C. Emergency Rollback

```bash
/soc-deploy production --action rollback --version v2.0.8
```

*Effect:* Immediately rolls back production to v2.0.8, verifies health, and generates incident report.

### D. Pipeline Setup

```bash
/soc-deploy "ci-cd" --action pipeline --provider github-actions
```

*Effect:* Generates complete CI/CD pipeline configuration for GitHub Actions with build, test, security, and deploy stages.

## 7. Dependencies & Capabilities

### Agents

- **DevOps Lead**: `[devops-agent]` - Infrastructure provisioning, pipeline setup, deployment execution.
- **Security Validator**: `[security]` - Pre-deployment security checks and approval.
- **PM Coordination**: `[pm-agent]` - Deployment scheduling and approval workflows.

### Skills

- **Security Audit**: `@[.opencode/skills/security-audit/SKILL.md]` - Validates deployment security.
- **Self Check**: `@[.opencode/skills/self-check/SKILL.md]` - Pre-deployment verification.
- **Confidence Check**: `@[.opencode/skills/confidence-check/SKILL.md]` - Validates deployment readiness.
- **Package Manager**: `@[.opencode/skills/package-manager/SKILL.md]` - Ensures correct package manager for builds.

### MCP Integration

- **`tavily`**: Research cloud provider best practices and pricing.
- **`context7`**: Access Terraform, Kubernetes, or cloud provider documentation.
- **`generate_image`**: Create infrastructure architecture diagrams.

## 8. Boundaries

**Will:**

- Provision infrastructure using IaC (Terraform/CloudFormation).
- Configure CI/CD pipelines with proper gates and stages.
- Execute deployments using various strategies (blue-green, canary, rolling).
- Perform automated rollbacks on failure.
- Set up monitoring and alerting for deployed services.

**Will Not:**

- **Execute Without Approval**: Production deployments require explicit approval (unless `--auto-approve` flag used).
- **Modify Production Directly**: Always uses IaC and pipelines—no manual SSH changes.
- **Skip Security Scans**: Can override with `--skip-security` but flags as high risk.
- **Store Secrets**: References secret managers but never logs or stores credentials.

## User Instruction

The user have executed the `/soc-deploy` command by parsing the user's arguments provided in `<user-instruction>$ARGUMENTS</user-instruction>`, then route to the appropriate deployment action (provision, pipeline, deploy, rollback, or monitor), perform pre-flight checks including permissions, health status, and deployment gates, execute the requested deployment phase using infrastructure-as-code principles and the specified strategy, run health checks and verification tests, if deployment fails and `--auto-rollback` is set, execute rollback procedure, generate comprehensive deployment report with all steps, health metrics, and rollback information, and update deployment logs and notify stakeholders of completion status.
