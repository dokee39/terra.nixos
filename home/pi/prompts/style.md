---
description: Review code style against the coding-style skill rules. Complement to /review.
argument-hint: "<files, diff, or path>"
---
Review code style: $ARGUMENTS

1. Read all relevant files in full (no truncation).
2. Load (if not already in context) and apply the rules from the coding-style skill (skills/coding-style/SKILL.md).
3. Apply every rule from that skill to the code. Check each category: Simplicity, Defensive Code, Naming/Comments/Voice, Maintainability.
4. For each finding, give file:line, quote the violated rule, and classify as high / medium / low.
5. Do not modify any files.
