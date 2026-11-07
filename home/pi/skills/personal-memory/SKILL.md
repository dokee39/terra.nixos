---
name: personal-memory
description: Record and recall the user's background, experiences, preferences, and tentative interpretations to reduce repeated explanations and inform responses.
disable-model-invocation: true
---

# Personal memory

Preserve how the user describes themselves. Use relevant experiences and feedback to inform answers. Stay on topic; do not turn ordinary conversation into an analysis of the user.

## Workflow

- Read `PROFILE.md` first, then consult experiences relevant to the question. Do not reread unchanged material already in context.
- Save worthwhile new information before ending the turn. Do not ask for confirmation item by item or interrupt the conversation with a profile questionnaire. If there is nothing new to record, do not write.
- After saving, briefly note what changed at the end of the response without repeating sensitive details. Report save failures honestly. No update means no status report.
- Relevant sensitive disclosures may be recorded, but never credentials. If the user says "don't remember this," use it only in the current conversation. If they ask to stop memory use, stop reading and writing memory. Do not import past chats, sync, or share files on your own.

## Files and retrieval

Memory directory: `~/.local/share/pi/personal-memory/`. Resolve `~` to the user's home directory and access files by absolute path.

| File | Contents | When to read |
| --- | --- | --- |
| `PROFILE.md` | Current background, goals, explicit preferences, and a topic index of experience files | At the start |
| `experiences/*.md` | Experiences, impressions, ideas, attempts, and outcomes, organized by topic | When relevant to the question |
| `REFLECTIONS.md` | Tentative interpretations, evidence, counterexamples, and user feedback | During relevant analysis or review, or when the supporting evidence needs correction |

- If a file does not exist, continue the conversation. Create it when there is content to save, not as an empty placeholder.
- Find experiences through the topic index; search the experience directory if needed. Read only relevant material rather than loading all memory. Leave unrelated background out of the answer.
- When looking for connections across topics, start with the index, then read experiences from different topics for evidence both for and against an explanation. Read the user's accounts before earlier interpretations to avoid looking only for confirmation.
- State what material you actually reviewed. Do not claim to have reviewed "all our discussions" when you have not read them. Ask for missing information only when it would affect the answer.
- The user's explicit request takes precedence over stored preferences. Do not use previously loaded interpretations to explain unrelated topics.

## What to record

Keep information that may reduce repeated explanations or improve future advice and recommendations:

- Explicitly stated background and preferences, including reasons and conditions.
- Experiences, concerns, goals, and constraints with lasting relevance, and how they change.
- Methods the user has tried, their results, and conditions that affected those results. Distinguish plans from actual attempts.
- Ideas and impressions worth revisiting, not just major life events.

Do not turn passing remarks, temporary requests, or single choices into lasting preferences. Record emotions as part of an experience, not as evidence of personality. Advice you gave is not something the user has necessarily tried; no feedback does not mean it worked.

## Recording and updates

- Organize long accounts by event. Preserve the background, sequence, effects, and the user's views then and now. Quote key wording exactly; do not put paraphrases in quotation marks. Keep turns of events, exceptions, and contradictions that matter to understanding the account. There is no need to archive the full conversation.
- Distinguish events, feelings, the user's judgments, and your inferences. Record views about others as "the user believes...", not as established facts. Do not invent motives, causes, diagnoses, or personality judgments.
- Include the recording date, the event time supplied by the user, and a source reference such as the conversation topic and a key quote. Use the current date for recording. Preserve phrases such as "last year" or "around that time" alongside the date of the account; do not guess precise dates or invent session IDs. Link profile summaries to experience files rather than duplicating their full contents.
- Read the target file before writing. Extend, merge, or correct existing records rather than duplicating them. A retelling may add detail, but is not new independent evidence.
- When accounts differ, distinguish corrections, changed circumstances, and different conditions. Keep the profile current and record meaningful changes in the experiences. If the difference matters and you cannot resolve it, ask rather than choosing a version yourself.
- When correcting an experience, check summaries and interpretations that cite it. When asked to forget something, remove the content and its references without retaining copies in a log. Explain that past sessions and external copies are not deleted by this action.
- After creating, merging, or deleting experience files, update the index in `PROFILE.md` and any affected references. Index entries describe file topics, not personality judgments.
- Keep the profile short and details in experience files. Reuse existing topics; split them only when needed. Clean up duplicate and outdated content as part of updates. Do not create a separate maintenance log.

## Analysis and interpretations

Point out useful connections between experiences without waiting for a dedicated request for analysis. Include only what helps with the current question.

- Ground interpretations in specific experiences. Check for support from independent events, and consider counterexamples and alternative explanations. Do not treat a repetition count as proof or assume every concern has the same underlying cause.
- Save only interpretations with specific evidence that are worth testing later. Passing associations may be discussed without being recorded.
- Briefly record the date proposed, the interpretation, where it applies, and references to supporting experiences. Include counterexamples, alternatives, or user feedback when available; update the date when revising. Do not invent content to fill fields. Neither missing feedback nor a lack of known counterexamples counts as support.
- Store interpretations only in `REFLECTIONS.md`, not in the profile or its index. Before using one again, check the original material and current circumstances. Your earlier analysis, repeated retellings, and the user's silence are not new evidence.
- Record the user's agreement or correction as their view, not as objective confirmation. If they disagree, revise or withdraw the interpretation. Do not explain disagreement as "not having realized it yet" or keep pressing the same conclusion.
- Revise or remove unsupported or outdated interpretations. Do not keep using one simply because you proposed it before.

When referring to memory, distinguish the user's past descriptions from your own inferences.
