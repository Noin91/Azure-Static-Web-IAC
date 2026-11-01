# Azure Static Web App as IAC

Infrastructure as Code (Bicep) for a React single-page app on **Azure Static Web Apps (Free plan)**, with a built-in **cost guardrail**.

The goal of this project is a reproducible, cost-safe Azure baseline: everything that was first created by hand in the portal is described as code, can be validated in CI, and cannot accidentally be switched to a paid SKU.

> Status: infrastructure code written and validated in CI (see checklist below). It has **not** been deployed from this repo yet; the live app was created manually before.

## Architecture

```mermaid
flowchart LR
    GH[GitHub repo] -->|GitHub Actions build + deploy| SWA
    subgraph Azure subscription
        BUD[Budget with e-mail alerts]
        subgraph RG[Resource group rg-workload-env]
            SWA[Static Web App - Free]
        end
    end
    USER[Browser] --> SWA
    SWA -->|anon key + RLS| SB[(Supabase)]
```

## Cost guardrails

Avoiding unplanned cost is a design requirement, not an afterthought.

| Guardrail | Where | Effect |
|---|---|---|
| `@allowed(['Free'])` on the SKU parameter | `infra/modules/staticwebapp.bicep` | A deployment with a paid SKU fails at validation time |
| `@allowed` on the region | `infra/main.bicep` | Only regions supported by the Free plan |
| Monthly budget with alerts at 50 %, 90 %, 100 % of actual spend | `infra/modules/budget.bicep` | E-mail warning |
| Contact e-mail read from an environment variable | `infra/main.bicepparam` | No personal data in the repo |

Important: a budget **only warns**, it never stops resources. The real protection is the free account's spending limit (do not upgrade to pay-as-you-go) plus the Free-only SKU lock.

## Naming and tags

CAF-style names such as `rg-fantasy-e-draft-dev` and `stapp-fantasy-e-draft-dev`, plus the tags `project`, `environment`, `owner` and `managedBy`. Details: [docs/naming-convention.md](docs/naming-convention.md).

## Repository layout

```
.
├── infra/
│   ├── main.bicep              # subscription scope: resource group, modules, outputs
│   ├── main.bicepparam         # parameter values (no secrets)
│   └── modules/
│       ├── staticwebapp.bicep  # Static Web App, Free only
│       └── budget.bicep        # monthly budget with alerts
├── docs/
│   ├── naming-convention.md
│   └── security-case-study-rls.md
└── .github/workflows/
    └── validate.yml            # bicep build + lint, Checkov scan
```

## Deploy

Prerequisites: Azure CLI with Bicep, and a login (`az login`). Use a learning subscription, not a company tenant.

```bash
export BUDGET_CONTACT_EMAIL="you@example.com"   # never commit this

# 1. Validate without creating anything
az deployment sub validate \
  --location westeurope \
  --parameters infra/main.bicepparam

# 2. Preview the changes
az deployment sub what-if \
  --location westeurope \
  --parameters infra/main.bicepparam

# 3. Deploy
az deployment sub create \
  --location westeurope \
  --parameters infra/main.bicepparam
```

The parameter file uses `env = 'dev'` so a first run does not collide with resources that were created manually under `prod` names.

Clean up: `az group delete --name rg-fantasy-e-draft-dev`.

## Status

- [x] Bicep code for resource group, Static Web App (Free) and budget
- [x] CI workflow for build, lint and Checkov (runs on push and pull request)
- [ ] CI run green on GitHub
- [ ] First deployment from this repo to a `dev` environment
- [ ] `what-if` in CI via OIDC federation (no stored secrets)
- [ ] Log Analytics / Application Insights module

## Security notes

- No secrets in the repository. `.gitignore` excludes env files and keys.
- The deployment token of a Static Web App and all application keys live in GitHub repository secrets only.
- Front-end build variables (`VITE_*`) end up in the browser bundle. Only public values such as the Supabase anon key belong there; access control is enforced by Row Level Security. See [docs/security-case-study-rls.md](docs/security-case-study-rls.md).
- Checkov currently runs with `soft_fail: true`. Findings are to be reviewed and then enforced.

## Troubleshooting log

**Two workflows deploying into one Static Web App.** Azure generated a workflow file when the app was created, and a second one was added manually later. They used different deployment tokens and app locations, so builds overwrote each other and the site served wrong files. Fix: exactly one workflow per Static Web App, with the token of that specific app.

## Roadmap

1. OIDC login from GitHub Actions and `what-if` on pull requests.
2. Monitoring module (Log Analytics, Application Insights, alert rules).
3. Second project: containerised API with database, built and scanned in CI, not run permanently.
