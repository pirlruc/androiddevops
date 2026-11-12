#!/bin/sh
# Run a Maestro flow against a device that is already attached.
# The image digest is the published android-maestro pin. This script fails
# when adb has no device, so a missing emulator is not a green skip.
set -eu

IMAGE="${MAESTRO_IMAGE:-ghcr.io/pirlruc/android-maestro@sha256:aba49b8d5f8d87c291a6e6c59b9163d071ade024f85de61e87be1c9869b030da}"

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

sdk="${ANDROID_HOME:-${HOME}/Android/Sdk}"
os="$(docker info --format '{{.OperatingSystem}}' 2>/dev/null || true)"
net="--network host"
relay=""
if printf '%s' "${os}" | grep -q "Docker Desktop"; then
	adb -a start-server >/dev/null 2>&1 || true
	net="--add-host=host.docker.internal:host-gateway"
	relay="-e ADB_SERVER_SOCKET=tcp:host.docker.internal:5037"
fi

mount=""
path_env=""
if [ -d "${sdk}/platform-tools" ]; then
	mount="-v ${sdk}/platform-tools:/opt/platform-tools:ro"
	path_env="-e PATH=/opt/platform-tools:/opt/maestro/bin:/opt/java/openjdk/bin:/usr/bin"
fi

# shellcheck disable=SC2086
exec docker run --rm ${net} ${relay} ${mount} ${path_env} \
	-v "${PWD}:/work" \
	-w /work \
	"${IMAGE}" \
	maestro test "$@"
