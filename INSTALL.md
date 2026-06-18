# Installing AeSH

AeSH is public as a shell artifact, but the main RYZ language/toolchain repository is private.

That means there are two paths:

1. **Install and use AeSH** from a prebuilt binary release.
2. **Build AeSH from source** only if you have access to the private RYZ toolchain.

## Recommended public install path

Once a release binary is uploaded, public users should install AeSH with:

```bash
curl -fsSL https://raw.githubusercontent.com/Zheke32174/ryz-shell/master/scripts/install.sh | bash
```

The installer expects a GitHub Release asset named for the platform, for example:

```text
aesh-linux-x86_64
aesh-linux-aarch64
```

## Manual install

```bash
curl -L -o aesh https://github.com/Zheke32174/ryz-shell/releases/latest/download/aesh-linux-x86_64
chmod +x aesh
sudo install -m 0755 aesh /usr/local/bin/aesh
aesh -c "help"
```

## Build from source

Building from source requires the private RYZ toolchain:

```bash
python3 /path/to/ryz/bin/ryznative.py aesh.ryz -o aesh
./aesh -c "help"
```

The public repo intentionally does not include:

- RYZ compiler
- RYZ interpreter
- RYZ native backend
- private standard-library implementation
- private language/toolchain tests

## What works without the private toolchain

A prebuilt AeSH binary should support:

- starting the shell
- builtin commands such as `help`, `pwd`, `status`, and `history`
- external command passthrough
- one-shot command mode with `aesh -c "help"`

RYZ script evaluation features require a RYZ interpreter/toolchain path to be available on the user's machine.

## Release checklist

Before publishing an AeSH binary release:

```bash
./aesh -c "help"
./aesh -c "pwd"
./aesh -c "status"
```

Then upload the binary as a GitHub Release asset named:

```text
aesh-linux-x86_64
```

Optional later assets:

```text
aesh-linux-aarch64
aesh-android-aarch64
```
