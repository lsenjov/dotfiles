# Dotfiles

Personal Zsh, Prezto, Neovim, Codex, and agent-skill configuration managed with
GNU Stow. The repository is an explicit allowlist: authored configuration
belongs here; credentials, sessions, histories, caches, logs, databases, and
machine identifiers do not.

The implementation follows the reviewed
[repository plan](plans/dotfiles-repository-plan.html).

## Managed paths

| Package | Home paths |
| --- | --- |
| `zsh` | `~/.zprezto`, six Zsh runcoms, and `~/.p10k.zsh` |
| `nvim` | `~/.config/nvim` |
| `codex` | `~/.codex/AGENTS.md` |
| `agents` | `~/.agents/skills/{grill-me,explain-code-changes,code-review-skill,astra-frontend-design,linear-process-ai-issues}` |

`~/.config`, `~/.codex`, and `~/.agents/skills` remain real directories. Only
the paths in [`config/managed-paths.tsv`](config/managed-paths.tsv) may be
linked, so unrelated application configuration, Codex runtime state, and
bundled `.system` skills cannot be folded into this repository by Stow.

## Fresh CachyOS bootstrap

Install runtime and verification dependencies:

```sh
sudo pacman -S --needed \
  actionlint diffutils fzf gcc git gitleaks libxml2 neovim perl python python-yaml \
  shellcheck stow tree-sitter-cli util-linux zsh
```

GNU Stow 2.4.0 or newer is required. Earlier releases mishandle directory
translation with `--dotfiles`.

Clone recursively and prepare the two files sourced by the managed `.zshrc`:

```sh
git clone --recurse-submodules <repository-url> "$HOME/code/lsenjov/dotfiles"
cd "$HOME/code/lsenjov/dotfiles"
mkdir -p -- "$HOME/.cargo" "$HOME/.local/bin"
touch -- "$HOME/.cargo/env" "$HOME/.local/bin/env"
```

Preview the environment and the exact Stow transaction before applying it:

```sh
./install --check
./scripts/link --dry-run
./install --apply
```

`--apply` initializes recursive submodules, simulates the operation against a
shadow home, copies and verifies each conflict, moves only manifested
conflicts, links the selected packages, and verifies every resulting symlink.
It rolls back automatically if linking or verification fails.

To operate on selected packages:

```sh
./scripts/link --dry-run zsh
./install --apply codex agents
```

Changing the login shell is deliberately separate:

```sh
chsh -s "$(command -v zsh)"
```

## Backups and recovery

Each non-idempotent apply writes a timestamped directory under:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/
```

The backup contains verified metadata-preserving copies, the moved originals,
a tab-separated manifest, created-container records, and a status file. Keep
the directory until the installation has been exercised successfully.

Restore one transaction with its exact path:

```sh
./scripts/restore \
  "$HOME/.local/state/dotfiles/backups/<timestamp>"
```

Restore multiple migration transactions in reverse chronological order. The
restore command accepts expected managed links or matching originals, refuses
changed targets, verifies copied content and modes, and never overwrites a
newer unmanifested path.

To remove managed links without restoring displaced files:

```sh
./scripts/unlink
```

Package names can be appended to `scripts/unlink`. Backups are never deleted
or restored automatically by unlinking.

Repository-import archives and retired Git metadata are stored separately
under:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/imports/
${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/retired/
```

Git bundles can be inspected with `git bundle verify` and cloned with:

```sh
git clone /path/to/repository.bundle /path/to/recovered-repository
```

These state directories are recovery material, not repository content.

## Normal updates

Update the repository without merging implicitly, verify the pinned recursive
dependencies, then reapply:

```sh
git pull --ff-only
git submodule update --init --recursive
./install --check
./scripts/test
./install --apply
```

A second apply is expected to report that every selected package is already
linked and must not create another backup.

### Updating Prezto

Prezto is a pinned recursive submodule. Advance it deliberately, initialize its
nested dependencies from inside the proposed checkout, run verification, and
commit the new gitlink:

```sh
git -C packages/zsh/dot-zprezto fetch origin
git -C packages/zsh/dot-zprezto checkout <tested-commit>
git -C packages/zsh/dot-zprezto submodule update --init --recursive
./scripts/test
git add packages/zsh/dot-zprezto
git commit -m "Update Prezto"
```

Do not use `zprezto-update` as the normal update path; it can move the
submodule checkout without recording that revision in this repository.

### Updating guidance and skills

Edit global instructions in
`packages/codex/dot-codex/AGENTS.md`. Personal skills live below
`packages/agents/dot-agents/skills/`. Most are ordinary tracked directories;
`astra-frontend-design` is a pinned submodule from
[Enixes/astra-frontend-design](https://github.com/Enixes/astra-frontend-design).

Run the focused validator while editing:

```sh
./scripts/validate-skills
```

To update Astra, check out the desired upstream revision in
`packages/agents/dot-agents/skills/astra-frontend-design`, run the verification
suite, and commit the updated submodule reference. Existing installations of the
retired `frontend-design` skill need their old `~/.agents/skills/frontend-design`
symlink removed; the installer only manages paths in the current manifest.

## Verification

The full local suite is:

```sh
./scripts/test
```

It checks:

- Bash syntax and ShellCheck
- plan HTML and GitHub Actions syntax when their validators are installed
- GNU Stow 2.4.0 or newer and recursive submodule state
- transactional backup, rollback, restore, and idempotence behavior
- the actual managed package allowlist in a temporary home
- Zsh syntax and a quiet interactive startup in a pseudo-terminal
- skill frontmatter, names, resource links, metadata, and attribution
- forbidden Codex runtime/cache paths and broken symlinks
- committed history and current files with Gitleaks when available

GitHub Actions runs the same suite in an Arch Linux container, with the full
verification toolchain installed, and scans both history and a clean archive
of tracked content.
