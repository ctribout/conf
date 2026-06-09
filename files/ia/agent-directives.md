# Tool usage

Prefer purpose-built operations over shelling out. When dedicated tools are
available for reading, finding, searching, and editing files, use them rather than
their shell equivalents (`cat`, `ls`, `find`, `grep`, `sed`, or `for … cat` loops).

Reach for the shell only when it is genuinely the right tool: running builds, tests,
`git`, package managers, or real text-processing pipelines (transform/aggregate)
that the dedicated tools can't express. Don't use the shell as a shortcut for plain
file reading or searching.

# Secrets

Treat tokens and credentials as sensitive: never echo or print their values, never
write them to files or logs, and refer to them by variable name. Redact values that
would otherwise appear in output.
