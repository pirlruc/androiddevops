#!/usr/bin/env python3
"""Android manifest gates (ANDROID-SEC-002, ANDROID-SDK-001)."""

from __future__ import annotations

import pathlib
import sys

ROOT = pathlib.Path(".").resolve()


def main() -> int:
    """Return 0 when manifests disable backup and cleartext."""
    errors: list[str] = []
    manifests = list(ROOT.glob("**/src/main/AndroidManifest.xml"))
    if not manifests:
        print("no AndroidManifest.xml under src/main", file=sys.stderr)
        return 1
    for path in manifests:
        text = path.read_text(encoding="utf-8")
        if 'android:allowBackup="false"' not in text:
            errors.append(f"ANDROID-SEC-002: {path} does not set allowBackup false")
        if 'android:usesCleartextTraffic="true"' in text:
            errors.append(f"ANDROID-SDK-001: {path} allows cleartext")
    if errors:
        for item in errors:
            print(item, file=sys.stderr)
        return 1
    print("android guardrails ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
