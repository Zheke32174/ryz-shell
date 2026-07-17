#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
APP_DIR=${APP_DIR:-$HOME/.local/share/aesh}
BIN_DIR=${BIN_DIR:-$HOME/.local/bin}
STAGE="${APP_DIR}.stage.$$"

command -v python3 >/dev/null 2>&1 || { echo "AeSH requires python3" >&2; exit 1; }

cd "$ROOT"
sh scripts/smoke.sh

rm -rf "$STAGE"
mkdir -p "$STAGE/tools" "$BIN_DIR"
cp tools/ryzc "$STAGE/tools/ryzc"
cp aesh.ryz VERSION "$STAGE/"
chmod 0755 "$STAGE/tools/ryzc"

rm -rf "${APP_DIR}.previous"
if [ -e "$APP_DIR" ]; then
  mv "$APP_DIR" "${APP_DIR}.previous"
fi
mv "$STAGE" "$APP_DIR"

cat > "$BIN_DIR/aesh" <<EOF
#!/usr/bin/env sh
exec python3 "$APP_DIR/tools/ryzc" "$APP_DIR/aesh.ryz" "\$@"
EOF
chmod 0755 "$BIN_DIR/aesh"

if ! "$BIN_DIR/aesh" -c help >/dev/null; then
  rm -rf "$APP_DIR"
  if [ -e "${APP_DIR}.previous" ]; then mv "${APP_DIR}.previous" "$APP_DIR"; fi
  echo "AeSH install smoke failed; previous installation restored" >&2
  exit 1
fi
rm -rf "${APP_DIR}.previous"
echo "Installed AeSH $(cat VERSION) from reviewed checkout: $ROOT"
echo "Launcher: $BIN_DIR/aesh"
