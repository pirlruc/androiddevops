# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
