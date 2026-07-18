# AeSH

AeSH is the public shell artifact for the RYZ language ecosystem.

The shell source in [`aesh.ryz`](aesh.ryz) is written in RYZ. This repository also includes a deliberately constrained Python compatibility runner so the public artifact can be inspected and exercised without the private/full RYZ native backend.

That distinction matters:

- the **source artifact** demonstrates shell structure and command dispatch in RYZ;
- the **public compatibility package** executes a supported demonstration subset through `tools/ryzc`;
- a **native AeSH binary** must be built with the canonical RYZ toolchain and tested separately.

**Version:** [`VERSION`](VERSION)  
**MODOS component:** [`MODOS_COMPONENT.yaml`](MODOS_COMPONENT.yaml)  
**License:** GPL-3.0-or-later

## Run from a reviewed checkout

```bash
git clone https://github.com/Zheke32174/ryz-shell.git
cd ryz-shell
make check
sh bin/aesh -c help
sh bin/aesh -c pwd
```

The compatibility runner supports the public shell path, builtins, history, external command passthrough, non-interactive `-c`, and a small bounded inline-expression demonstration. It is not presented as the full RYZ parser or native compiler.

## Install locally

Review the checkout, then run:

```bash
sh scripts/install.sh
```

This installs atomically under:

```text
~/.local/share/aesh
~/.local/bin/aesh
```

The installer does not download or update source. It installs exactly the checkout being reviewed, runs a smoke test first, and restores the previous local installation if the post-install check fails.

## Build packages

```bash
make package
```

Outputs are written under `dist/`:

```text
aesh-<version>-linux-all.tar.gz
aesh-<version>-linux-all.tar.gz.sha256
aesh_<version>_all.deb
aesh_<version>_all.deb.sha256
```

Packaging reads one version from `VERSION`, normalizes archive ownership and timestamps, and verifies the public runner before creating artifacts.

Candidate packages are built in CI for review. GitHub Releases and GHCR images are published only from a matching `v<version>` tag; an ordinary branch push cannot silently replace a release.

See [PACKAGING.md](PACKAGING.md) for package details.

## Supported public behavior

The compatibility runtime currently demonstrates:

- `help`, `status`, `pwd`, `cd`, `history`, `run`, and `exit`;
- `-c <command>` non-interactive execution;
- persistent history, configurable through `AESH_HISTORY`;
- external command execution using the invoking user's ordinary shell authority;
- bounded inline examples such as `fmt.println("answer", 6*7)`.

It deliberately does not claim:

- complete RYZ language compatibility;
- native compilation;
- process isolation;
- elevated privileges;
- policy-broker authority;
- production shell completeness;
- POSIX conformance certification.

## Security and authority boundary

AeSH is a shell. External commands supplied by the user are intentionally executed with the user's existing operating-system permissions. The compatibility runner does not sandbox those commands and must not be used as an authority broker.

Local shell passthrough deliberately uses only the ordinary authority of the user running AeSH. It is not a MODOS domain-capability path. Consequential domain actions must be composed as typed requests and authorized separately by the PDK capability broker.

Inline demo evaluation is restricted to a small AST allowlist and supported `fmt.print` / `fmt.println` forms. It does not expose Python imports, attribute access, calls, or arbitrary evaluation.

History files may contain sensitive command text. Set `AESH_HISTORY` to a protected path or disable persistence in a future deployment wrapper where necessary.

## Relationship to RYZ and MODOS

The canonical language repository owns:

- the language grammar and standard library;
- the bootstrap interpreter/checker;
- the RYZ-to-C native emitter;
- cross-backend regression tests.

This repository owns:

- the public AeSH source artifact;
- the compatibility runner;
- public packaging and release mechanics;
- shell-specific smoke and behavior tests;
- the local command-surface contract for future typed MODOS requests.

Changes to language semantics should be made and tested in RYZ first, then deliberately synchronized here. This repository must not quietly grow into a divergent compiler fork. Likewise, local shell execution must not be mistaken for fresh distributed authority merely because AeSH later gains typed MODOS request composition.

## Native build

With access to a reviewed canonical RYZ checkout:

```bash
python3 /path/to/ryz/bin/ryz build aesh.ryz -o build/aesh --mode safe
./build/aesh -c help
```

A native artifact should not be published until the source commit, toolchain commit, compiler mode, test results, and artifact hash are recorded.

## Development

```bash
make check
make package
sha256sum -c dist/*.sha256
```

A change should preserve:

1. version agreement among `VERSION`, `aesh.ryz`, and `tools/ryzc`;
2. non-interactive exit status;
3. bounded inline evaluation;
4. reproducible package layout;
5. tag-only release publication;
6. honest separation between RYZ source and compatibility execution;
7. separation between local shell authority and typed MODOS domain authority.

## Status

Experimental and publicly runnable. It is a credible shell/source demonstration and packaging target, not yet a production login shell or operating-system authority layer.
