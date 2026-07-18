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
        timeout=20,
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
            timeout=20,
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
            timeout=20,
        )
        self.assertNotEqual(rejected.returncode, 0)

    def test_numeric_exit_is_the_process_status(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result = invoke("-c", "exit 7", history=pathlib.Path(directory) / "history")
        self.assertEqual(result.returncode, 7)
        self.assertNotIn("Traceback", result.stderr)

    def test_invalid_exit_status_is_bounded(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result = invoke("-c", "exit nope", history=pathlib.Path(directory) / "history")
        self.assertEqual(result.returncode, 2)
        self.assertIn("numeric status required", result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_exit_rejects_extra_operands(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result = invoke("-c", "exit 1 2", history=pathlib.Path(directory) / "history")
        self.assertEqual(result.returncode, 2)
        self.assertIn("at most one status code", result.stderr)

    def test_bare_run_is_a_builtin_error(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result = invoke("-c", "run", history=pathlib.Path(directory) / "history")
        self.assertEqual(result.returncode, 2)
        self.assertIn("exactly one script path is required", result.stderr)
        self.assertNotIn("not found", result.stderr.lower())

    def test_malformed_run_quoting_is_reported_without_traceback(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result = invoke(
                "-c",
                'run "unterminated',
                history=pathlib.Path(directory) / "history",
            )
        self.assertEqual(result.returncode, 2)
        self.assertIn("No closing quotation", result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_quoted_script_path_with_spaces_runs(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            script = root / "hello world.ryz"
            script.write_text(
                'import "std/fmt"\nfmt.println("quoted path ok")\n',
                encoding="utf-8",
            )
            result = invoke(
                "-c",
                f'run "{script}"',
                history=root / "history",
            )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("quoted path ok", result.stdout)

    def test_external_command_status_is_preserved(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result = invoke(
                "-c",
                "sh -c 'exit 9'",
                history=pathlib.Path(directory) / "history",
            )
        self.assertEqual(result.returncode, 9)

    def test_invalid_inline_expression_is_bounded(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result = invoke(
                "-c",
                ": fmt.println(1/0)",
                history=pathlib.Path(directory) / "history",
            )
        self.assertEqual(result.returncode, 2)
        self.assertIn("invalid inline expression", result.stderr)
        self.assertNotIn("Traceback", result.stderr)


if __name__ == "__main__":
    unittest.main()
