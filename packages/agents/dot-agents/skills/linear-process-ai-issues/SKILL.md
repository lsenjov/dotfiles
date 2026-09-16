---
name: linear-process-ai-issues
description: Process a repository's configured Linear issue queue by answering issues marked AI Await Answer or implementing issues marked AI Await Implement. Use when Codex is asked to work through the current project's AI issue queue, research and answer Linear issues, or implement queued Linear work in the current Git repository.
---

# Process Linear AI Issues

## Resolve and validate repository configuration

Before any Linear mutation or repository edit:

1. Resolve the current Git root from the user's current task context with Git. Do not
   infer a repository from Linear data or search parent, sibling, or global config
   locations. If the task context is outside a Git worktree or makes the intended
   worktree ambiguous, stop without mutation.
2. Read exactly `<git-root>/.codex/linear-ai-issues.yaml`. Do not use a global,
   default, or fallback project. Missing or unreadable config is a hard stop.
3. Parse the YAML as this exact versioned schema:

   ```yaml
   version: 1
   project:
     name: "project-name"
     id: "project-uuid"
     url: "https://linear.app/..."
   team:
     name: "Team Name"
     id: "team-uuid"
   ai_status:
     group: "AI Status"
     answer:
       source: "AI Await Answer"
       destination: "AI Answered"
     implement:
       source: "AI Await Implement"
       destination: "AI Implemented"
   ```

   Require `version: 1`, every shown mapping and scalar, non-empty strings, valid
   UUIDs for both IDs, an HTTPS Linear URL, and four distinct transition labels.
   Reject unsupported versions, duplicate keys, YAML aliases, extra fields, multiple
   project/team entries, malformed values, or any other ambiguous representation.
   The repository root is implicit from the config location; reject repository path
   fields.
4. Snapshot the resolved root, exact parsed values, and config file fingerprint as
   immutable run configuration. Never reload, replace, or merge that configuration
   during the run; a later invocation may load a changed file.
5. Using read-only Linear calls, resolve the configured project and team by ID and
   verify their exact configured names, the project's exact URL, the project's team
   association, and all four exact label names in the configured label group on that
   team. Each identity and label must resolve uniquely. Any missing, mismatched, or
   ambiguous metadata is a hard stop with no Linear mutation or repository edit.

Do not discover issue queues until this preflight succeeds. Use only the immutable
validated values and resolved Git root for the whole run. When delegating an answer,
the parent must pass the resolved root and the complete immutable project, team,
label-group, transition, version, and fingerprint values to the subagent. The
subagent must use those values and must not locate, read, or select configuration
independently.

## Process in strict phases

Run repeated full cycles in this order: answer phase, implementation phase, then a
rescan of both source queues. Never start implementation discovery, preflight, or
work until the answer phase for that cycle is complete. Finish a cycle before
restarting discovery, even if an answer issue appears during implementation.

At invocation start, create an attempt/progress ledger keyed by issue ID and a
material fingerprint. Include current labels, issue and comment update context, and,
for implementation, relevant repository, commit, branch, upstream, and remote state.
Record every attempted side effect, its result, reconciliation, and completed
progress. After a failed side effect, allow at most one appropriate retry or
reconciliation attempt for the same fingerprint during this invocation. If that
also fails without a fingerprint change, mark it quiescent for this invocation;
never let it trigger another cycle. A materially changed fingerprint or a later
invocation may retry it.

After every completed full cycle, fetch both source queues again. Require at least
one such final rescan. Start another full cycle at the answer phase only when the rescan finds
new or materially changed actionable work, or actual forward progress exposed the
next pending work. Stop when a complete rescan finds neither. An incomplete side
effect may restart the loop only while its ledger entry still permits the bounded
retry. Treat unchanged conflicts, blockers, and exhausted failures as quiescent;
they must not keep the cycle running.

If an answer subagent exhausts its retry and aborts the cycle before Phase 2, perform
one terminal answer-queue rescan for reporting and stop. Do not discover or fetch the
implementation queue in that aborted cycle.

### Phase 1: answer every answer issue

