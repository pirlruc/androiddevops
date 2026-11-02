#!/usr/bin/env bash
# Local CI parity (CI-008). Host PATH first; no extra OS packages.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

uv run --with pyyaml python scripts/validate-yaml.py \
	docs/issues.yml \
	docs/guardrail-deviations.yml \
	docs/issues-sync-targets.yml \
	.github/dependabot.yml \
	.github/workflows/*.yml
sh scripts/check-submodule-pins.sh
python3 scripts/lint-doc-links.py --root "$ROOT"
uv run --with pytest python -m pytest scripts/tests -q

if [[ -f .github/scaffold/scripts/issues-sync.py ]]; then
	python3 .github/scaffold/scripts/issues-sync.py --yaml docs/issues.yml --validate-only
fi

queued=""
if command -v actionlint >/dev/null 2>&1; then
	actionlint .github/workflows/*.yml
else
	queued="${queued} actionlint"
fi
if command -v shellcheck >/dev/null 2>&1; then
	shellcheck --severity=error scripts/*.sh
else
	queued="${queued} shellcheck"
fi
if command -v shfmt >/dev/null 2>&1; then
	shfmt -d scripts/*.sh
else
	shfmt_bin="$(mktemp)"
	curl -sSfL -o "${shfmt_bin}" \
		https://github.com/mvdan/sh/releases/download/v3.11.0/shfmt_v3.11.0_linux_amd64
	echo "1904ec6bac715c1d05cd7f6612eec8f67a625c3749cb327e5bfb4127d09035ff  ${shfmt_bin}" | sha256sum -c
	chmod +x "${shfmt_bin}"
	"${shfmt_bin}" -d scripts/*.sh
	rm -f "${shfmt_bin}"
fi
if command -v ruff >/dev/null 2>&1; then
	ruff check scripts/gradle-to-cyclonedx.py scripts/fail-on-sarif-severity.py \
		scripts/validate-yaml.py scripts/lint-doc-links.py scripts/tests
else
	uvx ruff check scripts/gradle-to-cyclonedx.py scripts/fail-on-sarif-severity.py \
		scripts/validate-yaml.py scripts/lint-doc-links.py scripts/tests
fi
if command -v zizmor >/dev/null 2>&1; then
	zizmor --min-severity=low .github/workflows
else
	queued="${queued} zizmor"
fi
if [[ -n "${queued}" ]]; then
	# shellcheck disable=SC2086
	ADO_DOCKER_STEPS="${queued# }" sh scripts/check-ci-docker.sh
fi
