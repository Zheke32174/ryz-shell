# Installing AeSH

AeSH ships as a RYZ source artifact plus a constrained public compatibility runner. Review the source or a versioned release before installing it.

## Run from a checkout

```bash
git clone https://github.com/Zheke32174/ryz-shell.git
cd ryz-shell
make check
sh bin/aesh -c help
```

## Local user installation

From the reviewed checkout:

```bash
sh scripts/install.sh
```

Defaults:

```text
application: ~/.local/share/aesh
launcher:    ~/.local/bin/aesh
```

Custom locations:

```bash
APP_DIR="$HOME/apps/aesh" BIN_DIR="$HOME/bin" sh scripts/install.sh
```

The installer:

1. runs the repository smoke test;
2. stages source and runner files separately;
3. swaps the installation atomically;
4. tests the installed launcher;
5. restores the previous installation if verification fails.

It does not curl executable text, clone an unreviewed moving branch, or edit shell startup files.

## Package installation

Build from source:

```bash
make package
sha256sum -c dist/*.sha256
sudo dpkg -i "dist/aesh_$(cat VERSION)_all.deb"
```

For a GitHub Release, verify that the tag matches the version and validate the accompanying checksum before installation.

## Public runner scope

The packaged `tools/ryzc` is an AeSH compatibility runner, not the full RYZ compiler. It supports the documented shell demonstration path, command status, history, external command passthrough, and bounded inline examples.

## Native binary build

Use the canonical reviewed RYZ frontend:

```bash
python3 /path/to/ryz/bin/ryz build aesh.ryz -o build/aesh --mode safe
./build/aesh -c help
```

Record the RYZ commit, AeSH commit, compiler mode, test output, and artifact hash before distributing a native build.
