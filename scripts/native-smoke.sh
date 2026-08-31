#!/usr/bin/env bash
# native-smoke.sh — verify the ryzcc-compiled AeSH.
#
# scripts/smoke.sh does NOT test this file's logic. The public runner reimplements
# AeSH's dispatch in Python and, given aesh.ryz, only checks that the path exists
# (`--check` is a file-existence test, not a parse). So CI green says nothing about
# aesh.ryz. This script is the gate that actually executes it.
#
# Not runnable in this repo's CI: it needs ryzcc from the ryz-lab toolchain, which
# is not a dependency here. Run it by hand after building:
#   ryzcc aesh.ryz /tmp/aesh-native.elf && bash scripts/native-smoke.sh
#
# Same seven checks as the run-aesh driver, against the ELF instead of the runner.
set -uo pipefail
cd "$(dirname "$0")/.."          # RYZC in aesh.ryz is the relative ./tools/ryzc
AESH=${AESH:-/tmp/aesh-native.elf}
pass=0; fail=0
ck(){ if [ "$2" = "$3" ]; then echo "  ok  $1"; pass=$((pass+1)); else echo "FAIL $1 (got [$3] want [$2])"; fail=$((fail+1)); fi; }

ck "echo"      "aesh-ok"          "$($AESH -c 'echo aesh-ok')"
ck "pipe"      "HI"               "$($AESH -c 'echo hi | tr a-z A-Z')"
ck "&&"        "yes"              "$($AESH -c 'true && echo yes')"
ck "|| short"  ""                 "$($AESH -c 'true || echo no')"
ck "ryz-eval"  "ryz-in-aesh 42"   "$($AESH -c ': fmt.println("ryz-in-aesh", 6 * 7)')"
$AESH -c 'false' >/dev/null 2>&1; ck "false exit" "1" "$?"

cat > /tmp/_aesh_tty_n.sh <<EOF
#!/usr/bin/env bash
cd "$(pwd)"
$AESH -c '[ -t 1 ] && echo AESH_HAS_TTY || echo AESH_NO_TTY'
EOF
chmod +x /tmp/_aesh_tty_n.sh
got="$(script -qec /tmp/_aesh_tty_n.sh /dev/null 2>/dev/null | tr -d '\r' | grep -o 'AESH_[A-Z_]*' | head -1)"
ck "tty passthrough" "AESH_HAS_TTY" "$got"
rm -f /tmp/_aesh_tty_n.sh
echo; echo "native aesh verification: $pass passed, $fail failed"
exit $fail
