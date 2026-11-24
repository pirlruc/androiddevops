# AI agent handoff — androiddevops

## Identity

| Field | Value |
| --- | --- |
| **Remote** | <https://github.com/pirlruc/androiddevops> (public). The owner can set the repo private. Do not change visibility from an agent session. |
| **Branch** | `main`. Published tip is **1.10.0** (`0e3d9e2c081a0d583b77b11e333f0fccb261e50c`). `android-maestro` publishes to GHCR. |
| **Role** | Reusable GitHub Actions for Android Gradle callers |

## Pins

| Component | Ref |
| --- | --- |
| guardrails | tag **1.17.0** → `9a17ebb269a5ab02899570dd3e40fb72e50ad762` |
| github-scaffold | tag **1.14.0** → `da8942edf17a0d2736d297c90338fd78b7ec31fb` |
| commondevops | v6.9.0 `5d8b83da2f8f0c0c1bd894ef920619fe127c033e`. SBOM and actionlint downloads source `fetch-verified.sh` from v6.9.1. |
| containerdevops | tag **6.8.0** → `ae9dbee9e4537bd3a0b533de3bad011cb44b201e` |
| ci-lint (Actions amd64) | `sha256:f9001c4c8726f72107545094237d4fc0592baca023cfa299a532634666d88111` |
| osv-scanner | `2.6.0` `sha256:ca69b3d3cd08f889a49dc0a383122f71cc528b83803671df5fd874d97485b108` |

## Delivery status

| Epic | Status |
| --- | --- |
| AND-001 reusable workflows | done on the 1.0.0 branch |
| AND-002 finsilo and heimdall adoption | open. finsilo stays on its inline jobs. heimdall calls `android-gradle-ci.yml` at 1.3.0 (`a41e029`, merge `d11d939`) and passes `checkout_token`. |
| AND-003 fail closed and emulator boot | done on the 1.2.0 branch |
| AND-004 runner SDK packages | done on the 1.3.0 branch. No Android SDK image. |
| AND-005 Maestro image | done. GHCR digest `sha256:aba49b8d5f8d87c291a6e6c59b9163d071ade024f85de61e87be1c9869b030da`. Doksi and Arbigent are not images here: Doksi is a paid cloud service, and Arbigent was skipped. |

## Private later

GitHub does not let a public repository call a reusable workflow stored in a
private repository. After this repo is private, [mat-aventuras](https://github.com/pirlruc/mat-aventuras)
and [finsilo](https://github.com/pirlruc/finsilo) stop at `uses:`.
[heimdall](https://github.com/NjordLabs/heimdall) is private and keeps working
if Actions access allows this repo and the caller passes `checkout_token`.
The fix for a public caller is to copy the workflow at its tag into that repo.

This repo's own CI reads commondevops the same way. commondevops is public
today and has the same limit once it is private. Pass
`COMMONDEVOPS_READ_TOKEN` when that happens. `github.token` is the fallback
while commondevops is public.

`docs/guardrail-deviations.yml` records SC-SIGN-001 and DOCKER-SEC-001.
CI-032 is retired. The repo is public. REL-PUB-004 is retired:
callers pass `environment` and this repo has no publish token. None of the
remaining entries lower a number. Dependabot
`registries: github-private` stays commented until `DEPENDABOT_GITHUB_TOKEN`
exists as a Dependabot secret.

Actions access on `ci-lint` and `ci-supply-chain` is granted for this repo.
Own CI pulls `ci-lint` only.

## Commands

```bash
bash scripts/check-ci-local.sh
```

The mobsfscan lock is `scripts/requirements-mobsfscan.txt`, compiled from
`scripts/requirements-mobsfscan.in` with `scripts/mobsfscan-overrides.txt`.
The command is the lock header. Do not hand-edit the lock.

The Maestro image is `docker/android-maestro`. Local CI builds
`android-maestro:local` and runs container-structure-test 1.19.3. High
findings in the pinned CLI zip are listed in
`docker/android-maestro/.trivyignore.yaml` and `.grype.yaml`
(DOCKER-SEC-001). Do not drop those ids to make a scan pass. The
published digest from the 1.4.0 release workflow:

| Image | Digest |
| --- | --- |
| android-maestro 1.4.0 | `sha256:aba49b8d5f8d87c291a6e6c59b9163d071ade024f85de61e87be1c9869b030da` |

*Last updated: 2026-11-24 — 1.10.0. Callers pin commondevops v6.9.0 and containerdevops 6.8.0. Tool downloads use `fetch-verified.sh`.*

*Last updated: 2026-11-03 (1.4.0 Maestro digest recorded).*

*Last updated: 2026-11-04 — filed documentation follow-up epics moved out of guardrails, methodologies, or github-scaffold. Not implemented here.*

*Last updated: 2026-11-07 — 1.6.0. Temurin 25 Maestro image. mcp 2.3.0. commondevops 6.1.0. containerdevops 6.5.0. SC-SIGN-001 stays because a Release has no separate binary.*

*Last updated: 2026-11-07 — default-branch ruleset requires pins and scaffold / verify. CI-032 is retired. Scorecard policy is docs/scorecard-open-checks.md.*

*Last updated: 2026-11-23 — 1.9.0. Guardrails 1.17.0. Scaffold 1.14.0. Maestro publish still pins containerdevops 6.5.0.*

*Last updated: 2026-11-21 — `android-gradle-ci` can clone a pinned vcpkg and cache binaries by triplet. The registry token stays in the job environment.*

*Last updated: 2026-11-18 — `android-gradle-ci` takes `runs_on`. The default stays `ubuntu-24.04`. A caller passes a JSON label array for a self-hosted runner. The job installs `unzip` when it is missing, and skips `sudo` when the job is already root.*
