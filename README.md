# AeSH — The RYZ Adaptive Shell

AeSH is an interactive shell written in **RYZ**, a custom systems programming language. It serves as the command interface for the RYZ runtime and as a proving ground for shell/userland behavior in the experimental ryzOS direction.

The main RYZ language/toolchain repository is currently private. This public repo showcases one of the language's most important artifacts: a shell written in the language itself.

## Quick start

Clone and run AeSH with the bundled public compatibility runner:

```bash
git clone https://github.com/Zheke32174/ryz-shell.git
cd ryz-shell
python3 tools/ryzc --check aesh.ryz
python3 tools/ryzc aesh.ryz -c "help"
python3 tools/ryzc aesh.ryz -c "pwd"
python3 tools/ryzc aesh.ryz -c "echo hi"
```

Or use the launcher:

```bash
sh bin/aesh -c "help"
sh bin/aesh
```

Run the public smoke test:

```bash
sh scripts/smoke.sh
```

## Install

The installer clones this repo and installs an `aesh` launcher that runs `aesh.ryz` through the bundled public runner:

```bash
curl -fsSL https://raw.githubusercontent.com/Zheke32174/ryz-shell/master/scripts/install.sh | sh
```

## Why this matters

A custom programming language becomes much more credible when real system software is written in it. AeSH demonstrates that RYZ can support command dispatch, scripting, history, external command passthrough, and non-interactive shell execution.

## Features

- Builtin commands: `cd`, `pwd`, `exit`, `help`, `status`, `history`, `run`
- Inline RYZ demo expression execution with `ryz:` or `:`
- External command passthrough through the host shell
- Persistent history at `~/.aesh_history`
- `-c <cmd>` non-interactive mode for scripting

## Public runner versus private toolchain

This repo includes `tools/ryzc`, a small public compatibility runner that makes AeSH clone-and-run without exposing the private RYZ native backend.

The private RYZ repo still contains the full language/toolchain work, including the native backend. This public repo intentionally does **not** ship `ryznative.py`.

## Build a native binary

Native compilation still requires the private RYZ toolchain:

```bash
python3 /path/to/ryz/bin/ryznative.py aesh.ryz -o aesh
./aesh -c "help"
```

## Portfolio framing

> AeSH is a shell written in RYZ, a custom systems programming language. It validates the RYZ runtime/toolchain against real shell behavior: builtins, script mode, command dispatch, history, and external process execution.

## Status

Experimental but publicly runnable through the bundled compatibility runner. Native compiled releases can be added later as GitHub Release assets.

## License

GPL-3.0-or-later
