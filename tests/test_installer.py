from __future__ import annotations

import os
import pathlib
import stat
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
INSTALLER = ROOT / "scripts" / "install.sh"


class InstallerTests(unittest.TestCase):
    def run_installer(
        self,
        app_dir: pathlib.Path,
        bin_dir: pathlib.Path,
    ) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env["APP_DIR"] = str(app_dir)
        env["BIN_DIR"] = str(bin_dir)
        return subprocess.run(
            ["sh", str(INSTALLER)],
            cwd=ROOT,
            env=env,
            check=False,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=30,
        )

    def test_replaces_existing_install_and_launcher_atomically(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            app_dir = root / "app"
            bin_dir = root / "bin"
            app_dir.mkdir()
            bin_dir.mkdir()
            (app_dir / "old-marker").write_text("old", encoding="utf-8")
            launcher = bin_dir / "aesh"
            launcher.write_text("#!/bin/sh\necho old\n", encoding="utf-8")
            launcher.chmod(0o755)

            result = self.run_installer(app_dir, bin_dir)

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse((app_dir / "old-marker").exists())
            self.assertTrue((app_dir / "tools" / "ryzc").is_file())
            self.assertTrue((app_dir / "aesh.ryz").is_file())
            self.assertTrue((app_dir / "VERSION").is_file())
            self.assertTrue(launcher.is_file())

            smoke = subprocess.run(
                [str(launcher), "-c", "help"],
                check=False,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=20,
            )
            self.assertEqual(smoke.returncode, 0, smoke.stderr)
            self.assertIn("builtin commands", smoke.stdout)
            self.assertEqual(list(root.glob("*.previous.*")), [])
            self.assertEqual(list(bin_dir.glob("aesh.previous.*")), [])

    def test_restores_existing_install_when_launcher_publication_fails(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            app_dir = root / "app"
            bin_dir = root / "bin"
            app_dir.mkdir()
            bin_dir.mkdir()
            marker = app_dir / "old-marker"
            marker.write_text("preserve-me", encoding="utf-8")

            original_mode = stat.S_IMODE(bin_dir.stat().st_mode)
            bin_dir.chmod(0o500)
            try:
                result = self.run_installer(app_dir, bin_dir)
            finally:
                bin_dir.chmod(original_mode)

            self.assertNotEqual(result.returncode, 0)
            self.assertTrue(marker.is_file())
            self.assertEqual(marker.read_text(encoding="utf-8"), "preserve-me")
            self.assertFalse((app_dir / "tools" / "ryzc").exists())
            self.assertIn("previous application and launcher restored", result.stderr)
            self.assertEqual(list(root.glob("*.stage.*")), [])
            self.assertEqual(list(root.glob("*.previous.*")), [])
            self.assertEqual(list(bin_dir.glob("aesh.previous.*")), [])


if __name__ == "__main__":
    unittest.main()
