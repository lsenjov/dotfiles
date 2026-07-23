# Dotfiles

Personal Zsh, Prezto, Codex, and agent-skill configuration managed with GNU Stow.

The implementation is being delivered from the reviewed
[repository plan](plans/dotfiles-repository-plan.html).

## Bootstrap interface

```sh
./install --check
./install --apply
```

`--check` is read-only. `--apply` previews the Stow operation, backs up exact
conflicts under `${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups`, and
rolls back automatically if linking or verification fails.

Full installation, update, recovery, and removal documentation will be added
with the final implementation phase.

## Updating Prezto

Prezto is pinned as a recursive submodule. Advance it deliberately, initialize
its nested dependencies, run the repository tests, and commit the new pointer:

```sh
git -C packages/zsh/dot-zprezto fetch origin
git -C packages/zsh/dot-zprezto checkout <tested-commit>
git -C packages/zsh/dot-zprezto submodule update --init --recursive
./scripts/test
git add packages/zsh/dot-zprezto
```

Do not use `zprezto-update` as the normal update path; it can move the
submodule checkout without recording that revision in this repository.

The captured `.zshrc` also expects `fzf --zsh`, `~/.cargo/env`, and
`~/.local/bin/env` to exist. On a fresh CachyOS host, install `fzf` and create
non-destructive placeholders before first interactive startup; later Rust and
local-bin installers can populate those files:

```sh
sudo pacman -S --needed fzf
mkdir -p -- "$HOME/.cargo" "$HOME/.local/bin"
touch -- "$HOME/.cargo/env" "$HOME/.local/bin/env"
```
