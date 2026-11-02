"""Tests for the SARIF severity gate."""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

import pytest


def _load():
    """Load the hyphenated script as a module."""
    path = Path(__file__).resolve().parents[1] / "fail-on-sarif-severity.py"
    spec = importlib.util.spec_from_file_location("fail_on_sarif_severity", path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


main = _load().main


def _sarif(level: str, score: str | None = None) -> dict:
    """Build a one-result SARIF document."""
    result: dict = {
        "ruleId": "TEST",
        "level": level,
        "message": {"text": "example"},
        "locations": [
            {
                "physicalLocation": {
                    "artifactLocation": {"uri": "App.kt"},
                    "region": {"startLine": 4},
                }
            }
        ],
    }
    if score is not None:
        result["properties"] = {"security-severity": score}
    return {"runs": [{"results": [result], "tool": {"driver": {"rules": []}}}]}


def _run(tmp_path: Path, document: dict, *extra: str) -> int:
    """Write SARIF and invoke main."""
    path = tmp_path / "out.sarif"
    path.write_text(json.dumps(document), encoding="utf-8")
    old = sys.argv
    sys.argv = ["fail-on-sarif-severity.py", str(path), *extra]
    try:
        return main()
    finally:
        sys.argv = old


def test_high_blocks_by_default(tmp_path: Path) -> None:
    """A high result fails the default gate."""
    assert _run(tmp_path, _sarif("warning", "8.1")) == 1


def test_medium_does_not_block_the_default(tmp_path: Path) -> None:
    """A medium result is printed and does not fail the default gate."""
    assert _run(tmp_path, _sarif("warning", "5.0")) == 0


def test_medium_blocks_when_asked(tmp_path: Path) -> None:
    """--min-severity medium fails a medium result."""
    assert _run(tmp_path, _sarif("warning", "5.0"), "--min-severity", "medium") == 1


def test_missing_file_exits_2(tmp_path: Path) -> None:
    """A missing path fails closed."""
    old = sys.argv
    sys.argv = ["fail-on-sarif-severity.py", str(tmp_path / "nope.sarif")]
    try:
        with pytest.raises(SystemExit) as raised:
            main()
        assert raised.value.code == 2
    finally:
        sys.argv = old
