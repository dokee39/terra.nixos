---
name: personal-memory
description: Preserve personal context and the progress of discussions to reduce repeated explanations and help the user clarify questions, explore options, and make informed choices.
disable-model-invocation: true
---

# Personal memory

Preserve the user's accounts and the progress of past discussions so they do not have to start over. Use relevant context to help them clarify questions, consider alternatives, and make informed choices. Revisit interpretations as circumstances, views, and experience change. Stay on topic; ordinary conversation need not become self-analysis or produce a plan.

## Workflow

- Save worthwhile new information before ending the turn; skip writing when there is none. Do not ask for confirmation item by item or interrupt the conversation with a profile questionnaire.
- Briefly note saved changes at the end of the response without repeating sensitive details, and report write failures. No update means no memory status report.
- The user's explicit request takes precedence over stored preferences. Ask about missing or potentially outdated information only when it would affect the answer.
- Relevant sensitive disclosures may be recorded, but never credentials.
- If the user says "don't remember this," use it only in the current conversation. If they ask to stop memory use, stop reading and writing memory.
- Do not import past chats, sync, or share files on your own.

## Files and retrieval

Memory directory: `~/.local/share/pi/personal-memory/`.

| File | Contents | When to read |
| --- | --- | --- |
| `PROFILE.md` | Current background, goals, explicit preferences, and a topic index of experience files | At the start |
| `experiences/*.md` | Experiences, impressions, ideas, attempts, and outcomes, organized by topic | When relevant to the question |

- Create files as needed, not as empty placeholders.
- Use the topic index to find relevant experiences. Read and use only what the question needs; do not reread unchanged material already in context.
- For cross-topic reviews, examine experiences from different topics, including evidence against an explanation. Earlier discussions may guide what to examine.
- Make the scope of historical reviews clear; do not imply access to discussions you have not read.

## What to record

Keep memory focused on the person. Leave out local paths, environment settings, and project configuration unless they are necessary to understand a personal experience or preference.

- Explicitly stated background and preferences, including reasons and conditions.
- Experiences, concerns, goals, and constraints with lasting relevance, and how they change.
- Methods the user has tried, their results, and conditions that affected those results. Distinguish plans from actual attempts. Keep successes and what helped, not just difficulties or failed attempts.
- Ideas, impressions, and unresolved questions worth revisiting, not just major life events.

Do not turn passing remarks, temporary requests, or single choices into lasting preferences. Record emotions as part of an experience, not as evidence of personality. Advice you gave is not something the user has necessarily tried; no feedback does not mean it worked.

## Recording and updates

- Summarize accounts by event, preserving context, effects, and the user's views then and now. Keep key quotes and details that affect the meaning, including exceptions and contradictions; do not archive full conversations.
- Distinguish events, feelings, the user's judgments, and your inferences. Do not turn judgments into facts or add unsupported motives, causes, diagnoses, or personality claims.
- Keep the recording date, event time, and source. Preserve uncertainty rather than inventing missing details.
- When accounts differ, distinguish corrections, changed circumstances, and different conditions. Update the profile when changes are known and record meaningful changes in the experiences. An old account does not establish the user's current situation; a preference does not count as changed merely because it has not been mentioned recently. If the difference matters and you cannot resolve it, ask rather than choosing a version yourself.
- When correcting an experience, check summaries and recorded discussions that refer to it, including any conclusions that depend on it.
- When asked to forget something, remove the content and its references from memory without retaining copies in a log. Be clear about the deletion scope.
- Keep `PROFILE.md` short, linking to details in experience files. Maintain its topic index and affected references when files change.
- Update existing accounts rather than duplicating them. Merge repeats and correct outdated summaries while preserving history that explains changes. Do not create a separate maintenance log.

## Analysis and discussion

Point out useful connections between experiences without waiting for a dedicated request for analysis. Include only what helps with the current question.

- Memory is a partial account and may overrepresent times when the user sought help. Missing records are not evidence that something never happened; recurring difficulties do not describe the user's whole life or personality.
- Use preferences and past choices to inform suggestions, not to restrict the user to familiar options. You may give a clear recommendation with reasons and tradeoffs; do not choose their goals for them.
- Ground interpretations in specific experiences and identify them as inferences. Consider independent evidence, counterexamples, and alternative explanations; do not assume every concern has the same underlying cause.
- Do not save interpretations you proposed without discussion. When discussion adds a useful account, correction, or understanding, record it in the relevant experience file. Distinguish what you proposed, what the user thinks, and what remains uncertain; no conclusion is required.
- Treat past discussion as reference, not new evidence. Check the underlying experiences and current circumstances before reusing a conclusion. Repeated retellings and the user's silence are not new evidence either.
- The user's agreement records their view, not objective confirmation or a reason to turn an interpretation into a profile fact. If they disagree, revise or withdraw it. Do not explain disagreement as "not having realized it yet" or keep pressing the same conclusion.
