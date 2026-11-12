#!/usr/bin/env python3
"""Fail when a CycloneDX component uses a denied SPDX license (SC-LIC-001)."""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path


def excluded() -> set[str]:
    """Return package names skipped via LICENSE_GATE_EXCLUDE."""
    raw = os.environ.get("LICENSE_GATE_EXCLUDE", "")
    return {part.strip() for part in raw.split(",") if part.strip()}


def deny_list() -> list[str]:
    """Return lowercase deny substrings from LICENSE_DENY_LIST."""
    raw = os.environ.get(
        "LICENSE_DENY_LIST",
        '["AGPL-3.0","SSPL-1.0","BUSL-1.1","Commons-Clause","CC-BY-NC"]',
    )
    parsed = json.loads(raw)
    if not isinstance(parsed, list):
        raise TypeError("LICENSE_DENY_LIST must be a JSON array")
    return [item.lower().strip() for item in parsed if isinstance(item, str) and item.strip()]


def license_ids(component: dict) -> list[str]:
    """Return SPDX ids and names declared on one component."""
    found: list[str] = []
    for entry in component.get("licenses") or []:
        node = entry.get("license") or entry.get("expression") or {}
        if isinstance(node, str):
            found.append(node)
            continue
        if isinstance(node, dict):
            found.append(str(node.get("id") or node.get("name") or ""))
    return [item for item in found if item]


def main() -> int:
    """Return 0 when no non-excluded component matches the deny list."""
    if len(sys.argv) != 2:
        print("usage: check-cyclonedx-licenses.py <bom.json>", file=sys.stderr)
        return 2
    document = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    denied = deny_list()
    skip = excluded()
    hits: list[str] = []
    for component in document.get("components") or []:
        if not isinstance(component, dict):
            continue
        name = str(component.get("name") or component.get("bom-ref") or "unknown")
        if name in skip:
            continue
        for license_id in license_ids(component):
            lowered = license_id.lower()
            matched = [item for item in denied if item in lowered]
            if matched:
                hits.append(f"{name}: {license_id}")
    if hits:
        print("denied licenses:", file=sys.stderr)
        for hit in hits:
            print(f"  {hit}", file=sys.stderr)
        return 1
    print("no denied licenses")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
