#!/usr/bin/env bash
# CycloneDX SBOM of the runtime classpath for a built APK, then OSV
# (SC-SBOM-001 / SC-SBOM-002). Fail closed if the APK, the dependency
# report, or osv-scanner is missing (CI-035). High/Critical findings fail
# the job (CI-005).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CALLER_ROOT:-$(pwd)}"
OSV_VERSION="2.6.0"
OSV_SHA256="ca69b3d3cd08f889a49dc0a383122f71cc528b83803671df5fd874d97485b108"

if [[ $# -ne 1 || ! -f $1 ]]; then
	echo "error: pass the built APK path" >&2
	exit 1
fi

apk_dir="$(cd "$(dirname "$1")" && pwd)"
APK="${apk_dir}/$(basename "$1")"
WORKDIR="${TMPDIR:-/tmp}/androiddevops-osv-sbom"
mkdir -p "$WORKDIR"
OSV="${WORKDIR}/osv-scanner"
DEPS="${DEPS_FILE:-${WORKDIR}/debug-runtime.txt}"
SBOM="${WORKDIR}/app.cdx.json"
SARIF="${WORKDIR}/osv.sarif"

install_osv() {
	local url helper
	helper="${COMMONDEVOPS_SCRIPTS:-}/fetch-verified.sh"
	if [[ ! -f $helper ]]; then
		echo "error: COMMONDEVOPS_SCRIPTS must contain fetch-verified.sh" >&2
		exit 1
	fi
	# shellcheck disable=SC1091
	source "$helper"
	url="https://github.com/google/osv-scanner/releases/download/v${OSV_VERSION}/osv-scanner_linux_amd64"
	fetch_verified "$url" "$OSV" "$OSV_SHA256"
	chmod +x "$OSV"
}

if [[ ! -x $OSV ]]; then
	install_osv
fi
if [[ ! -x $OSV ]]; then
	echo "error: osv-scanner is not executable" >&2
	exit 1
fi

if [[ -z ${DEPS_FILE:-} ]]; then
	(
		cd "$ROOT"
		./gradlew --no-daemon :app:dependencies --configuration debugRuntimeClasspath --console=plain
	) >"$DEPS"
fi

python3 "${SCRIPT_DIR}/gradle-to-cyclonedx.py" "$APK" "$DEPS" "$SBOM"

status=0
"$OSV" scan source -L "$SBOM" --format sarif --output-file "$SARIF" --verbosity error || status=$?
if [[ $status -gt 1 ]]; then
	echo "error: osv-scanner failed (${status})" >&2
	exit "$status"
fi
if [[ ! -s $SARIF ]]; then
	echo "error: osv-scanner wrote no SARIF" >&2
	exit 1
fi

python3 "${SCRIPT_DIR}/fail-on-sarif-severity.py" --min-severity high "$SARIF"
bash "${SCRIPT_DIR}/run-grype-cyclonedx.sh" "$SBOM"
python3 "${SCRIPT_DIR}/check-cyclonedx-licenses.py" "$SBOM"
