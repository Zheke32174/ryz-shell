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

echo "aesh public smoke: ok"
