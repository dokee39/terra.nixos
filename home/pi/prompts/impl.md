---
description: Plan concrete code changes from the current task or discussion, confirm, then implement.
argument-hint: "[optional scope or instructions]"
---
Implement: $ARGUMENTS

1. Load the `coding` skill. Read the target files, entry points, and callers before planning.
2. Write a brief change plan: list the specific files and symbols to add, change, or remove (including old paths to delete) and how the change fits the existing code; separately call out any non-obvious choices or defaults you made, along with any open questions, conflicts, or simpler options found in the code. Wait for me to confirm before editing any files.
3. After I confirm, implement the changes following the `coding` skill. Put my actual goal and code preferences ahead of finishing the plan at all costs—if writing the code exposes a gap or edge case that would require extra complexity, awkward workarounds, or wider scope, stop and point it out.
4. Briefly report what changed and why.
