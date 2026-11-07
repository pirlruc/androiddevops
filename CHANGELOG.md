# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

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
