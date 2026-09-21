#!/usr/bin/env bash
set -euo pipefail

tool="${IA_TOOL:-claude}"

case "$tool" in
    claude) dir="$HOME/.claude"; init=(rtk init -g) ;;
    codex) dir="$HOME/.codex"; init=(rtk init -g --codex) ;;
    *) exec "$tool" "$@" ;;
esac

ensure_claude_skill_links() {
    local skills_dir="$HOME/.claude/skills"
    local skill target link existing_target

    mkdir -p "$skills_dir"
    for skill in grill-me grilling; do
        target="$HOME/.agents/skills/$skill"
        link="$skills_dir/$skill"

        if [ -L "$link" ]; then
            existing_target="$(readlink -f "$link" 2>/dev/null || true)"
            [ "$existing_target" = "$target" ] && continue
        fi

        if [ -e "$link" ] || [ -L "$link" ]; then
            echo "IA skill link not created: $link already exists" >&2
        else
            ln -s "$target" "$link"
        fi
    done
}

if [ "$tool" = claude ]; then
    ensure_claude_skill_links
fi

# ~/.claude and ~/.codex are bind-mounted from the host (see ia.sh) and persist
# across containers. Regenerate rtk's global config only when RTK.md is missing
# or the image's rtk version changed since it was last written, so a rebuilt
# image refreshes RTK.md without paying the cost on every start. Run it
# non-interactively and never let a failure block the agent from launching.
stamp="$dir/.rtk-version"
version="$(rtk --version 2>/dev/null || true)"
prev=""
[ -e "$stamp" ] && prev="$(<"$stamp")"

if [ ! -e "$dir/RTK.md" ] || [ "$prev" != "$version" ]; then
    if "${init[@]}" </dev/null >/dev/null; then
        printf '%s\n' "$version" >"$stamp"
    else
        echo "rtk init failed; continuing" >&2
    fi
fi

exec "$tool" "$@"
