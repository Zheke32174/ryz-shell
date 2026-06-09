# AeSH — The RYZ Adaptive Shell

AeSH is a shell written in the [RYZ programming language](https://github.com/Zheke32174/ryz).
It serves as the interactive interface to the RYZ runtime and a fully audited command dispatcher.

## Features

- Builtin commands: `cd`, `pwd`, `exit`, `help`, `status`, `history`, `run`, `compose`
- Inline RYZ script execution (lines prefixed with `ryz:` or `:`)
- External command passthrough via `fmt.shell`
- Persistent history at `~/.aesh_history`
- `-c <cmd>` non-interactive mode for scripting

## Quick Start

Requires: Python 3, gcc

```bash
# Compile aesh to native ELF
python3 ryznative.py aesh.ryz -o aesh

# Run interactively
./aesh

# Run a single command
./aesh -c "help"
```

## License

GPL-3.0-or-later
