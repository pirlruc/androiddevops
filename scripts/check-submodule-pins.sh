#!/bin/sh
# SC-DEP-004: gitlink SHA must equal the peeled annotated tag named here.
set -eu

ROOT="$(git rev-parse --show-toplevel)"
cd "${ROOT}"

GR_TAG="1.17.0"
GR_EXPECT="9a17ebb269a5ab02899570dd3e40fb72e50ad762"
SC_TAG="1.14.0"
SC_EXPECT="da8942edf17a0d2736d297c90338fd78b7ec31fb"

gr="$(git rev-parse 'HEAD:docs/guardrails')"
sc="$(git rev-parse 'HEAD:.github/scaffold')"

status=0
if [ "${gr}" != "${GR_EXPECT}" ]; then
	echo "SC-DEP-004: docs/guardrails gitlink ${gr} != ${GR_TAG} ${GR_EXPECT}" >&2
	status=1
fi
if [ "${sc}" != "${SC_EXPECT}" ]; then
	echo "SC-DEP-004: .github/scaffold gitlink ${sc} != ${SC_TAG} ${SC_EXPECT}" >&2
	status=1
fi
if [ "${status}" -ne 0 ]; then
	exit 1
fi

echo "SC-DEP-004: docs/guardrails @ ${GR_TAG} (${GR_EXPECT})"
echo "SC-DEP-004: .github/scaffold @ ${SC_TAG} (${SC_EXPECT})"
