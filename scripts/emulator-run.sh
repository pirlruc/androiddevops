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
