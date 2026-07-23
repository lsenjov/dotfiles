# Code Duplication

Language-agnostic strategies for finding and reviewing duplicated code.

## Automated detection with jscpd

Use [jscpd](https://jscpd.dev/) to find token-level duplication across source files. Prefer the repository's pinned command or package script when one exists. Otherwise, run the current v5 CLI without installing it:

```bash
npx jscpd@5 --reporters ai --no-tips ./src
```

The `ai` reporter produces compact locations without embedding every duplicated code block. Scan the relevant source roots, not only changed files, so new code can be compared with existing implementations.

For a narrower scan or a noisy repository, adjust the inputs and detection settings:

```bash
npx jscpd@5 \
  --reporters ai \
  --no-tips \
  --min-lines 8 \
  --min-tokens 70 \
  --ignore "**/node_modules/**,**/dist/**,**/coverage/**,**/__snapshots__/**" \
  ./src ./packages
```

Use `--pattern "**/*.ts"` or `--format typescript` when the review concerns a specific file type. Use `--skip-comments` when repeated comments or generated documentation obscure meaningful matches.

Projects that run jscpd regularly should keep shared settings in `.jscpd.json`:

```json
{
  "minLines": 8,
  "minTokens": 70,
  "reporters": ["ai"],
  "ignore": [
    "**/node_modules/**",
    "**/dist/**",
    "**/coverage/**",
    "**/__snapshots__/**"
  ]
}
```

For CI, add a repository-agreed `threshold` percentage or pass `--threshold <percent>` so duplication above that limit fails the command. If existing duplication already exceeds the desired target, begin with the measured current percentage and lower the threshold as duplication is removed; jscpd has no separate baseline mode.

## Review the findings

Treat jscpd output as evidence to inspect, not as proof that code must be deduplicated.

1. Open both reported ranges and confirm they implement the same domain concept, not merely similar syntax.
2. Check whether the blocks are likely to change together. Shared ownership and shared reasons to change strengthen the case for extraction.
3. Exclude generated files, snapshots, vendored code, migrations, and intentionally explicit test cases unless maintaining the copies is causing errors.
4. Prefer an existing helper or abstraction when it already represents the shared concept. Otherwise, extract only when the new abstraction has a clear name and simpler interface than the duplicated blocks.
5. Report the affected locations, the maintenance risk, and a concrete reuse or extraction option. Avoid blocking solely on a repository-wide duplication percentage.

Re-run the same command after a refactor to confirm the target clone disappeared and that the change did not merely move or fragment the duplication.
