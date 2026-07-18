from __future__ import annotations

import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "tools" / "ryzc"
AESH = ROOT / "aesh.ryz"


class PublicRunnerCommandTests(unittest.TestCase):
    def run_aesh(self, command: str, history: Path) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env["AESH_HISTORY"] = str(history)
        return subprocess.run(
            [sys.executable, str(RUNNER), str(AESH), "-c", command],
            cwd=ROOT,
            env=env,
            capture_output=True,
            text=True,
            timeout=20,
        )

    def test_numeric_exit_is_the_process_status(self):
        with tempfile.TemporaryDirectory() as directory:
            result = self.run_aesh("exit 7", Path(directory) / "history")
        self.assertEqual(result.returncode, 7)
        self.assertNotIn("Traceback", result.stderr)

    def test_invalid_exit_status_fails_without_exiting_through_host_shell(self):
        with tempfile.TemporaryDirectory() as directory:
            result = self.run_aesh("exit nope", Path(directory) / "history")
        self.assertEqual(result.returncode, 2)
        self.assertIn("numeric status required", result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_exit_rejects_extra_operands(self):
        with tempfile.TemporaryDirectory() as directory:
            result = self.run_aesh("exit 1 2", Path(directory) / "history")
        self.assertEqual(result.returncode, 2)
        self.assertIn("at most one status code", result.stderr)

    def test_bare_run_is_a_builtin_error(self):
        with tempfile.TemporaryDirectory() as directory:
            result = self.run_aesh("run", Path(directory) / "history")
        self.assertEqual(result.returncode, 2)
        self.assertIn("exactly one script path is required", result.stderr)
        self.assertNotIn("not found", result.stderr.lower())

    def test_malformed_run_quoting_is_reported_without_traceback(self):
        with tempfile.TemporaryDirectory() as directory:
            result = self.run_aesh('run "unterminated', Path(directory) / "history")
        self.assertEqual(result.returncode, 2)
        self.assertIn("No closing quotation", result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_quoted_script_path_with_spaces_runs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            script = root / "hello world.ryz"
            script.write_text('import "std/fmt"\nfmt.println("quoted path ok")\n', encoding="utf-8")
            result = self.run_aesh(f'run "{script}"', root / "history")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("quoted path ok", result.stdout)

    def test_external_command_status_propagates(self):
        with tempfile.TemporaryDirectory() as directory:
            result = self.run_aesh("sh -c 'exit 9'", Path(directory) / "history")
        self.assertEqual(result.returncode, 9)

    def test_invalid_inline_expression_is_bounded(self):
        with tempfile.TemporaryDirectory() as directory:
            result = self.run_aesh(": fmt.println(1/0)", Path(directory) / "history")
        self.assertEqual(result.returncode, 2)
        self.assertIn("invalid inline expression", result.stderr)
        self.assertNotIn("Traceback", result.stderr)


if __name__ == "__main__":
    unittest.main()
