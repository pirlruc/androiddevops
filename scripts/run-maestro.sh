#!/bin/sh
# Run a Maestro flow against a device that is already attached.
# The CLI is ghcr.io/pirlruc/android-maestro. This script fails when adb
# has no device, so a missing emulator is not a green skip.
set -eu

IMAGE="${MAESTRO_IMAGE:-ghcr.io/pirlruc/android-maestro:1.4.0}"

if ! command -v adb >/dev/null 2>&1; then
	echo "adb is not on PATH" >&2
	exit 1
fi

attached="$(adb devices | awk 'NR > 1 && $2 == "device" { print $1 }')"
if [ -z "${attached}" ]; then
	echo "no device is attached" >&2
	exit 1
fi

if [ "$#" -eq 0 ]; then
	echo "pass a Maestro flow path" >&2
	exit 1
fi

exec docker run --rm \
	-v "${PWD}:/work" \
	-w /work \
	"${IMAGE}" \
	maestro test "$@"
