# AeSH — The RYZ Adaptive Shell

AeSH is an interactive shell written in **RYZ**, a custom systems programming language. It serves as the command interface for the RYZ runtime and as a proving ground for shell/userland behavior in the experimental ryzOS direction.

The main RYZ language/toolchain repository is currently private. This public repo exists to showcase one of the language's most important artifacts: a shell written in the language itself.

## Why this matters

A custom programming language becomes much more credible when real system software is written in it. AeSH demonstrates that RYZ can support command dispatch, scripting, history, external command passthrough, and non-interactive shell execution.

## Features

- Builtin commands: `cd`, `pwd`, `exit`, `help`, `status`, `history`, `run`, `compose`
- Inline RYZ script execution (lines prefixed with `ryz:` or `:`)
- External command passthrough via `fmt.shell`
- Persistent history at `~/.aesh_history`
- `-c <cmd>` non-interactive mode for scripting

## Quick Start

Requires: Python 3, GCC, and access to the private RYZ toolchain.

```bash
# From a machine that has the private RYZ repo checked out:
python3 /path/to/ryz/bin/ryznative.py aesh.ryz -o aesh

# Run interactively
./aesh

# Run a single command
./aesh -c "help"
```

This public repository intentionally does **not** ship the RYZ compiler, interpreter, or native backend. It only showcases AeSH source and documentation.

## Portfolio framing

> AeSH is a shell written in RYZ, a custom systems programming language. It validates the RYZ runtime/toolchain against real shell behavior: builtins, script mode, command dispatch, history, and external process execution.

## Status

Experimental. This repository is suitable as a public-facing companion to the private RYZ language/toolchain repo, but production-shell claims should be avoided unless backed by current tests and demos.

## License

GPL-3.0-or-later
