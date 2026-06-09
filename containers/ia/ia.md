# Copilot CLI

The settings file can't be managed as a dotfile like other files in this repo: the
symlink is lost after each modification done by the app.

## Custom status line

in `~/.copilot/settings.json` add the statusLine entry (type "command") below:

```json
{
  "footer": { "showCustom": true },
  "statusLine": {
    "type": "command",
    "command": "printf '%s@%s%s' \"$(id -un)\" \"$(hostname -s)\" \"$( [ -f /.dockerenv ] || [ -f /run/.containerenv ] || grep -qaE '(docker|containerd|kubepods|lxc)' /proc/1/cgroup 2>/dev/null && printf ' 🐳' )\""
  }
}
```

It shows `user@host` + 🐳 when inside a container.
