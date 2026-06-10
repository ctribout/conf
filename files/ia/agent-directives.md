# Tool usage

Prefer purpose-built operations over shelling out: when dedicated tools are
available for reading, finding, searching, and editing files, use them rather
than their shell equivalents (no `for` loops over `cat`, `find`, `grep`, …
when an internal tool can do it directly).

Prefer in-repo tooling (Makefile targets, defined lint/test scripts,
pre-commit hooks) over inventing ad-hoc commands.

# Secrets

Treat tokens and credentials as sensitive: never echo or print their values,
never write them to files, logs, or commits, and refer to them by variable
name. Redact values that would otherwise appear in output. Avoid passing
secrets as command-line arguments (visible via `ps` and shell history); prefer
environment variables, stdin, or credential files.

# Environment safety

Never run `sudo` for any reason. If a task requires elevated privileges, stop
and tell the user what would need to be done so they can decide.

Do not install system or user-space packages, and do not add new dependencies
to a project's manifest, without asking the user first.
