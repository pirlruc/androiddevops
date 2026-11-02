"""Tests for the Gradle dependency parser."""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

import pytest


def _load():
    """Load the hyphenated script as a module."""
    path = Path(__file__).resolve().parents[1] / "gradle-to-cyclonedx.py"
    spec = importlib.util.spec_from_file_location("gradle_to_cyclonedx", path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


parse_dependencies = _load().parse_dependencies
main = _load().main


def test_parses_arrow_resolution_and_strictly() -> None:
    """A resolved arrow and a strictly constraint both yield a version."""
    text = """
    releaseRuntimeClasspath
    +--- com.example:one:1.0.0 -> 1.2.3
    +--- com.example:two:{strictly 4.5.6}
    +--- project :data
    \\--- com.example:three:7.0.0 (*)
    """
    assert parse_dependencies(text) == [
        ("com.example", "one", "1.2.3"),
        ("com.example", "three", "7.0.0"),
        ("com.example", "two", "4.5.6"),
    ]


def test_empty_configuration_is_an_error(tmp_path: Path) -> None:
    """A report with no Maven coordinates fails closed."""
    apk = tmp_path / "app.apk"
    deps = tmp_path / "deps.txt"
    out = tmp_path / "out.json"
    apk.write_bytes(b"apk")
    deps.write_text("releaseRuntimeClasspath - Resolved\n", encoding="utf-8")
    assert main_with(apk, deps, out) == 1
    assert not out.exists()


def test_writes_a_bill(tmp_path: Path) -> None:
    """A parsed classpath becomes a CycloneDX component."""
    apk = tmp_path / "app.apk"
    deps = tmp_path / "deps.txt"
    out = tmp_path / "out.json"
    apk.write_bytes(b"apk-bytes")
    deps.write_text("+--- com.example:lib:1.0.0\n", encoding="utf-8")
    assert main_with(apk, deps, out) == 0
    bill = json.loads(out.read_text(encoding="utf-8"))
    assert bill["components"][0]["purl"] == "pkg:maven/com.example/lib@1.0.0"
    assert bill["metadata"]["component"]["hashes"][0]["alg"] == "SHA-256"


def main_with(apk: Path, deps: Path, out: Path) -> int:
    """Run main against three paths."""
    return main_argv(apk, deps, out)


def main_argv(apk: Path, deps: Path, out: Path) -> int:
    """Invoke main with a replaced argv."""
    old = sys.argv
    sys.argv = ["gradle-to-cyclonedx.py", str(apk), str(deps), str(out)]
    try:
        return main()
    finally:
        sys.argv = old


def test_usage_error(capsys: pytest.CaptureFixture[str]) -> None:
    """The wrong number of arguments returns 2."""
    old = sys.argv
    sys.argv = ["gradle-to-cyclonedx.py"]
    try:
        assert main() == 2
    finally:
        sys.argv = old
    assert "usage:" in capsys.readouterr().err