1. Fetch every issue in the configured project and team carrying the answer source
   label. Follow pagination until exhausted. Do not fetch implementation work yet,
   and do not process issues from other projects or teams.
2. De-duplicate by issue ID. Sort by Linear's numeric semantics: `Urgent (1)`,
   `High (2)`, `Medium (3)`, `Low (4)`, then `No priority (0)` last. Within each
   priority, sort by creation time ascending.
3. When subagents are available, delegate one issue to each subagent, launching in
   that order and never exceeding available concurrency. Each answer subagent must:
   - Re-read its issue and current labels immediately before acting. Skip it if the
     answer source label is gone. If its AI Status labels are ambiguous, post at
     most one conflict comment under the idempotency rules, retain every label, and
     stop work on that issue.
   - Read the full issue, all comments, attachments, relations, and linked context.
     It may inspect relevant repository instructions, documentation, and code, but
     must never edit repository files, mutate Git state, commit, or push.
   - Reconcile prior comments and side effects, post or reuse the required answer
     comment, and replace the answer source label with the answer destination label
     only after the comment succeeds.
4. Wait for every launched answer subagent to finish before leaving the answer
   phase. If there are more issues than available slots, launch the next sorted
   batch as slots become available. Track a structured outcome for every launched
   issue, including its fingerprint, actions, results, and resulting eligibility.
   The parent must validate each result against current Linear state; subagent
   completion alone is not success. Retry a failed, missing, or invalid result once
   sequentially or in a later bounded slot, subject to the ledger. If it still
   fails with the same fingerprint, stop this invocation before Phase 2 and report
   the issue as a blocker. Never start implementation while an answer issue is
   unprocessed because its agent failed. If subagents are unavailable, perform the
   same per-issue procedure sequentially.
5. Re-fetch the complete answer source queue after all current answer work finishes.
   Reconcile it with the parent-validated outcomes and ledger. Process newly eligible
   or materially changed actionable issues in the same way, and repeat until a
   phase-boundary fetch finds none that remain actionable under the ledger. An
   unchanged issue already reconciled with an idempotent conflict comment or an
   exhausted side-effect failure is quiescent rather than actionable.

### Phase 2: implement every implementation issue

1. Only after the answer phase is complete, fetch every issue in the configured
   project and team carrying the implementation source label. Follow pagination
   until exhausted. Do not process issues from other projects or teams.
2. De-duplicate by issue ID. Sort by the same priority semantics as the answer phase,
   then by creation time ascending. Process this queue sequentially.
3. Before any implementation issue or related Linear mutation, confirm the configured
   repository is a Git repository and inspect staged, unstaged, and untracked files.
   If any change is present, disable implementation processing for the rest of the
   run, report the dirty paths, and leave every implementation issue untouched with
   no Linear mutation.
4. Immediately before each issue that remains eligible, re-read its current labels
   and material context. Skip it if it no longer has the implementation source
   label; the label transition is the completion signal. If its AI Status labels are
   ambiguous, reconcile under the conflict rules below, retain every label, and
   continue safely. The clean-repository preflight must have succeeded before
   commenting on an ambiguous implementation issue.

An AI Status conflict means that the issue carries more than one label from the
validated configured label group, including group labels not named in the four
configured transition values. Never change the normal Linear workflow status.
Preserve every non-AI label. When a transition is required, replace only the source
AI Status label with its configured destination. Prefer conditional or versioned
mutations and delta label updates when available. Change the label only after the
required comment succeeds.

## Guard every Linear mutation

Immediately before every Linear comment or label mutation, re-fetch the issue's full
current labels and material issue/comment context. If the expected source label is
gone, do not perform the stale mutation. If AI Status labels conflict, do not perform
the intended mutation; reconcile using the idempotent conflict-comment rules while
retaining all labels. If material context changed, update the fingerprint and restart
or refresh the analysis before commenting.

After a required comment succeeds and immediately before its destination label
update, re-read the complete current label set and material context again. Replace
the source label only if it is still present, AI Status labels are unambiguous, and
the context still supports the result. Preserve all non-AI labels. If any check
fails, stop the stale transition and reconcile from current state. Apply the ledger's
bounded retry rule to comment and label failures.

