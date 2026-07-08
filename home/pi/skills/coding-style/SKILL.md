---
name: coding-style
description: Read before writing or modifying code, writing tests, or reviewing code style. Prevents over-engineering, defensive code, AI filler, dead code, and scope creep. If `/style` already loaded this file, skip re-reading.
---

# Coding Style Rules

Code is read more than it's written. These rules prevent the most common AI-generated code anti-patterns. Follow when writing or modifying code. Each rule shows what to avoid and what to do instead.

## Simplicity

### No over-engineering

Don't create classes, factories, or wrappers for things that work as plain functions. Don't wrap default values in a factory function that just spreads them. Wait for the third occurrence before extracting shared logic.

```python
# BAD — class for a one-line operation
class UserFormatter:
    def __init__(self, user: User):
        self.user = user
    def format(self) -> str:
        return f"{self.user.first} {self.user.last}"

# BAD — factory that just spreads defaults
def create_config(host: str = "localhost", port: int = 3000) -> Config:
    return Config(host=host, port=port)

# GOOD
display = f"{user.first} {user.last}"
config = Config(host="example.com", port=3000)
```

### No dead code

Commented-out blocks, unused imports, unreachable branches, backward-compat shims with no external consumers. Delete entirely — git history preserves the old version.

```python
# BAD
# def old_parse(data):
#     ...
import os  # unused
```

Rust: unused `use` statements, `#[allow(dead_code)]` as a permanent fix. C++: unused `#include`, commented-out `#ifdef` blocks.

### No verbose patterns

Redundant else after return, redundant boolean comparison, unnecessary async/await, unnecessary copy.

```python
# BAD
if user:
    return user.name
else:
    return "anonymous"

# BAD
if active == True:
    ...

# BAD
async def get_user(uid: str):
    return await fetch_user(uid)

# GOOD
if user:
    return user.name
return "anonymous"

def get_user(uid: str):
    return fetch_user(uid)
```

Rust: unnecessary `.clone()` on values not reused. C++: `else` after `return`/`throw`; copy when `const auto&` suffices; `.get()` on `unique_ptr` then dereference when `*ptr` works.

## Defensive Code

### No redundant guards

Don't add null/type checks, fallback values, or error handling for scenarios the type system, prior checks, or caller's contract already rules out.

```python
# BAD — name is str, not Optional
def greet(name: str) -> str:
    if name is None:
        raise ValueError("name required")
    return f"Hello, {name}"

# GOOD
def greet(name: str) -> str:
    return f"Hello, {name}"
```

Rust: don't `if let Ok` then `unwrap()` — use `match` or `?`. Don't `is_some()` then `unwrap()` — use `if let Some(x)`. C++: don't null-check references or `unique_ptr` from dereference; don't `size()`-check before indexing when the loop bound guarantees it.

### No silent swallowing

Don't catch errors only to return a default, continue silently, or log-and-reraise without adding handling.

```python
# BAD — log and re-raise adds noise, no handling
try:
    result = store(data)
except Exception as e:
    logger.error(f"Failed: {e}")
    raise

# GOOD — let it propagate to where it's handled
result = store(data)
```

If silence is deliberate, annotate: `except FileNotFoundError: pass  # INTENTIONAL: idempotent cleanup`.
Exception: catching to add context the upstream handler lacks (e.g., local variables at a service boundary) is valid handling, not noise.

```rust
// BAD — discarding the error
let _ = fallible_op();

// BAD — silently converting to None
let result = fallible_op().ok();

// GOOD — propagate
let result = fallible_op()?;
```

C++: no empty `catch(...) {}`.

### No generic error messages

```python
# BAD
raise ValueError("Invalid input")

# GOOD
raise ValueError(f"Could not parse {doc_id}: expected JSON, got {content_type}")
```

Rust: `.expect("reason")` over bare `.unwrap()`. C++: `throw std::runtime_error("msg: " + detail)` over bare `throw std::runtime_error("error")`.

### No suppressed safety without explanation

```python
# BAD
result = compute(data)  # type: ignore

# GOOD
result = compute(data)  # type: ignore — mypy lacks the validation context
```

Rust: `unsafe` requires `// SAFETY: <why sound>`. C++: prefer `static_cast` over C-style casts; comment on any reinterpretation.

## Naming, Comments & Voice

### No self-evident restating

Comments that rephrase the next line add zero information. Document *why*, not *what*.

```python
# BAD
# increment counter
counter += 1

# BAD
def get_db():
    """Get the database client."""
    return _db

# GOOD
# Map Python log levels to Cloud Logging severity
SEVERITY_MAP = {logging.INFO: 200}

def get_db():
    return _db
```

No section dividers, no emoji, no vague TODOs. If a TODO is real, reference a ticket: `# TODO(PROJ-123): rate limit this endpoint`.

### No AI filler

```python
# BAD
# Ensure proper error handling
# Handle edge case gracefully
enhanced_user = merge(base, override)

# GOOD
# Close DB connection even if the query fails
merged_user = merge(base, override)
```

Flag as filler in comments: ensure, robust, graceful, properly, safely, elegant, comprehensive.
Flag as filler in names: enhanced, optimized, improved, streamlined, sophisticated.
Factual guarantees ("Ensure the connection is closed before returning") are fine. Slop is when these words replace specificity.

### No narrative or hedging

```python
# BAD
# First, validate the input
validate(input)
# Then, process
return process(input)

# BAD
# This might not be the most efficient approach, but...
# This works for now but could be improved

# GOOD — delete both. Code reads top to bottom. Ship what works or fix what doesn't.
```

### Explicit over implicit

```python
# BAD
if status == 3:
    ...
x = calc(d, 0.85, True)

# GOOD
if status == OrderStatus.SHIPPED:
    ...
x = calculate_discount(price, TAX_RATE, include_shipping=True)
```

Rust: named constants over raw bit flags in `#[repr]`; `enum` over `u8` with documented variants. C++: `enum class` over integer constants; named arguments via struct or descriptive temporaries.

## Maintainability

### No duplication

Cut-and-paste blocks or repeated utility functions across files. Unify on the third occurrence — duplication is cheaper than the wrong abstraction. When extracting, ensure the duplicated things change for the same reasons.

```python
# TWO occurrences — tolerate
def handle_slack(event):
    user = event.get("user", "unknown")

def handle_api(request):
    user = request.get("user", "unknown")

# THREE occurrences, same shape, same reason to change — extract
def extract_user(data):
    return data.get("user", "unknown")
```

### No scope creep

Don't modify unrelated files, reintroduce deliberately removed code, or create new files for one-off functions. Default bar for a new file: 3+ functions with a distinct responsibility not covered by any existing file.
