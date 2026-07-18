#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
APP_DIR=${APP_DIR:-$HOME/.local/share/aesh}
BIN_DIR=${BIN_DIR:-$HOME/.local/bin}
LAUNCHER="$BIN_DIR/aesh"
STAGE="${APP_DIR}.stage.$$"
APP_BACKUP="${APP_DIR}.previous.$$"
LAUNCHER_BACKUP="${LAUNCHER}.previous.$$"
PUBLICATION_STARTED=0
COMMITTED=0

cleanup() {
  status=$?
  trap - EXIT HUP INT TERM
  rm -rf "$STAGE"

  if [ "$PUBLICATION_STARTED" -eq 1 ] && [ "$COMMITTED" -eq 0 ]; then
    rm -rf "$APP_DIR"
    if [ -e "$APP_BACKUP" ] || [ -L "$APP_BACKUP" ]; then
      mv "$APP_BACKUP" "$APP_DIR"
    fi

    rm -rf "$LAUNCHER"
    if [ -e "$LAUNCHER_BACKUP" ] || [ -L "$LAUNCHER_BACKUP" ]; then
      mv "$LAUNCHER_BACKUP" "$LAUNCHER"
    fi

    echo "AeSH installation failed; previous application and launcher restored" >&2
  fi

  exit "$status"
}

trap cleanup EXIT
trap 'exit 130' HUP INT TERM

command -v python3 >/dev/null 2>&1 || { echo "AeSH requires python3" >&2; exit 1; }

cd "$ROOT"
sh scripts/smoke.sh

rm -rf "$STAGE" "$APP_BACKUP" "$LAUNCHER_BACKUP"
mkdir -p "$STAGE/tools" "$(dirname "$APP_DIR")" "$BIN_DIR"
cp tools/ryzc "$STAGE/tools/ryzc"
cp aesh.ryz VERSION "$STAGE/"
chmod 0755 "$STAGE/tools/ryzc"

if [ -e "$APP_DIR" ] || [ -L "$APP_DIR" ]; then
  mv "$APP_DIR" "$APP_BACKUP"
fi
if [ -e "$LAUNCHER" ] || [ -L "$LAUNCHER" ]; then
  mv "$LAUNCHER" "$LAUNCHER_BACKUP"
fi
PUBLICATION_STARTED=1

mv "$STAGE" "$APP_DIR"
cat > "$LAUNCHER" <<EOF
#!/usr/bin/env sh
exec python3 "$APP_DIR/tools/ryzc" "$APP_DIR/aesh.ryz" "\$@"
EOF
chmod 0755 "$LAUNCHER"
"$LAUNCHER" -c help >/dev/null

COMMITTED=1
rm -rf "$APP_BACKUP" "$LAUNCHER_BACKUP"
trap - EXIT HUP INT TERM

echo "Installed AeSH $(cat VERSION) from reviewed checkout: $ROOT"
echo "Launcher: $LAUNCHER"
