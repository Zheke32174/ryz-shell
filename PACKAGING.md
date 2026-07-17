# AeSH Packaging

The public package contains the RYZ shell source, the constrained compatibility runner, launchers, documentation, and the version file. It does not contain the canonical native RYZ backend.

## Build

```bash
make package
```

The version is read from `VERSION`. Set `SOURCE_DATE_EPOCH` to reproduce archive timestamps explicitly; otherwise the latest Git commit timestamp is used.

Outputs:

```text
dist/aesh-<version>-linux-all.tar.gz
dist/aesh-<version>-linux-all.tar.gz.sha256
dist/aesh_<version>_all.deb
dist/aesh_<version>_all.deb.sha256
```

Verify:

```bash
sha256sum -c dist/*.sha256
```

The package is architecture `all` because the public runtime is Python-based.

## Candidate versus release

Pull requests and branch pushes build candidate packages as CI artifacts. They are not releases.

A release occurs only when a pushed tag exactly equals `v$(cat VERSION)`. The release workflow reruns tests, rebuilds packages, verifies checksums, and creates an immutable GitHub Release. GHCR publication uses the same tag-only rule.

## Tarball

```bash
VERSION=$(cat VERSION)
tar -xzf "dist/aesh-${VERSION}-linux-all.tar.gz" -C /tmp
sh "/tmp/aesh-${VERSION}/bin/aesh" -c help
```

## Debian package

```bash
sudo dpkg -i "dist/aesh_$(cat VERSION)_all.deb"
aesh -c help
```

## Native artifact

A native artifact requires the canonical RYZ toolchain:

```bash
python3 /path/to/ryz/bin/ryz build aesh.ryz -o dist/aesh-linux-x86_64 --mode safe
```

Do not mix that binary into the architecture-independent compatibility package. Publish it as a separately named artifact with toolchain commit, source commit, build mode, tests, and checksum recorded.
