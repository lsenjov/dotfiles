# Neovim configuration import

1. Import the authored Neovim configuration as an ordinary `nvim` Stow
   package, without nested Git metadata or generated spell output.
2. Add `~/.config/nvim` to the managed-path allowlist and teach the reversible
   link/restore flow to preserve `~/.config` as a real container directory.
3. Update documentation and test coverage, run the full verification suite,
   and obtain an independent code review with no high- or medium-severity
   findings.
4. Commit the reviewed repository changes, apply the `nvim` package to the
   live home directory, and verify the resulting link and backup.
