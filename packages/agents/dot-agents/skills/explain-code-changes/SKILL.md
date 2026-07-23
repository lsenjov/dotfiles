---
name: explain-code-changes
description: Conduct an interactive walkthrough of changes on the current Git branch, pull request, commit range, or supplied diff. Use when the user wants to understand changed code in depth, review a branch one cohesive behavior at a time, inspect implementation intent, identify opportunities to simplify or trim changed behavior, or discuss each code unit before continuing. Present the relevant code with what-and-why explanations and a focused simplification assessment, answer questions about the current unit, and advance only after an explicit request.
---

# Explain Code Changes

Walk through changed code as a paced, read-only conversation. Present exactly one cohesive behavior per turn and advance only when the user explicitly says `next`, `continue`, or equivalent.

## Establish the change set

1. Honor supplied diffs, ranges, reviewed branches or PRs, and file scopes exactly.
2. For branch or PR reviews, choose the base from: user choice, PR target, then repository default. Diff the target's merge-base with the reviewed branch; use a tracking branch only if it is the integration branch.
3. Resolve both endpoints to SHAs, state them, and keep them pinned unless the user asks to refresh. Identify a supplied diff as fixed instead.
4. Read repository instructions, the full change set, and enough surrounding code to understand it.

Ask one concise question only when an ambiguous comparison would materially alter the review.

## Organize the walkthrough

Group changes by behavior, not hunk or file. A unit may span source, tests, types, and configuration; keep unrelated behavior separate. Include each changed test with the behavior it verifies, using only relevant shared test support. Order units by dependency, preferably from entry point or core behavior to internals and boundaries. Include unchanged context only when needed.

Before the first unit, create an empty action ledger. Add a simplification or trimming opportunity only when the user explicitly asks to retain it. Record:

- Unit and exact code references.
- `Definite` or `Question`.
- Candidate change, evidence, tradeoff, and lost capability.

Merge only true duplicates and retain all references. Never edit during the walkthrough. Record requested edits, but require fresh authorization after completion. If the user explicitly ends the walkthrough, acknowledge it before treating editing as a separate task.

## Present one unit

For the current behavior:

1. Name it and link its files or line ranges.
2. Briefly explain where it fits and what changed from the base.
3. Show focused code beside its explanation, using the collaborative viewer or a two-column layout when available. Otherwise place each exact excerpt immediately before its notes. Use a focused diff when clearer. For deletion or replacement, label base and branch excerpts; omit the branch excerpt for an unreplaced deletion.
4. For each excerpt explain:
   - **What:** control flow, data flow, state, or contract.
   - **Why:** requirement, invariant, tradeoff, or failure mode.
5. Mark inferred intent and its evidence. Split large units into ordered excerpts.
6. Show relevant tests after source code. Explain what each verifies and what it reveals about intent. If no relevant test changed, say so; mention existing coverage only when useful.
7. Add **Simplify or trim**:
   - **Definite:** evidence proves redundancy, duplication, unreachable code, needless indirection, or functionality already provided elsewhere.
   - **Question:** removal may help, but repository evidence does not prove the behavior is unnecessary.
   - For either, cite code and state the tradeoff and lost capability. Otherwise say `None found`.
   - Do not add findings to the action ledger unless the user asks.

Do not dump the full diff, narrate obvious syntax, or broaden critique beyond simplification unless asked.

## Pause

After a non-final unit, state that the walkthrough is paused and invite questions or an explicit advance command. Do not preview or explain the next unit. Questions, corrections, acknowledgements, and requests for detail do not advance it; answer them and remain paused.

After the final unit, state that the walkthrough is complete, show the consolidated ledger (`No items recorded` if empty), invite questions, and ask which items to action. Never infer authorization to edit.
