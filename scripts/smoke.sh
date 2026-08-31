#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."

python3 tools/ryzc --check aesh.ryz
python3 tools/ryzc aesh.ryz -c "help" >/tmp/aesh-help.txt
grep -q "aesh v" /tmp/aesh-help.txt
python3 tools/ryzc aesh.ryz -c "pwd" >/tmp/aesh-pwd.txt
grep -q "/" /tmp/aesh-pwd.txt
python3 tools/ryzc aesh.ryz -c "echo hi" >/tmp/aesh-echo.txt
grep -q "hi" /tmp/aesh-echo.txt
python3 tools/ryzc -e 'fmt.println("x", 6*7)' >/tmp/aesh-eval.txt
grep -q "x 42" /tmp/aesh-eval.txt

# The RYZ-execution builtins. These route through ryz_exec, the single seam the
# shell uses for language.ryz.execute@v1, and had no coverage before — help/pwd/
# echo exercise dispatch and external commands but never touch it.
python3 tools/ryzc aesh.ryz -c ': fmt.println("inline", 6*7)' >/tmp/aesh-inline.txt
grep -q "inline 42" /tmp/aesh-inline.txt
# Both streams, and the exit status is not the assertion: a shell reporting a
# missing script may legitimately exit non-zero. The message is what is under test.
python3 tools/ryzc aesh.ryz -c "run /tmp/aesh-no-such-file.ryz" >/tmp/aesh-run.txt 2>&1 || true
grep -q "file not found" /tmp/aesh-run.txt

echo "aesh public smoke: ok"
