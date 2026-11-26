# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.12.2] - 2026-11-26

### Changed

- APK bill jobs and self-CI pin commondevops v6.12.0.

## [1.12.1] - 2026-11-24

### Fixed

- `android-release-apk.yml` and `android-apk-sbom.yml` check out `fetch-verified.sh` from commondevops v6.11.0 and set `COMMONDEVOPS_SCRIPTS` before `run-osv-sbom.sh`.

## [1.12.0] - 2026-11-24

### Added

- `android-jvm-fuzz.yml` runs a caller-selected Gradle test with `FUZZ_ITERATIONS` set. It is a schedule or dispatch job, not a pull-request gate.
- `android-emulator.yml` accepts `maestro_flows`. An empty value skips Maestro. A set value runs the digest-pinned `android-maestro` image after the caller script.

## [1.11.0] - 2026-11-24

### Changed

- Self-CI calls `ops-repo-ci` from commondevops v6.10.0. A `pins` job keeps the ruleset check name. A Friday schedule runs the same reusable with Scorecard.
- Maestro builds on the current Temurin 25 manifests. The mobsfscan lock keeps semgrep 1.186.0 and moves wcmatch to 12.0.4.
- Downloads retry. The security page links to the advisory form.

## [1.10.0] - 2026-11-24

### Fixed

- Reusable concurrency groups use the caller ref. A group that included `github.run_id` never cancelled a superseded run (CI-002).
- The Maestro publish passes `image_documentation` and `image_url`, and the digest job checks out commondevops v6.9.0 (DOCKER-DOC-001).
- Tool downloads retry a transport failure (CI-054).

### Changed

- Maestro image jobs pin containerdevops 6.8.0. Self-CI pins commondevops v6.9.0.
- Docs name tag 1.10.0 and the `runs_on`, `guardrail_checks`, and vcpkg inputs.

## [1.9.0] - 2026-11-23

### Added

- The reusable workflows set `concurrency` (CI-002).

### Changed

- `docs/guardrails` is 1.17.0 and `.github/scaffold` is 1.14.0.
- AND-VCPKG-001 is done. AND-002 is deferred because the remaining caller is finsilo.

## [1.8.0] - 2026-11-21

### Added

- `android-gradle-ci` takes `runs_on`. The default stays the GitHub-hosted `ubuntu-24.04` label. A caller passes a JSON array to select a self-hosted runner.
- `android-gradle-ci` installs `unzip` into the job home when the runner does not have it. The homelab job user is not root, and `sudo` cannot run.
- `android-gradle-ci` takes `enable_vcpkg`. When set, the job clones microsoft/vcpkg at `vcpkg_commit`, exports `VCPKG_ROOT`, and caches the binary directory by triplet, commit, and manifest. `registry_token` authenticates a private registry for that job only.

### Changed

- DevOps CI and the Maestro digest job pin commondevops `c775138` (6.1.1), including `scripts_ref`.
- The MobSF override uses semgrep 1.185.0.

## [1.7.0] - 2026-11-12

### Added

- Runtime-classpath bills are scanned with checksum-pinned grype and a CycloneDX license deny list.
- `android-gradle-ci` takes `guardrail_checks` for the Kotlin and Android scripts.
- `run-maestro.sh` pins the image digest and reaches the host adb server from Docker Desktop.

## [1.6.0] - 2026-11-07

### Added

- `android-maestro-image` appends the published image digest to the GitHub Release.

### Changed

- Callers pin commondevops 6.1.0 and containerdevops 6.5.0. Image publish passes `environment: release` only on a release event.
- setup-java is v6.2.0 and CodeQL is v4.39.3.
- android-maestro is Temurin 25. The fetch stage installs curl because that JRE image does not ship it.
- The mobsfscan override pins mcp 2.3.0. The lock installs and `import mcp` succeeds.
- SC-SIGN-001 stays. The image publish job sets `sign` when the repository is public. A GitHub Release still has no separate binary to sign.
- `templates/ci-android.yml` pins the 1.5.0 tag commit.

## [1.5.0] - 2026-11-07

### Added

- `.devcontainer/`, `templates/ci-android.yml`, and `scripts/run-maestro.sh`.
  The Maestro script fails when no device is attached (AND-DOC-001).
- Dependabot updates git submodules outside the grouped pull request.
  Non-LTS Temurin 22, 23, and 24 stay ignored (KT-BUILD-001).

