# AI agent handoff — androiddevops

## Identity

| Field | Value |
| --- | --- |
| **Remote** | <https://github.com/pirlruc/androiddevops> (public). The owner can set the repo private. Do not change visibility from an agent session. |
| **Branch** | `main`. Tag **1.4.0** publishes `android-maestro` to GHCR. Tag **1.3.0** installs caller `sdk_packages`. Tag **1.2.0** fails closed without a keystore. Do not move `1.0.0` through `1.3.0`. |
| **Role** | Reusable GitHub Actions for Android Gradle callers |

## Pins

| Component | Ref |
| --- | --- |
| guardrails | tag **1.15.0** → `2d4bb70e95449f6922781716857adeb22badf676` |
| github-scaffold | tag **1.12.0** → `9c443ea978851768f451b1df2020dd86dfb1a967` |
| commondevops | tag **6.1.0** → `2c5e1ebe9797828128e01f3941b5a02650abe59a` |
| containerdevops | tag **6.5.0** → `b8c0746603eefdc89571b17c62d1e965b28ff31f` |
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

`docs/guardrail-deviations.yml` records CI-032 and SC-SIGN-001. The repo is
public, so the old Free-plan rationale is gone. REL-PUB-004 is retired:
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

*Last updated: 2026-11-03 (1.4.0 Maestro digest recorded).*

*Last updated: 2026-11-04 — filed documentation follow-up epics moved out of guardrails, methodologies, or github-scaffold. Not implemented here.*

*Last updated: 2026-11-07 — 1.6.0. Temurin 25 Maestro image. mcp 2.3.0. commondevops 6.1.0. containerdevops 6.5.0. SC-SIGN-001 stays because a Release has no separate binary.*

*Last updated: 2026-11-07 — default-branch ruleset requires pins and scaffold / verify. CI-032 is retired. Scorecard policy is docs/scorecard-open-checks.md.*

*Last updated: 2026-11-12 — The private caller link cites NjordLabs/heimdall. SBOM jobs scan the Gradle bill with grype and a license deny list. guardrail_checks stays opt-in.*
