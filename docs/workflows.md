# Workflows

Pin `uses:` to a commit SHA. Pass that SHA as `scripts_ref`. Pass
`secrets.checkout_token` as `github.token` while this repo is public, and as a
contents:read token after it is private.

A public caller cannot call these workflows once this repository is private.
Copy the workflow file at the pinned tag into the caller instead.

## `android-gradle-ci.yml`

One JDK 17 (override with `java_version`), Android SDK, optional wrapper
validation, and one `./gradlew` invocation (`gradle_tasks`). Set `upload_apk`
to upload `apk_path` as `artifact_name` for one day.

## `android-codeql.yml`

CodeQL java-kotlin, `build-mode: manual`. `build_command` is the compile.
`upload` defaults to `never` so a private Free-plan caller does not need code
scanning. The job still fails on SARIF at `min_severity` (default `high`).

## `android-mobsf.yml`

Installs mobsfscan from `scripts/requirements-mobsfscan.txt` with
`--require-hashes`. `source_paths` is a space-separated list.

## `android-apk-sbom.yml`

Runs `assemble_task`, writes a CycloneDX bill from `gradle_configuration`, and
runs osv-scanner 2.6.0 pinned by SHA-256. High and critical findings fail.

## `android-emulator.yml`

`ReactiveCircus/android-emulator-runner` with `api_level`, `target`, `arch`,
and `script`. Keep this off pull requests.

## `android-release-apk.yml`

Runs `gradle_task` (default `:app:assembleRelease`) and uploads
`android-release-apk`. Pass that artifact name to
[common-release](https://github.com/pirlruc/commondevops/blob/5.7.0/.github/workflows/common-release.yml)
`release_artifact` from a later job in the same run. common-release writes the
`.sha256` files.

Signing secrets, all or none: `keystore_base64`, `keystore_password`,
`key_alias`, `key_password`. Empty `keystore_base64` builds an unsigned APK.
