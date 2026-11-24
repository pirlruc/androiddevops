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
| guardrails | tag **1.17.1** → `8508e93691aa3c4f769ecc215ddc83ecf26e70b2` |
| github-scaffold | tag **1.14.2** → `615dbbcbe906d62a29e4f4e4118cb94cb119f5a5` |
| commondevops | v6.10.0 `a2af891c6d05fe2790bc5ddf761252c95185ce5f` |
| containerdevops | tag **6.8.0** → `ae9dbee9e4537bd3a0b533de3bad011cb44b201e` |
| ci-lint (Actions amd64) | `6.8.0` `sha256:3ed6d8dcbb08abf82e563630f2c1218cf0e8f33bb883ed46770e147113af48b0` |
| osv-scanner | `2.6.0` `sha256:ca69b3d3cd08f889a49dc0a383122f71cc528b83803671df5fd874d97485b108` |

## Delivery status

| Epic | Status |
| --- | --- |
| AND-001 reusable workflows | done on the 1.0.0 branch |
| AND-002 finsilo and heimdall adoption | deferred, still open. finsilo stays on its inline jobs. heimdall calls `android-gradle-ci.yml` at 1.3.0 (`a41e029`, merge `d11d939`) and passes `checkout_token`. |
| AND-003 fail closed and emulator boot | done on the 1.2.0 branch |
| AND-004 runner SDK packages | done on the 1.3.0 branch. No Android SDK image. |
| AND-005 Maestro image | done. 1.10.0 linux/amd64 `sha256:b11c589ebfcb9b518074d8b9d0974cd8e225562d24c8d046df009c5c51f174e0`. Doksi and Arbigent are not images here: Doksi is a paid cloud service, and Arbigent was skipped. |

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
`registries:` in `.github/dependabot.yml` is active.

Actions access on `ci-lint` and `ci-supply-chain` is granted for this repo.
`scripts/check-ci-docker.sh` pulls `ci-lint`. The DevOps CI job container is
`ghcr.io/catthehacker/ubuntu:act-24.04`, because `ci-lint` 6.8.0 has no gzip
and `actions/checkout` cannot unpack. The default-branch ruleset requires a
check named `pins`. `ops-repo-ci` reports that job as `ops-ci / pins / pins`,
so `devops-ci.yml` keeps a `pins` job that needs `ops-ci`.

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
published digest from the 1.10.0 release:

| Image | Digest |
| --- | --- |
| android-maestro 1.10.0 linux/amd64 | `sha256:b11c589ebfcb9b518074d8b9d0974cd8e225562d24c8d046df009c5c51f174e0` |

*Last updated: 2026-11-24 — 1.11.0. Self-CI calls ops-repo-ci from commondevops v6.10.0 in the act image. A pins job satisfies the ruleset. AND-002 stays open and deferred. Dependabot registries are active.*
