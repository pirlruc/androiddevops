#!/usr/bin/env bash
# KT-SEC-004: scan a CycloneDX bill with a checksum-pinned grype.
set -euo pipefail

if [[ $# -ne 1 || ! -f $1 ]]; then
	echo "error: pass a CycloneDX JSON file" >&2
	exit 1
fi

VERSION="0.116.1"
SHA256="0122df7b655981abe547ad3d2190d65551dac6a2bfc80b4dc2a989b5d0587458"
WORKDIR="${TMPDIR:-/tmp}/androiddevops-grype-${VERSION}"
mkdir -p "$WORKDIR"
GRYPE="${WORKDIR}/grype"
ARCHIVE="${WORKDIR}/grype.tgz"

if [[ ! -x $GRYPE ]]; then
	curl -fsSL -o "$ARCHIVE" \
		"https://github.com/anchore/grype/releases/download/v${VERSION}/grype_${VERSION}_linux_amd64.tar.gz"
	echo "${SHA256}  ${ARCHIVE}" | sha256sum -c -
	tar -xzf "$ARCHIVE" -C "$WORKDIR" grype
	chmod +x "$GRYPE"
fi

"$GRYPE" sbom:"$1" --fail-on high
