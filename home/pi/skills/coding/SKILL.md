---
name: coding
description: General coding rules for writing, changing, refactoring, debugging, or reviewing code and tests (codebase consistency, minimal design, boundary validation, fail-fast errors, testing, and code clarity).
---

# Coding Principles

## Structure & Consistency

- Match the repository's directory layout, naming style, idioms, and module boundaries. Reuse or extend existing entry points and shared helpers instead of writing one-off duplicates.
- When moving, merging, or replacing code—or changing interfaces and entry points—check where it is created or registered, update callers, and remove old paths. When fixing a bug caused by a repeated pattern, check similar code paths for the same bug. Never silently duplicate, bypass, or half-migrate an existing design: finish the migration within scope, or point out any parallel paths left behind and why.
- Recheck symbol, parameter, and file names whenever behavior, role, or types change. Rename outdated internal names within scope; if an outdated name is part of a public API, config key, or data schema, keep compatibility and point out the mismatch.
- When a change outgrows the existing structure, reshape the control and data flow instead of bolting on boolean flags or special-case branches. Delete dead code, unused imports, commented-out blocks, and unused compatibility code.

```python
# BAD — boolean flag patchwork; validate_token now mutates DB
def validate_token(tok: Token, auto_refresh: bool = False) -> Claims:
    if tok.expired:
        if not auto_refresh:
            raise AuthError("token expired")
        tok = issue_refresh(tok.user_id)
        db.save_token(tok)
    return decode_claims(tok)

# GOOD — separate responsibilities, accurate names
def refresh_if_expired(tok: Token) -> Token:
    if not tok.expired:
        return tok
    fresh = issue_refresh(tok.user_id)
    db.save_token(fresh)
    return fresh

def verify_claims(tok: Token) -> Claims:
    if tok.expired:
        raise AuthError(f"token expired for user {tok.user_id}")
    return decode_claims(tok)
```

## Minimal Design

- Prefer plain data and functions over classes, factories, builders, or manager objects unless state, resource lifecycles, or multiple implementations genuinely need them.
- Avoid interfaces or traits with only one implementation, pass-through wrappers, and one-off helpers that break up straight-line code without hiding real complexity. Follow the project's existing layers without adding extra pass-through layers.
- Build only what is needed now—no unrequested config options, extension hooks, or abstractions for imaginary future callers. Create a new file only when it has a clear, separate role.
- Extract shared code only when duplicates change for the same reason; prefer small local repetition over tying different cases together behind flag-heavy helpers.
- Keep functions, fields, and types private by default, exposing them only when external callers need them. Put repeated, spec-defined, or meaningful domain values into named constants or enums; keep obvious one-off literals inline.

```python
# BAD — unrequested options, class for stateless work, pointless helper
class ReportFormatter:
    def __init__(self, sep: str = "\n", limit: int | None = None):
        self.sep, self.limit = sep, limit
    def _fmt_row(self, name: str, ms: float) -> str:
        return f"{name}: {ms:.1f}ms"
    def render(self, timings: list[tuple[str, float]]) -> str:
        rows = [self._fmt_row(k, v) for k, v in timings[:self.limit]]
        return self.sep.join(rows)

# GOOD — plain function for the actual requirement; obvious literal inline
def format_timings(timings: list[tuple[str, float]]) -> str:
    return "\n".join(f"{name}: {ms:.1f}ms" for name, ms in timings)
```

## Boundaries & Fail-Fast

- Parse, validate, and normalize untrusted input once at external boundaries (CLI, network, file I/O, config loading, FFI).
- Past the boundary, trust types, parsed data, and caller contracts: no redundant null or type checks, no `.get()` fallbacks on required fields, no handling for input types callers never pass, and no defensive copies when data is not mutated.
- Fail fast when assumptions break. Propagate errors (`?`, `Result`, exceptions) with specific details (IDs, bad values, what was expected).
- Never silently drop unexpected errors (`except: pass`, bare `let _ = ...`, `.ok()`) or catch only to log and re-raise. Catch errors only to recover, convert them at a module or protocol boundary, or add key details (file path, ID, input) missing from a lower-level error—never wrap calls just to repeat the call stack.
- When a missing item or cleanup failure is harmless, prefer built-in idempotent options (`missing_ok=True`). When an error must be ignored directly, match only the specific expected error and comment why if non-obvious.

```python
# BAD — internal null/type checks, type guessing, raw env fallback, swallowed error
def run_step(step: Step, env: dict[str, str]) -> Artifact:
    if step is None or not step.cmd:
        return Artifact.empty()
    cmd = [step.cmd] if isinstance(step.cmd, str) else list(step.cmd)
    timeout = int(env.get("STEP_TIMEOUT") or 30)
    try:
        proc = exec_proc(cmd, timeout=timeout)
        return parse_artifact(proc.stdout)
    except Exception as e:
        logger.error(f"step failed: {e}")
        return Artifact.empty()

# GOOD — validated at the boundary; internal code trusts types and fails fast
def run_step(step: Step, timeout_s: int) -> Artifact:
    proc = exec_proc(step.cmd, timeout=timeout_s)
    if proc.returncode != 0:
        raise StepError(f"step {step.name} exited {proc.returncode}: {proc.stderr}")
    return parse_artifact(proc.stdout)
```

## Verification & Testing

- Reproduce or trace the root cause before fixing non-obvious bugs.
- Test distinct behaviors and real edge cases, using parameterized or table-driven tests instead of copy-pasted test functions. Do not mock internal helpers, copy production logic into assertions, build heavy fixtures for simple inputs, or test trivial wiring and things the type system already guarantees.
- Never make checks pass by weakening assertions, skipping or deleting failing tests, silencing linters without cause, or adding test-only branches to production code.

## Code Clarity

- Flatten control flow with guard clauses and early `return` or `continue`; avoid unnecessary `async` wrappers.
- Write all comments in English, and comment only when assumptions, tradeoffs, or domain rules are not obvious from the code—explain *why*, never restate *what* or narrate steps. Leave out section banners, emojis, hedging comments, and vague TODOs.
- Never suppress type, lint, or memory-safety checks (`unsafe`, `# type: ignore`, `#[allow(...)]`) without an inline comment explaining why it is safe or necessary.
- Use clear, specific names (`merged_config`, `parse_header`); never use vague AI filler words in names or comments (`enhanced`, `robust`, `graceful`, `streamlined`, `optimized`, `properly`, `safely`, `comprehensive`).
