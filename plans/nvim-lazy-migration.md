# Neovim lazy.nvim migration

## Implementation phase

1. Replace the Vimscript entrypoint and vim-plug bootstrap with a Lua
   entrypoint and lazy.nvim bootstrap.
2. Express the existing plugin set, dependencies, settings, and mappings in
   Lua while preserving eager startup behavior. Remove the duplicate plugin
   declaration and replace the removed visual LSP code-action API.
3. Generate and commit `lazy-lock.json` so plugin revisions are reproducible.

## Verification

1. Validate Lua syntax and start Neovim headlessly with the existing plugin
   installation.
2. Bootstrap lazy.nvim and all plugins in isolated XDG directories, then run
   Neovim health and startup checks against the isolated installation.
3. Run `scripts/test` and obtain an independent review with no high- or
   medium-severity findings before committing the implementation phase.

## Treesitter restore repair

1. Document and install the Tree-sitter CLI required by the current
   nvim-treesitter branch.
2. Complete the live plugin restore, then update installed parsers from a
   fresh Neovim process so the update uses the restored Treesitter code.
3. Repeat syntax, startup, repository, and independent review checks before
   committing the repair.
