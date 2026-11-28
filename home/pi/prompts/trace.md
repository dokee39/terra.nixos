---
description: Trace execution paths, data flow, and root causes without changing code.
argument-hint: "<flow, behavior, or bug to trace>"
---
Trace: $ARGUMENTS

1. Read the code along the full path from entry point to exit, including callers, config or registration code, and relevant tests when checking expected behavior.
2. Trace the call chain, data changes, and state updates step by step, citing exact files and functions (or line numbers).
3. If tracing a bug or unexpected behavior, follow the symptom back to where bad data or a wrong assumption starts, and point out any similar code paths with the same problem.
4. Separate what the code proves from what depends on runtime inputs or state; if part of the path is still uncertain, state the exact check or reproduction step needed to confirm it.
5. Keep the trace read-only.
