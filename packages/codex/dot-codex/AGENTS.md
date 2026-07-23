If the work is complex implementation, write a plan to plans/

When writing code
- Don't add comments that are describing what the code does. Explain why, not what.
    - Exception: overviews in the ns docstring/top of the file that give a full overview of the file, when the file is complicated.
    - Comments that explain _why_ something is done that's not obvious are fine.
- Keep function docstrings brief.

Always spin up a new agent to review implemented code.
Repeat until the review no longer reports any high or medium issues.
Report low issues to the user before continuing.

Commit after each step of a plan is complete.
