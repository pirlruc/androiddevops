# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
