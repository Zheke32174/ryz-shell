# AeSH Packaging

AeSH can be shipped as a source-runnable package without exposing the private RYZ native backend.

The public package contains:

```text
bin/aesh
resources/aesh.ryz via /usr/share/aesh/aesh.ryz or package root
tools/ryzc public compatibility runner
README.md
INSTALL.md
```

It does **not** contain:

```text
ryznative.py
private RYZ compiler/native backend
private RYZ test corpus
private RYZ standard-library implementation beyond the public runner behavior
```

## Build packages

```bash
sh scripts/package.sh
```

or:

```bash
make package
```

Outputs:

```text
dist/aesh-0.1.0-linux-all.tar.gz
dist/aesh-0.1.0-linux-all.tar.gz.sha256
dist/aesh_0.1.0_all.deb
dist/aesh_0.1.0_all.deb.sha256
```

The `.deb` is architecture `all` because this public package is shell/Python based. It depends on `python3`.

## Install tarball

```bash
tar -xzf dist/aesh-0.1.0-linux-all.tar.gz -C /tmp
cd /tmp/aesh-0.1.0
sh bin/aesh -c "help"
```

## Install `.deb`

```bash
sudo dpkg -i dist/aesh_0.1.0_all.deb
aesh -c "help"
```

## Make a GitHub release

After `sh scripts/package.sh`, upload these assets to a release:

```text
dist/aesh-0.1.0-linux-all.tar.gz
dist/aesh-0.1.0-linux-all.tar.gz.sha256
dist/aesh_0.1.0_all.deb
dist/aesh_0.1.0_all.deb.sha256
```

Suggested tag:

```text
v0.1.0
```

## Native binary later

A native binary release is still possible later using the private RYZ native backend:

```bash
python3 /path/to/ryz/bin/ryznative.py aesh.ryz -o dist/aesh-linux-x86_64
```

That native binary can be uploaded as an additional release asset without publishing `ryznative.py`.
