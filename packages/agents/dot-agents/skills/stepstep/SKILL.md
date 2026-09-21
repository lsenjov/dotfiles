---
name: stepstep
description: Walk through a file, function, snippet, or other text one non-empty line at a time, explaining what each line does. Use only when the user explicitly asks for stepstep or $stepstep.
---

# Stepstep

Use this skill only when explicitly requested by name.

Read the requested material and enough surrounding context to explain it accurately. If the target is unclear, ask which file, function, or text to walk through.

Start at the beginning of the requested scope, or the line the user specifies. Preserve source order and original line numbers. Skip empty and whitespace-only lines; include comments and delimiter-only lines.

For each turn:

1. Show the current line verbatim with its file and original line number when available.
2. Explain in plain language what happens on that line. For a line within a multiline expression, explain its role in the whole expression without advancing the walkthrough.
3. Pause for questions or an explicit `next`, `continue`, or equivalent before moving to the next non-empty line. Answer follow-up questions about the current line without advancing. Honor explicit requests to jump or change pace.

Keep explanations focused on the current line and distinguish inferred intent from known behavior. Explain comments as documentation and delimiters as structure, without implying they execute independently.

After the last non-empty line, say the walkthrough is complete. If the scope contains no non-empty lines, say so. This is an explanation task; do not edit the material as part of the walkthrough.
