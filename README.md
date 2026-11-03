# androiddevops

Reusable GitHub Actions workflows for Android builds, scans, emulator tests, and signed APKs.

Pin every `uses:` to a **commit SHA**. Pass that same SHA as `scripts_ref`.
A private caller also passes `checkout_token`. The current tag is **1.4.0**.
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

[mat-aventuras](https://github.com/pirlruc/mat-aventuras) calls tag 1.2.0.
[heimdall](https://github.com/pirlruc/heimdall) calls `android-gradle-ci.yml`
at tag 1.3.0 and passes `checkout_token`.
`sdk_packages` installs extra SDK packages, including the NDK, on the
runner. There is no Android SDK image.

## Maestro image

`android-maestro` is the Maestro CLI for a local emulator. It does not
include the Android SDK or `adb`. Point it at the host adb server:

Maestro dials `127.0.0.1:5037`. On a Linux Docker engine, `--network host`
reaches the host adb server:

```bash
docker pull ghcr.io/pirlruc/android-maestro@sha256:aba49b8d5f8d87c291a6e6c59b9163d071ade024f85de61e87be1c9869b030da
docker run --rm --network host \
  -v "$ANDROID_HOME/platform-tools:/opt/platform-tools:ro" \
  -e PATH="/opt/platform-tools:/opt/maestro/bin:/opt/java/openjdk/bin:/usr/bin" \
  -v "$PWD:/workspace" -w /workspace \
  ghcr.io/pirlruc/android-maestro@sha256:aba49b8d5f8d87c291a6e6c59b9163d071ade024f85de61e87be1c9869b030da \
  maestro test .maestro/
```

Docker Desktop does not share the host network namespace. Start adb on all
interfaces (`adb -a start-server`) and set `ADB_SERVER_SOCKET`. The image
relays `127.0.0.1:5037` to that address:

```bash
docker run --rm --add-host=host.docker.internal:host-gateway \
  -v "$ANDROID_HOME/platform-tools:/opt/platform-tools:ro" \
  -e PATH="/opt/platform-tools:/opt/maestro/bin:/opt/java/openjdk/bin:/usr/bin" \
  -e ADB_SERVER_SOCKET=tcp:host.docker.internal:5037 \
  -v "$PWD:/workspace" -w /workspace \
  ghcr.io/pirlruc/android-maestro@sha256:aba49b8d5f8d87c291a6e6c59b9163d071ade024f85de61e87be1c9869b030da \
  maestro test .maestro/
```

Pin `ghcr.io/pirlruc/android-maestro@sha256:aba49b8d5f8d87c291a6e6c59b9163d071ade024f85de61e87be1c9869b030da`.
Tag `1.4.0` points at that digest. Do not install Maestro on the host.
[finsilo](https://github.com/pirlruc/finsilo) still inlines its Android jobs.

## Workflows

| Workflow | Purpose |
| --- | --- |
| [android-gradle-ci.yml](.github/workflows/android-gradle-ci.yml) | JDK, Android SDK, wrapper check, one Gradle command |
| [android-codeql.yml](.github/workflows/android-codeql.yml) | CodeQL java-kotlin, manual build |
| [android-mobsf.yml](.github/workflows/android-mobsf.yml) | mobsfscan with a hash-pinned install |
| [android-apk-sbom.yml](.github/workflows/android-apk-sbom.yml) | Runtime-classpath CycloneDX and osv-scanner |
| [android-emulator.yml](.github/workflows/android-emulator.yml) | Instrumented tests on an emulator |
| [android-release-apk.yml](.github/workflows/android-release-apk.yml) | Signed release APK and a CycloneDX bill. Empty keystore secrets fail the job unless `allow_unsigned` is true. Pass `environment` when the keystore is an environment secret. |
| [android-maestro-image.yml](.github/workflows/android-maestro-image.yml) | Build, scan, and publish the Maestro CLI image to GHCR |

Inputs are in [docs/workflows.md](docs/workflows.md).
