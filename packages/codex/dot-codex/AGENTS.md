# Generally

- Keep things simple.
  - When conversing, suggest ways to simplify complex things if you notice them.

If we're talking about/questioning an idea and I haven't asked you to implement, don't jump into implementation when you think everything is answered. Check first.

# Code

When writing code
- Keep things simple. Prefer simplicity where possible.
- Don't add comments that are describing what the code does. Explain why, not what.
    - Exception: overviews in the ns docstring/top of the file that give a full overview of the file, when the file is complicated.
    - Comments that explain _why_ something is done that's not obvious are fine.
- Keep function docstrings brief.

# Implementation

If the work is complex implementation, write a plan to plans/

Always spin up a new agent to review implemented code.

Repeat until the review no longer reports any high or medium issues.

Fix low documentation issues. These can be fixed without a review pass.

Report low issues to the user before continuing.

Commit after each step of a plan is complete.
