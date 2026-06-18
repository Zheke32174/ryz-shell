PREFIX ?= /usr/local
DESTDIR ?=
VERSION ?= 0.1.0
PACKAGE = aesh
ARCH ?= all
DIST_DIR = dist
PKG_DIR = build/$(PACKAGE)-$(VERSION)
DEB_ROOT = build/deb/$(PACKAGE)_$(VERSION)_$(ARCH)

.PHONY: smoke install uninstall package tarball deb clean

smoke:
	sh scripts/smoke.sh

install:
	install -d "$(DESTDIR)$(PREFIX)/bin"
	install -d "$(DESTDIR)$(PREFIX)/share/aesh/tools"
	install -d "$(DESTDIR)$(PREFIX)/share/doc/aesh"
	install -m 0755 bin/aesh "$(DESTDIR)$(PREFIX)/bin/aesh"
	install -m 0755 tools/ryzc "$(DESTDIR)$(PREFIX)/share/aesh/tools/ryzc"
	install -m 0644 aesh.ryz "$(DESTDIR)$(PREFIX)/share/aesh/aesh.ryz"
	install -m 0644 README.md INSTALL.md "$(DESTDIR)$(PREFIX)/share/doc/aesh/"
	@echo "Installed AeSH into $(DESTDIR)$(PREFIX)"

uninstall:
	rm -f "$(DESTDIR)$(PREFIX)/bin/aesh"
	rm -rf "$(DESTDIR)$(PREFIX)/share/aesh"
	rm -rf "$(DESTDIR)$(PREFIX)/share/doc/aesh"
	@echo "Uninstalled AeSH from $(DESTDIR)$(PREFIX)"

package: smoke tarball deb

tarball:
	rm -rf "$(PKG_DIR)"
	mkdir -p "$(PKG_DIR)/bin" "$(PKG_DIR)/tools" "$(PKG_DIR)/share/doc/aesh"
	cp bin/aesh "$(PKG_DIR)/bin/aesh"
	cp tools/ryzc "$(PKG_DIR)/tools/ryzc"
	cp aesh.ryz "$(PKG_DIR)/aesh.ryz"
	cp README.md INSTALL.md "$(PKG_DIR)/share/doc/aesh/"
	chmod +x "$(PKG_DIR)/bin/aesh" "$(PKG_DIR)/tools/ryzc"
	mkdir -p "$(DIST_DIR)"
	tar -C build -czf "$(DIST_DIR)/$(PACKAGE)-$(VERSION)-linux-$(ARCH).tar.gz" "$(PACKAGE)-$(VERSION)"
	sha256sum "$(DIST_DIR)/$(PACKAGE)-$(VERSION)-linux-$(ARCH).tar.gz" > "$(DIST_DIR)/$(PACKAGE)-$(VERSION)-linux-$(ARCH).tar.gz.sha256"

# Pure shell/Python package; default architecture is all.
deb:
	rm -rf "$(DEB_ROOT)"
	mkdir -p "$(DEB_ROOT)/usr/bin" "$(DEB_ROOT)/usr/share/aesh/tools" "$(DEB_ROOT)/usr/share/doc/aesh" "$(DEB_ROOT)/DEBIAN"
	cp tools/ryzc "$(DEB_ROOT)/usr/share/aesh/tools/ryzc"
	cp aesh.ryz "$(DEB_ROOT)/usr/share/aesh/aesh.ryz"
	cp README.md INSTALL.md "$(DEB_ROOT)/usr/share/doc/aesh/"
	chmod +x "$(DEB_ROOT)/usr/share/aesh/tools/ryzc"
	printf '%s\n' '#!/usr/bin/env sh' 'exec python3 /usr/share/aesh/tools/ryzc /usr/share/aesh/aesh.ryz "$$@"' > "$(DEB_ROOT)/usr/bin/aesh"
	chmod +x "$(DEB_ROOT)/usr/bin/aesh"
	printf '%s\n' \
	  'Package: aesh' \
	  'Version: $(VERSION)' \
	  'Section: shells' \
	  'Priority: optional' \
	  'Architecture: $(ARCH)' \
	  'Depends: python3' \
	  'Maintainer: Anthony Ford <zheke32174@gmail.com>' \
	  'Description: AeSH, the RYZ Adaptive Shell' \
	  ' AeSH is a shell written in RYZ and shipped with a public compatibility runner.' \
	  > "$(DEB_ROOT)/DEBIAN/control"
	mkdir -p "$(DIST_DIR)"
	dpkg-deb --build "$(DEB_ROOT)" "$(DIST_DIR)/$(PACKAGE)_$(VERSION)_$(ARCH).deb"
	sha256sum "$(DIST_DIR)/$(PACKAGE)_$(VERSION)_$(ARCH).deb" > "$(DIST_DIR)/$(PACKAGE)_$(VERSION)_$(ARCH).deb.sha256"

clean:
	rm -rf build dist
