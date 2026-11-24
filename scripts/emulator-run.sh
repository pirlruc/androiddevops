#!/usr/bin/env bash
# Wait until the emulator reports boot, then run the caller command.
# android-emulator-runner executes each script line with sh -c, so the wait
# lives in this file and the workflow passes a single bash invocation.
set -euo pipefail

if [[ ! "${BOOT_TIMEOUT_SECONDS:-}" =~ ^[0-9]+$ ]]; then
	echo "::error::BOOT_TIMEOUT_SECONDS must be digits" >&2
	exit 1
fi
if [[ -z "${CALLER_SCRIPT:-}" ]]; then
	echo "::error::CALLER_SCRIPT is empty" >&2
	exit 1
fi

adb wait-for-device
deadline=$((SECONDS + BOOT_TIMEOUT_SECONDS))
until adb shell getprop sys.boot_completed | tr -d '\r' | grep -qx 1; do
	if ((SECONDS >= deadline)); then
		echo "::error::emulator did not report sys.boot_completed" >&2
		exit 1
	fi
	sleep 2
done

bash -c "${CALLER_SCRIPT}"

if [[ -z "${MAESTRO_FLOWS:-}" ]]; then
	exit 0
fi
case "${MAESTRO_FLOWS}" in
*..* | /* | *$'\n'*)
	echo "::error::maestro_flows must be a relative directory" >&2
	exit 1
	;;
esac
if [[ ! -d "${MAESTRO_FLOWS}" ]]; then
	echo "::error::maestro_flows directory is missing: ${MAESTRO_FLOWS}" >&2
	exit 1
fi
if [[ ! "${MAESTRO_IMAGE:-}" =~ ^ghcr.io/pirlruc/android-maestro@sha256:[0-9a-f]{64}$ ]]; then
	echo "::error::maestro_image must be ghcr.io/pirlruc/android-maestro pinned by digest" >&2
	exit 1
fi
pulled=0
for _attempt in 1 2 3; do
	if docker pull "${MAESTRO_IMAGE}"; then
		pulled=1
		break
	fi
	sleep 5
done
if [[ "${pulled}" -ne 1 ]]; then
	echo "::error::could not pull the maestro image" >&2
	exit 1
fi
sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
docker run --rm --network host \
	-v "${PWD}:/workspace:ro" \
	-w /workspace \
	-v "${sdk}/platform-tools:/opt/platform-tools:ro" \
	-e PATH="/opt/platform-tools:/opt/maestro/bin:/usr/bin" \
	"${MAESTRO_IMAGE}" \
	maestro test "${MAESTRO_FLOWS}"