### Changed

- `.gitmodules` keeps the path-named stanzas.
- Guardrails 1.15.0, github-scaffold 1.12.0, commondevops 6.0.1, and
  containerdevops 6.4.0. Scaffold verify receives `packs_token`.
- The Dependabot actionlint job installs zizmor in a virtualenv.
- `android-gradle-ci` no longer checks out an unused README.
- README links for heimdall point at NjordLabs. SECURITY.md links the
  advisories page. Trivy ignores expire on 2026-12-06 and Grype ignores
  carry that review date.
- AND-002-T1 is rejected. The finsilo adoption lives in that repo.

## [1.4.0] - 2026-11-03

### Added

- `android-maestro` image: Maestro CLI 2.12.1 on Temurin 21, user 1000.
  The zip sha256 is checked at build time. The image does not include the
  Android SDK. `--network host` reaches a Linux engine's adb server. Docker
  Desktop sets `ADB_SERVER_SOCKET` and the image relays `127.0.0.1:5037`,
  because Maestro does not read that variable itself. Published to GHCR from
  the release workflow. Docker Hub is not a target until this repo has
  registry secrets.
- Dependabot covers `docker/android-maestro`. Local CI builds the image and
  runs container-structure-test. High findings inside the pinned Maestro zip
  are listed in `.trivyignore.yaml` and `.grype.yaml` (DOCKER-SEC-001).

## [1.3.0] - 2026-11-03

### Added

- `android-gradle-ci` accepts `sdk_packages` and installs them with
  `sdkmanager` on the runner. Callers that need the NDK pass the package
  ids. This repo does not publish an Android SDK image.
- The same job accepts `cache_path` and `cache_key` for caller build
  outputs.

## [1.2.0] - 2026-11-02

### Changed

- `android-release-apk` fails when the keystore secrets are empty.
  `allow_unsigned: true` is the explicit unsigned build. Passwords are
  a temporary `gradle.properties` that the step restores, and the keystore
  file is removed when the step exits. Dotted `ORG_GRADLE_PROJECT_*` names
  never reach the Gradle JVM. A signed build must produce `app-release.apk`.
  The release job does not restore the Gradle cache.
- `android-emulator` enables KVM and runs the boot wait from
  `scripts/emulator-run.sh`, so the caller command is not inlined into the
  runner script. `boot_timeout_seconds` must be digits and `retry_count`
  must be `0` or `1`.
- The mobsfscan lock overrides semgrep, mcp, PyJWT, and opentelemetry-api
  onto patched releases. The install uses `--no-deps` because a resolver
  rejects those overrides. Dependabot covers `scripts/` as pip.
- `android-apk-sbom` and `android-mobsf` reject a `scripts_ref` that is not
  a full commit SHA. CodeQL uploads SARIF from a job that only writes
  security events.
- DevOps CI calls commondevops 5.8.0, runs shfmt, and lints every script.
  Dependabot pull requests run actionlint without the private lint image.

## [1.1.1] - 2026-11-02

### Fixed

- `android-release-apk` accepts an `environment` input and selects that
  GitHub Environment on the build job, so keystore secrets stored only
  there are available. An empty value leaves the job without an environment.

## [1.1.0] - 2026-11-01

### Added

- `android-release-apk` writes a CycloneDX bill of `releaseRuntimeClasspath`
  and uploads `app-release.cdx.json` beside the APK. `sbom: false` skips it.
  High and critical OSV findings fail the job.
- `android-emulator` disables animations, waits for `sys.boot_completed`, and
  retries the run once. `boot_timeout_seconds`, `pre_emulator_script`, and
  `retry_count` are inputs.

## [1.0.2] - 2026-10-31

### Fixed

- A caller that omits `checkout_token` no longer passes an empty token into
  `actions/checkout`, which rejects it. The job falls back to `github.token`.

## [1.0.1] - 2026-10-31

### Added

- `android-gradle-ci` accepts `pre_command`, `post_command`, and an optional
  `command_token` secret exported as `GUARDRAILS_READ_TOKEN`.

## [1.0.0] - 2026-10-31

### Added

- Reusable workflows for Gradle, CodeQL, MobSF, the APK bill, an emulator,
  and a release APK. Callers pin a commit SHA and pass it as `scripts_ref`.
