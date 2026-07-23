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
