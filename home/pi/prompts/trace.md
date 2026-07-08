---
description: Read code, trace execution path, and report findings. Use for bugs, code understanding, or refactoring analysis.
argument-hint: "<what to trace>"
---
Trace: $ARGUMENTS

1. Define the scope — what code, behavior, or question are you tracing.
2. Read all relevant files in full (no truncation).
3. If this is a bug: read test files for the affected area too — they may reveal expected behavior that the implementation violates.
4. Trace the flow:
   - Map the execution path / call chain from entry to exit
   - Identify key data transformations and state changes
   - If tracing a problem, locate the symptom → immediate cause → data origin → root cause
5. Report findings clearly:
   - If a bug: root cause, impacted areas, and why it happens
   - If understanding: how the code works, key design decisions
   - If refactoring analysis: what patterns or structural issues exist and why they arose
6. Do not modify any files.
