# Workflows

Pin `uses:` to a commit SHA. Pass that SHA as `scripts_ref`. Pass
`secrets.checkout_token` as `github.token` while this repo is public, and as a
contents:read token after it is private.

A public caller cannot call these workflows once this repository is private.
Copy the workflow file at the pinned tag into the caller instead.

Tag 1.2.0 is the current release. Replace `<sha>` below with the commit that
tag points at, and pass the same value as `scripts_ref`.

```yaml
jobs:
  android:
    permissions:
      contents: read
    uses: pirlruc/androiddevops/.github/workflows/android-gradle-ci.yml@<sha>
    with:
      scripts_ref: <sha>
    secrets:
      checkout_token: ${{ secrets.GITHUB_TOKEN }}
```

Every workflow takes `scripts_ref` (required, 40 hex characters) and the
optional secret `checkout_token`.

## `android-gradle-ci.yml`

| Input | Default | Meaning |
| --- | --- | --- |
| `java_version` | `17` | Temurin major version |
| `gradle_tasks` | `:app:assembleDebug` | The Gradle invocation |
| `validate_wrapper` | `true` | Run wrapper validation before Gradle |
| `upload_apk` | `false` | Upload `apk_path` as `artifact_name` for one day |
| `apk_path` | `app/build/outputs/apk/debug/app-debug.apk` | APK to upload |
| `artifact_name` | `android-apk` | Artifact name |
| `pre_command` | empty | Shell after checkout. `command_token` is exported as `GUARDRAILS_READ_TOKEN` |
| `post_command` | empty | Shell after Gradle |

`command_token` is an optional secret.

## `android-codeql.yml`

| Input | Default | Meaning |
| --- | --- | --- |
| `java_version` | `17` | Temurin major version |
| `build_command` | required | Compile command CodeQL traces |
| `upload` | `never` | `never`, `always`, or `failure-only` |
| `min_severity` | `high` | SARIF rank that fails the job |

The analyze job keeps `contents: read`. A separate job uploads SARIF and is
the only job with `security-events: write`. It runs when `upload` is not
`never`.

## `android-mobsf.yml`

| Input | Default | Meaning |
| --- | --- | --- |
| `python_version` | `3.12` | Interpreter for the hash-locked install |
| `source_paths` | `app/src/main domain/src/main data/src/main` | Space-separated scan roots |
| `min_severity` | `high` | SARIF rank that fails the job |

The install uses `scripts/requirements-mobsfscan.txt` with
`--require-hashes --no-deps`, because the lock overrides semgrep's exact pins.
Regenerate that lock from `scripts/requirements-mobsfscan.in` and
`scripts/mobsfscan-overrides.txt` with the command in the lock header.

## `android-apk-sbom.yml`

| Input | Default | Meaning |
| --- | --- | --- |
| `java_version` | `17` | Temurin major version |
| `assemble_task` | `:app:assembleDebug` | Task that produces the APK |
| `apk_path` | `app/build/outputs/apk/debug/app-debug.apk` | APK passed to the bill |
| `gradle_configuration` | `debugRuntimeClasspath` | Configuration printed for the bill |

osv-scanner 2.6.0 is pinned by SHA-256. High and critical findings fail.

## `android-emulator.yml`

| Input | Default | Meaning |
| --- | --- | --- |
| `java_version` | `17` | Temurin major version |
| `api_level` | `36` | System image API level |
| `target` | `google_apis` | System image target |
| `arch` | `x86_64` | System image architecture |
| `script` | `./gradlew --no-daemon :app:connectedDebugAndroidTest` | Command run after boot |
| `boot_timeout_seconds` | `600` | Digits. Wait for `sys.boot_completed` |
| `pre_emulator_script` | empty | Shell before the emulator process. Written to a file, not inlined |
| `retry_count` | `1` | `0` or `1` extra attempt |

The job enables KVM before boot and refuses to fall back to software
acceleration. The runner `script:` is one line,
`bash .androiddevops/scripts/emulator-run.sh`. The caller command is passed
in the environment. Keep this workflow off pull requests.

## `android-release-apk.yml`

| Input | Default | Meaning |
| --- | --- | --- |
| `environment` | empty | GitHub Environment selected by the build job |
| `java_version` | `17` | Temurin major version |
| `gradle_task` | `:app:assembleRelease` | Task that produces the APK |
| `artifact_name` | `android-release-apk` | Artifact name. Pass the same name to common-release |
| `sbom` | `true` | Write `sbom_name` from `gradle_configuration` and fail on high or critical OSV findings |
| `gradle_configuration` | `releaseRuntimeClasspath` | Configuration printed for the bill |
| `sbom_name` | `app-release.cdx.json` | Bill file name inside the artifact |
| `allow_unsigned` | `false` | When false, empty keystore secrets fail the job |

Signing secrets, all or none: `keystore_base64`, `keystore_password`,
`key_alias`, `key_password`. The step appends them to `gradle.properties`
and restores that file when it exits. They are not Gradle command arguments.
The keystore file is removed when the step exits. A signed build must
produce `app-release.apk`. Gradle dependency cache is off on this job.

Pass that artifact name to
[common-release](https://github.com/pirlruc/commondevops/blob/5.8.0/.github/workflows/common-release.yml)
`release_artifact` from a later job in the same run. common-release writes the
`.sha256` files. The caller job cannot set `environment` on this workflow; the
`environment` input is what selects it.
