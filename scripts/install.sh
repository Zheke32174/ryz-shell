#!/usr/bin/env sh
set -eu

OWNER="Zheke32174"
REPO="ryz-shell"
VERSION="${AESH_VERSION:-latest}"
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="${BIN_DIR:-$PREFIX/bin}"
NAME="aesh"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
uname_m="$(uname -m 2>/dev/null || echo unknown)"

case "$uname_s" in
  Linux) os="linux" ;;
  Android) os="android" ;;
  *)
    echo "Unsupported OS: $uname_s" >&2
    exit 1
    ;;
esac

case "$uname_m" in
  x86_64|amd64) arch="x86_64" ;;
  aarch64|arm64) arch="aarch64" ;;
  *)
    echo "Unsupported architecture: $uname_m" >&2
    exit 1
    ;;
esac

asset="aesh-${os}-${arch}"
base="https://github.com/${OWNER}/${REPO}/releases"
if [ "$VERSION" = "latest" ]; then
  url="${base}/latest/download/${asset}"
else
  url="${base}/download/${VERSION}/${asset}"
fi

tmp="$(mktemp -t aesh.XXXXXX)"
cleanup() { rm -f "$tmp"; }
trap cleanup EXIT INT TERM

echo "Downloading $asset from $url"
if command -v curl >/dev/null 2>&1; then
  curl -fL "$url" -o "$tmp"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$tmp" "$url"
else
  echo "Need curl or wget to install AeSH." >&2
  exit 1
fi

chmod +x "$tmp"

if [ -w "$BIN_DIR" ]; then
  install -m 0755 "$tmp" "$BIN_DIR/$NAME"
else
  echo "Installing to $BIN_DIR requires sudo/admin rights."
  sudo install -m 0755 "$tmp" "$BIN_DIR/$NAME"
fi

echo "Installed: $BIN_DIR/$NAME"
"$BIN_DIR/$NAME" -c "help" || true
