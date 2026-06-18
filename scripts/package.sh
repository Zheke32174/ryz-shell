#!/usr/bin/env sh
set -eu

VERSION="${VERSION:-0.1.0}"
ARCH="${ARCH:-all}"
NAME="aesh"
DIST_DIR="dist"
BUILD_DIR="build"
PKG="${NAME}-${VERSION}"
TARBALL="${DIST_DIR}/${NAME}-${VERSION}-linux-${ARCH}.tar.gz"
DEB="${DIST_DIR}/${NAME}_${VERSION}_${ARCH}.deb"

cd "$(dirname "$0")/.."

sh scripts/smoke.sh

rm -rf "$BUILD_DIR/$PKG"
mkdir -p "$BUILD_DIR/$PKG/bin" "$BUILD_DIR/$PKG/tools" "$BUILD_DIR/$PKG/share/doc/aesh" "$DIST_DIR"

cp bin/aesh "$BUILD_DIR/$PKG/bin/aesh"
cp tools/ryzc "$BUILD_DIR/$PKG/tools/ryzc"
cp aesh.ryz "$BUILD_DIR/$PKG/aesh.ryz"
cp README.md INSTALL.md "$BUILD_DIR/$PKG/share/doc/aesh/"
chmod +x "$BUILD_DIR/$PKG/bin/aesh" "$BUILD_DIR/$PKG/tools/ryzc"

tar -C "$BUILD_DIR" -czf "$TARBALL" "$PKG"
sha256sum "$TARBALL" > "$TARBALL.sha256"
echo "Built $TARBALL"

if command -v dpkg-deb >/dev/null 2>&1; then
  DEB_ROOT="$BUILD_DIR/deb/${NAME}_${VERSION}_${ARCH}"
  rm -rf "$DEB_ROOT"
  mkdir -p "$DEB_ROOT/usr/bin" "$DEB_ROOT/usr/share/aesh/tools" "$DEB_ROOT/usr/share/doc/aesh" "$DEB_ROOT/DEBIAN"

  cp tools/ryzc "$DEB_ROOT/usr/share/aesh/tools/ryzc"
  cp aesh.ryz "$DEB_ROOT/usr/share/aesh/aesh.ryz"
  cp README.md INSTALL.md "$DEB_ROOT/usr/share/doc/aesh/"
  chmod +x "$DEB_ROOT/usr/share/aesh/tools/ryzc"

  cat > "$DEB_ROOT/usr/bin/aesh" <<'LAUNCHER'
#!/usr/bin/env sh
exec python3 /usr/share/aesh/tools/ryzc /usr/share/aesh/aesh.ryz "$@"
LAUNCHER
  chmod +x "$DEB_ROOT/usr/bin/aesh"

  cat > "$DEB_ROOT/DEBIAN/control" <<EOF
Package: aesh
Version: ${VERSION}
Section: shells
Priority: optional
Architecture: ${ARCH}
Depends: python3
Maintainer: Anthony Ford <zheke32174@gmail.com>
Description: AeSH, the RYZ Adaptive Shell
 AeSH is a shell written in RYZ and shipped with a public compatibility runner.
EOF

  dpkg-deb --build "$DEB_ROOT" "$DEB"
  sha256sum "$DEB" > "$DEB.sha256"
  echo "Built $DEB"
else
  echo "dpkg-deb not found; skipped .deb package"
fi
