# androiddevops

Reusable GitHub Actions workflows for Android builds, scans, emulator tests, and signed APKs.

Pin every `uses:` to a **commit SHA**. Pass that same SHA as `scripts_ref`.
A private caller also passes `checkout_token`. The current tag is **1.2.0**.
Use the commit that tag points at:

```yaml
uses: pirlruc/androiddevops/.github/workflows/android-gradle-ci.yml@<sha>
with:
  scripts_ref: <sha>
```

If this repository is made private, a public caller cannot use `workflow_call`.
That caller has to vendor the pinned workflow file instead. A private caller,
such as [heimdall](https://github.com/pirlruc/heimdall), keeps working when it
passes `checkout_token`.

[mat-aventuras](https://github.com/pirlruc/mat-aventuras) is the first caller.
[finsilo](https://github.com/pirlruc/finsilo) and heimdall still inline their
Android jobs.

## Workflows

| Workflow | Purpose |
| --- | --- |
| [android-gradle-ci.yml](.github/workflows/android-gradle-ci.yml) | JDK, Android SDK, wrapper check, one Gradle command |
| [android-codeql.yml](.github/workflows/android-codeql.yml) | CodeQL java-kotlin, manual build |
| [android-mobsf.yml](.github/workflows/android-mobsf.yml) | mobsfscan with a hash-pinned install |
| [android-apk-sbom.yml](.github/workflows/android-apk-sbom.yml) | Runtime-classpath CycloneDX and osv-scanner |
| [android-emulator.yml](.github/workflows/android-emulator.yml) | Instrumented tests on an emulator |
| [android-release-apk.yml](.github/workflows/android-release-apk.yml) | Signed release APK and a CycloneDX bill. Empty keystore secrets fail the job unless `allow_unsigned` is true. Pass `environment` when the keystore is an environment secret. |

Inputs are in [docs/workflows.md](docs/workflows.md).
