---
description: Generate a handoff document, save to /tmp, and copy to clipboard.
argument-hint: "<custom instruction>"
---
Generate a handoff document: $ARGUMENTS

1. Write a forward-looking document — the end state and the path ahead, not a transcript. Omit dead ends, abandoned approaches, and trial-and-error unless their lessons fit a section below (e.g., why an approach was abandoned goes in Key Decisions; a gotcha discovered goes in Critical Context).

2. Use the following format. Adapt sections as needed — skip empty ones.

  ## Task Background
  [Why this work exists — original request, problem context, and initial requirements]
  
  ## Constraints & Preferences
  - [Rules and requirements stated by the user]
  
  ## Key Decisions
  - **[Decision]**: [Rationale]
  
  ## Current State
  ### Done
  - [x] [What is currently in place and still relevant]
  
  ### In Progress
  - [ ] [Current work]
  
  ### Blocked
  - [Issues, if any]
  
  ## Critical Context
  - [Non-obvious facts, gotchas, and discovered knowledge needed to continue — not user-stated rules]
  
  ## Next Steps
  1. [What should happen next]
  
  <read-files>
  path/to/file1.ts
  </read-files>
  
  <modified-files>
  path/to/changed.ts
  </modified-files>

3. Write the document to `/tmp/pi-handoff-[descriptive name].md`.
4. Copy to clipboard with `wl-copy < /tmp/pi-handoff-[name].md` using the `bash` tool.
5. Report the file path.
