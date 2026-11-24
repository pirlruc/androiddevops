#!/bin/sh
# Run CI steps missing on the host inside ci-lint.
# POSIX sh. The image digest is ci-lint 6.8.0 Debian, which has bash.
#
# Env:
#   ADO_CI_IMAGE     — override the image (digest pin by default)
#   ADO_DOCKER_STEPS — space-separated step names (required)
#
# Steps: actionlint shellcheck zizmor hadolint
set -eu

SCRIPT_DIR="$(dirname "$0")"
SCRIPT_DIR="$(cd "${SCRIPT_DIR}" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
IMAGE="${ADO_CI_IMAGE:-ghcr.io/pirlruc/ci-lint@sha256:3ed6d8dcbb08abf82e563630f2c1218cf0e8f33bb883ed46770e147113af48b0}"

if [ -z "${ADO_DOCKER_STEPS:-}" ]; then
	echo "ADO_DOCKER_STEPS is required (e.g. shfmt ruff zizmor)" >&2
	exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
	echo "docker is required for host-unavailable CI checks" >&2
	exit 1
fi

echo "==> Pulling ${IMAGE}"
docker pull "${IMAGE}"

echo "==> Running in Docker: ${ADO_DOCKER_STEPS}"
docker run --rm \
	-v "${ROOT}:/workspace:ro" \
	-w /workspace \
	-e "ADO_DOCKER_STEPS=${ADO_DOCKER_STEPS}" \
	--entrypoint sh \
	"${IMAGE}" \
	-c '
    set -eu
    run_step() {
      case "$1" in
        actionlint) actionlint .github/workflows/*.yml ;;
        shellcheck) shellcheck --severity=error scripts/*.sh ;;
        zizmor) zizmor --min-severity=low .github/workflows ;;
        hadolint) hadolint docker/android-maestro/Dockerfile ;;
        *) echo "unknown step: $1" >&2; return 1 ;;
      esac
    }
    for step in ${ADO_DOCKER_STEPS}; do
      echo "==> ${step}"
      run_step "${step}"
    done
  '
