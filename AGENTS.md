# Dotfiles repository guidance

## Scope

- Keep this repository as an explicit allowlist of authored configuration.
- Never add credentials, histories, sessions, caches, logs, generated databases, or machine identifiers.
- Keep deployment reversible and avoid broad operations against `$HOME`.

## Implementation

- Write a plan under `plans/` for complex changes.
- Use `scripts/test` for the full local verification suite.
- Run `shellcheck` for shell changes and `xmllint --html --noout` for HTML changes.
- Require GNU Stow 2.4.0 or newer because earlier releases mishandle `--dotfiles` directories.
- After each implementation phase, use a new review agent. Fix all high- and medium-severity findings, repeat review until none remain, and report low-severity findings before continuing.
- Commit each completed plan phase separately.

## Code style

- Use comments only when they explain a non-obvious reason.
- Keep functions focused and fail safely when target paths or repository state are ambiguous.
