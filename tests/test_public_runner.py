from __future__ import annotations

import os
import pathlib
import re
import subprocess
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
RUNNER = ROOT / "tools" / "ryzc"
SOURCE = ROOT / "aesh.ryz"


def invoke(*args: str, history: pathlib.Path | None = None) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    if history is not None:
        env["AESH_HISTORY"] = str(history)
    return subprocess.run(
        [sys.executable, str(RUNNER), str(SOURCE), *args],
        cwd=ROOT,
        env=env,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


class PublicRunnerTests(unittest.TestCase):
    def test_versions_agree(self) -> None:
        expected = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
        runner = RUNNER.read_text(encoding="utf-8")
        source = SOURCE.read_text(encoding="utf-8")
        self.assertIn(f'VERSION = "{expected}"', runner)
        self.assertRegex(source, rf'let VERSION\s*=\s*"{re.escape(expected)}"')

    def test_help_and_status(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            history = pathlib.Path(temp) / "history"
            help_result = invoke("-c", "help", history=history)
            self.assertEqual(help_result.returncode, 0, help_result.stderr)
            self.assertIn("builtin commands", help_result.stdout)
            status_result = invoke("-c", "status", history=history)
            self.assertEqual(status_result.returncode, 0, status_result.stderr)
            self.assertIn("public compatibility runner", status_result.stdout)

    def test_inline_evaluation_is_bounded(self) -> None:
        result = subprocess.run(
            [sys.executable, str(RUNNER), "-e", 'fmt.println("answer", 6*7)'],
            cwd=ROOT,
            check=False,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "answer 42")
        rejected = subprocess.run(
            [sys.executable, str(RUNNER), "-e", '__import__("os").system("true")'],
            cwd=ROOT,
            check=False,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        self.assertNotEqual(rejected.returncode, 0)

    def test_external_command_status_is_preserved(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            result = invoke("-c", "false", history=pathlib.Path(temp) / "history")
            self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
