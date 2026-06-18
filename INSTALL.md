# Installing AeSH

AeSH is public as a shell artifact. The full RYZ language/toolchain repository remains private, but this repo now includes a small public compatibility runner so AeSH can be cloned and used immediately.

## Clone and run

```bash
git clone https://github.com/Zheke32174/ryz-shell.git
cd ryz-shell
python3 tools/ryzc --check aesh.ryz
python3 tools/ryzc aesh.ryz -c "help"
python3 tools/ryzc aesh.ryz -c "pwd"
python3 tools/ryzc aesh.ryz -c "echo hi"
```

Launcher form:

```bash
sh bin/aesh -c "help"
sh bin/aesh
```

Smoke test:

```bash
sh scripts/smoke.sh
```

## Install command

```bash
curl -fsSL https://raw.githubusercontent.com/Zheke32174/ryz-shell/master/scripts/install.sh | sh
```

The installer clones the repo into a local application directory and installs an `aesh` launcher into a bin directory.

Default install locations:

```text
~/.local/share/aesh
~/.local/bin/aesh
```

Custom locations:

```bash
APP_DIR="$HOME/apps/aesh" BIN_DIR="$HOME/bin" sh scripts/install.sh
```

## Public runner scope

`tools/ryzc` is a public AeSH compatibility runner. It supports:

- `python3 tools/ryzc --check aesh.ryz`
- `python3 tools/ryzc aesh.ryz -c "help"`
- `python3 tools/ryzc aesh.ryz -c "pwd"`
- external command passthrough, such as `echo hi`
- interactive AeSH REPL
- limited inline demo eval, such as `: fmt.println("x", 6*7)`

It is intentionally not the full private RYZ native backend.

## Native binary build

Building a native binary still requires the private RYZ toolchain:

```bash
python3 /path/to/ryz/bin/ryznative.py aesh.ryz -o aesh
./aesh -c "help"
```

## Future release binaries

Native compiled release assets can be added later, for example:

```text
aesh-linux-x86_64
aesh-linux-aarch64
aesh-android-aarch64
```