## Reconcile reruns

After the label recheck and any required implementation preflight, inspect prior
comments, commits, and remote commit containment.
Reconstruct completed side effects and resume at the first incomplete one. Do not
repeat an equivalent comment, edit, commit, or push when the issue and its material
context have not changed. Reconcile every observed side effect into the invocation
ledger before deciding whether another attempt is permitted.

For an answer, reuse an existing complete answer comment and perform only the missing
label transition. For an implementation, reuse a clearly matching commit from a
prior attempt. If it is already pushed, do not create another commit;
resume with the missing success comment or label transition. If the success comment
already exists, perform only the missing label transition. Treat ambiguous ownership
of prior work as a blocker rather than assuming it belongs to the issue.

Preserved uncommitted work from a failed prior invocation is a manual blocker: the
clean-repository preflight prevents automatic attribution or reuse. Report its dirty
paths and leave all implementation issues untouched until a human resolves it.

## Answer an issue

For an issue carrying the configured answer source label:

1. Read the full issue, all comments, attachments, relations, and linked context.
   Inspect relevant repository instructions, documentation, and code.
2. Assess whether the request and its assumptions are valid. Develop a concrete
   proposed solution. Identify missing information and formulate precise questions.
3. Post exactly one comment containing the assessment, proposed solution, and any
   necessary questions. Questions do not block this workflow.
4. After the comment succeeds, replace the answer source label with the answer
   destination label. If the comment fails, leave labels unchanged.

Always make the answer transition after a successful comment, including when the
comment asks questions.

## Implement an issue

For an issue carrying the configured implementation source label:

1. Read the full issue, comments, attachments, relations, linked context, and the
   relevant repository instructions, documentation, and code. Validate the request
   before editing.
2. If information is missing or the work is unsafe or invalid, post one comment with
   precise questions or blocker details. Before posting, inspect existing comments.
   If an equivalent question or blocker comment exists and no later human response
   or material issue or context change has occurred, do not repost it. Retain the
   source label and continue to the next issue when safe.
3. Before editing, inspect the current branch, upstream and remotes, branch
   divergence, and intended push target. A current default branch is valid. If the
   issue requests switching or creating a branch or creating a pull request, post
   one idempotent blocker comment, retain the source label, and continue to the next
   issue when safe. If the branch is detached, the push target is unsafe or
   ambiguous, or unrelated unpublished commits would be included, post one
   idempotent blocker comment, retain the source label, and disable implementation
   processing for the rest of the run. A clearly matching unpublished commit from
   a prior attempt may be reconciled and pushed without making new edits.
4. Obey all repository instructions. Always work on the current checked-out branch;
   never switch or create branches and never create pull requests. The current
   branch may be the default branch and may be pushed.
5. Implement the issue. Infer and run the appropriate tests, lint checks, and type
   checks from the repository. Every selected check must pass. Review the diff and
   include only changes belonging to this issue.
6. Immediately before committing, re-fetch the issue labels and material request
   context and re-inspect the relevant repository, branch, commit, upstream, and
   remote state. If eligibility or the material request changed, do not commit or
   push stale work; stop safely, preserve recoverable work, and reconcile from the
   new fingerprint. Otherwise commit the completed work. Determine the current
   branch and its upstream. Push to the configured upstream; if none exists, set one
   only when a single safe remote and destination can be inferred. Treat a detached
   HEAD or ambiguous push target as a blocker. A local commit without a successful
   push is not success.
7. After the push succeeds, post one success comment containing the commit SHA, the
   pushed branch, every exact changed-file path with a concise summary, and each
   exact validation command with its result. Then replace the implementation source
   label with the implementation destination label.

On any question, blocker, failed check, commit failure, push failure, or comment
failure, apply the same existing-comment check, explain the details in one issue
comment when possible, and retain the implementation source label. Continue with
later issues only when repository state and the failure make that safe. If a failure
leaves the repository dirty, stop implementation processing after reporting the
blocker; do not discard changes. If a failure leaves an unpublished commit, also stop
all implementation processing so a later push cannot include it.
