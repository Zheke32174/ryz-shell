# Agent Recommendations for AeSH / ryz-shell

Date: 2026-06-09
Source: GPT review, posted at Anthony's request
Audience: agents modifying `ryz-shell`, `aesh.ryz`, or `ryznative.py`

## Role

AeSH is the first flagship RYZ application and the live control shell for the RYZ runtime.

Keep it small, correct, and auditable.

## Current strengths

- Written in RYZ.
- Has builtins: `cd`, `pwd`, `exit`, `help`, `status`, `history`, `run`, `compose`.
- Supports inline RYZ via `ryz:` and `:`.
- Persists history at `~/.aesh_history`.
- Routes commands through one dispatcher.
- Passes external commands through to the host shell.

## Immediate fixes

### 1. Standardize argv

Use function style everywhere:

```ryz
let args = sys.argv()
```

Avoid property style:

```ryz
sys.argv
```

### 2. Fix fmt.system contract

AeSH currently wants the exit code from external commands. Recommended language contract:

```text
fmt.system(string) -> i64
```

Then AeSH should do:

```ryz
LAST_STATUS = fmt.system(stripped)
```

If the compiler currently treats `fmt.system` as void, patch sema/codegen or adjust AeSH after the final language ruling.

### 3. Preserve the single dispatcher

Do not route commands around `dispatch(line)`.

All future provenance/audit metadata depends on one command path.

### 4. Do not expand AeSH into the whole OS yet

AeSH should call out to tools like `rpkg`, `ryzstrat`, `kernel_bridge`, and `phase`, not absorb their logic.

## Good next tests

```text
aesh -c "help"
aesh -c "pwd"
aesh -c "status"
aesh -c "history"
aesh -c "ryz: fmt.println(\"hello\")"
aesh -c "false"     # should set nonzero LAST_STATUS
aesh -c "true"      # should set zero LAST_STATUS
```

## Operating doctrine

```text
No shell feature without a smoke test.
No external command behavior without exit-code preservation.
No audit feature outside the dispatcher.
```
