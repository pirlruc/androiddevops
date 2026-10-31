# AI agent handoff — androiddevops

## Identity

| Field | Value |
| --- | --- |
| **Remote** | https://github.com/pirlruc/androiddevops (public). The owner can set the repo private. Do not change visibility from an agent session. |
| **Branch** | `main`. Tag **1.0.0** is the first reusable release. Tag **1.0.1** adds `pre_command` and `post_command`. Do not move `1.0.0`. |
| **Role** | Reusable GitHub Actions for Android Gradle callers |

## Pins

| Component | Ref |
| --- | --- |
| guardrails | tag **1.13.1** → `1945211ac851c3c0f83694bd4ea53571fdced4ab` |
| github-scaffold | tag **1.10.2** → `c8eddcfb2c8a808981e640fa9739cb4fcefa991e` |
| commondevops | tag **5.7.0** → `01d993bc72eebc8806ae85f9459c4f3d6dd3415e` |
| ci-lint (Actions amd64) | `sha256:f9001c4c8726f72107545094237d4fc0592baca023cfa299a532634666d88111` |
| osv-scanner | `2.6.0` `sha256:ca69b3d3cd08f889a49dc0a383122f71cc528b83803671df5fd874d97485b108` |

## Delivery status

| Epic | Status |
| --- | --- |
| AND-001 reusable workflows | done on the 1.0.0 branch |
| AND-002 finsilo and heimdall adoption | open. Do not edit those repos from here. |

## Private later

GitHub does not let a public repository call a reusable workflow stored in a
private repository. After this repo is private, [mat-aventuras](https://github.com/pirlruc/mat-aventuras)
and [finsilo](https://github.com/pirlruc/finsilo) stop at `uses:`.
[heimdall](https://github.com/pirlruc/heimdall) is private and keeps working
if Actions access allows this repo and the caller passes `checkout_token`.
The fix for a public caller is to copy the workflow at its tag into that repo.

This repo's own CI reads commondevops the same way. commondevops is public
today and has the same limit once it is private. Pass
`COMMONDEVOPS_READ_TOKEN` when that happens. `github.token` is the fallback
while commondevops is public.

`docs/guardrail-deviations.yml` records CI-032, SC-SIGN-001, and REL-PUB-004
for the Free private plan. None of them lower a number. Dependabot
`registries: github-private` stays commented until `DEPENDABOT_GITHUB_TOKEN`
exists as a Dependabot secret.

Actions access on `ci-lint` and `ci-supply-chain` is granted for this repo.
Own CI pulls `ci-lint` only.

## Commands

```bash
sh scripts/check-submodule-pins.sh
actionlint .github/workflows/*.yml
shellcheck scripts/*.sh
python3 .github/scaffold/scripts/issues-sync.py --yaml docs/issues.yml --validate-only
```

*Last updated: 2026-10-31 (reusable workflows, tag 1.0.0)*
