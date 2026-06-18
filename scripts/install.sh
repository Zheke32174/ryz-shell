#!/usr/bin/env sh
set -eu

OWNER="Zheke32174"
REPO="ryz-shell"
APP_DIR="${APP_DIR:-$HOME/.local/share/aesh}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
NAME="aesh"
REPO_URL="https://github.com/${OWNER}/${REPO}.git"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Need $1 to install AeSH." >&2
    exit 1
  }
}

need python3
need git

mkdir -p "$BIN_DIR"

if [ -d "$APP_DIR/.git" ]; then
  echo "Updating AeSH in $APP_DIR"
  git -C "$APP_DIR" pull --ff-only
else
  echo "Cloning AeSH into $APP_DIR"
  rm -rf "$APP_DIR"
  git clone --depth=1 "$REPO_URL" "$APP_DIR"
fi

cat > "$BIN_DIR/$NAME" <<EOF
#!/usr/bin/env sh
exec python3 "$APP_DIR/tools/ryzc" "$APP_DIR/aesh.ryz" "\$@"
EOF
chmod +x "$BIN_DIR/$NAME"

echo "Installed: $BIN_DIR/$NAME"
"$BIN_DIR/$NAME" -c "help" >/dev/null
echo "AeSH install smoke: ok"
