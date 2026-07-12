---
description: Transition from discussion or research into implementation. Converge on scope, read code, then implement.
argument-hint: "<what to implement>"
---
Implement: $ARGUMENTS

1. Summarize the scope and constraints agreed on in this conversation.
2. Read all relevant files in full, and load (if not already in context) the rules from the coding-style skill (skills/coding-style/SKILL.md) to follow when writing code. Use available tools to gather any additional context as needed.
3. Think through the full implementation: what you will change, how it fits the existing code, edge cases, and anything you are uncertain about.
4. Output the plan, focused on what you will do — do not restate discussion conclusions. Cover: changes and steps; relevant code logic as it pertains to your changes; notes and open questions. If no open questions, state so. Wait for my acknowledgment or corrections before implementing.
5. Implement the change.
6. Run the project's test and lint commands. Fix minor issues directly. If you encounter a design conflict or a problem that makes the current approach unworkable, stop and report to me immediately.
7. Report a concise summary of what changed and why.
