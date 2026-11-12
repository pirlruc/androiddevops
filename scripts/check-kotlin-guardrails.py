#!/usr/bin/env python3
"""Kotlin build gates used by Android callers (KT-BUILD-003, KT-BUILD-004)."""

from __future__ import annotations

import pathlib
import sys

ROOT = pathlib.Path(".").resolve()


def main() -> int:
    """Return 0 when wrapper checksum and warning policy are present."""
    errors: list[str] = []
    wrapper = ROOT / "gradle" / "wrapper" / "gradle-wrapper.properties"
    if not wrapper.is_file() or "distributionSha256Sum=" not in wrapper.read_text(encoding="utf-8"):
        errors.append("KT-BUILD-003: gradle-wrapper.properties needs distributionSha256Sum")
    for path in ROOT.glob("*/build.gradle.kts"):
        text = path.read_text(encoding="utf-8")
        if "compilerOptions" not in text and "kotlin {" not in text:
            continue
        if "allWarningsAsErrors" not in text:
            errors.append(f"KT-BUILD-004: {path} does not set allWarningsAsErrors")
    if errors:
        for item in errors:
            print(item, file=sys.stderr)
        return 1
    print("kotlin guardrails ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
