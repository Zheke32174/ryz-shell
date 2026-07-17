PREFIX ?= /usr/local
DESTDIR ?=
VERSION ?= $(shell cat VERSION)
PACKAGE := aesh
ARCH ?= all
DIST_DIR := dist
BUILD_DIR := build
PKG_DIR := $(BUILD_DIR)/$(PACKAGE)-$(VERSION)
DEB_ROOT := $(BUILD_DIR)/deb/$(PACKAGE)_$(VERSION)_$(ARCH)
SOURCE_DATE_EPOCH ?= $(shell git log -1 --format=%ct 2>/dev/null || date +%s)

.PHONY: check smoke install uninstall package tarball deb clean

check:
	python3 -m unittest discover -s tests -p 'test_*.py' -v
	sh scripts/smoke.sh

smoke:
	sh scripts/smoke.sh

install: check
	install -d "$(DESTDIR)$(PREFIX)/bin"
	install -d "$(DESTDIR)$(PREFIX)/share/aesh/tools"
	install -d "$(DESTDIR)$(PREFIX)/share/doc/aesh"
	install -m 0755 tools/ryzc "$(DESTDIR)$(PREFIX)/share/aesh/tools/ryzc"
	install -m 0644 aesh.ryz VERSION "$(DESTDIR)$(PREFIX)/share/aesh/"
	install -m 0644 README.md INSTALL.md PACKAGING.md "$(DESTDIR)$(PREFIX)/share/doc/aesh/"
	printf '%s\n' '#!/usr/bin/env sh' 'exec python3 "$(PREFIX)/share/aesh/tools/ryzc" "$(PREFIX)/share/aesh/aesh.ryz" "$$@"' > "$(DESTDIR)$(PREFIX)/bin/aesh"
	chmod 0755 "$(DESTDIR)$(PREFIX)/bin/aesh"
	@echo "Installed AeSH $(VERSION) into $(DESTDIR)$(PREFIX)"

uninstall:
	rm -f "$(DESTDIR)$(PREFIX)/bin/aesh"
	rm -rf "$(DESTDIR)$(PREFIX)/share/aesh"
	rm -rf "$(DESTDIR)$(PREFIX)/share/doc/aesh"

package: check clean tarball deb

tarball:
	mkdir -p "$(PKG_DIR)/bin" "$(PKG_DIR)/tools" "$(PKG_DIR)/share/doc/aesh" "$(DIST_DIR)"
	cp bin/aesh "$(PKG_DIR)/bin/aesh"
	cp tools/ryzc "$(PKG_DIR)/tools/ryzc"
	cp aesh.ryz VERSION "$(PKG_DIR)/"
	cp README.md INSTALL.md PACKAGING.md "$(PKG_DIR)/share/doc/aesh/"
	chmod 0755 "$(PKG_DIR)/bin/aesh" "$(PKG_DIR)/tools/ryzc"
	find "$(PKG_DIR)" -exec touch -h -d "@$(SOURCE_DATE_EPOCH)" {} +
	tar --sort=name --mtime="@$(SOURCE_DATE_EPOCH)" --owner=0 --group=0 --numeric-owner \
		-C "$(BUILD_DIR)" -czf "$(DIST_DIR)/$(PACKAGE)-$(VERSION)-linux-$(ARCH).tar.gz" "$(PACKAGE)-$(VERSION)"
	sha256sum "$(DIST_DIR)/$(PACKAGE)-$(VERSION)-linux-$(ARCH).tar.gz" > "$(DIST_DIR)/$(PACKAGE)-$(VERSION)-linux-$(ARCH).tar.gz.sha256"

deb:
	mkdir -p "$(DEB_ROOT)/usr/bin" "$(DEB_ROOT)/usr/share/aesh/tools" "$(DEB_ROOT)/usr/share/aesh" "$(DEB_ROOT)/usr/share/doc/aesh" "$(DEB_ROOT)/DEBIAN" "$(DIST_DIR)"
	cp tools/ryzc "$(DEB_ROOT)/usr/share/aesh/tools/ryzc"
	cp aesh.ryz VERSION "$(DEB_ROOT)/usr/share/aesh/"
	cp README.md INSTALL.md PACKAGING.md "$(DEB_ROOT)/usr/share/doc/aesh/"
	chmod 0755 "$(DEB_ROOT)/usr/share/aesh/tools/ryzc"
	printf '%s\n' '#!/usr/bin/env sh' 'exec python3 /usr/share/aesh/tools/ryzc /usr/share/aesh/aesh.ryz "$$@"' > "$(DEB_ROOT)/usr/bin/aesh"
	chmod 0755 "$(DEB_ROOT)/usr/bin/aesh"
	printf '%s\n' \
	  'Package: aesh' \
	  'Version: $(VERSION)' \
	  'Section: shells' \
	  'Priority: optional' \
	  'Architecture: $(ARCH)' \
	  'Depends: python3' \
	  'Maintainer: Anthony Ford <zheke32174@gmail.com>' \
	  'Description: AeSH, the public RYZ shell artifact' \
	  ' AeSH source is written in RYZ and this package uses the constrained public compatibility runner.' \
	  > "$(DEB_ROOT)/DEBIAN/control"
	find "$(DEB_ROOT)" -exec touch -h -d "@$(SOURCE_DATE_EPOCH)" {} +
	dpkg-deb --root-owner-group --build "$(DEB_ROOT)" "$(DIST_DIR)/$(PACKAGE)_$(VERSION)_$(ARCH).deb"
	sha256sum "$(DIST_DIR)/$(PACKAGE)_$(VERSION)_$(ARCH).deb" > "$(DIST_DIR)/$(PACKAGE)_$(VERSION)_$(ARCH).deb.sha256"

clean:
	rm -rf "$(BUILD_DIR)" "$(DIST_DIR)"
