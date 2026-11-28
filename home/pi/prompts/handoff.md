---
description: Generate a handoff document, save to /tmp, and copy to clipboard.
argument-hint: "[optional focus]"
---
Generate a handoff document: $ARGUMENTS

1. Write for the next session: capture current state and what remains, leaving out chat history and dead ends unless they explain a key decision or gotcha.

2. Use this format, skipping empty sections:

  ## Task Background
  [Goal, problem context, and core requirements]

  ## Constraints & Preferences
  - [Rules and preferences stated by the user]

  ## Key Decisions
  - [Decision] — [Why, including rejected options if relevant]

  ## Current State
  ### Done
  - [x] [What is in place and verified]

  ### In Progress
  - [ ] [Active or unfinished work]

  ### Blocked
  - [Open blockers or questions]

  ## Critical Context
  - [Non-obvious facts, gotchas, or unconfirmed assumptions needed to continue]

  ## Next Steps
  1. [What to do next]

  <read-files>
  path/to/relevant.ts
  </read-files>

  <modified-files>
  path/to/changed.ts
  </modified-files>

3. Write to `/tmp/pi-handoff-<slug>.md` and copy with `wl-copy < /tmp/pi-handoff-<slug>.md`.
4. Reply with the file path only.
