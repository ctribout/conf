#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") <claude|codex|copilot> [agent args...] [-- docker run args...]" >&2
    exit 1
}

[ $# -lt 1 ] && usage

TOOL="$1"; shift
ENV_FLAGS=()
DEFAULT_AGENT_ARGS=()

case "$TOOL" in
    claude)
        ENTRYPOINT="claude"
        VOLUME_FLAGS=(
            "-v" "${HOME}/.claude:/home/dev/.claude"
            "-v" "${HOME}/.claude.json:/home/dev/.claude.json"
        )
        CONFIG_DIRS=("${HOME}/.claude")
        ;;
    codex)
        ENTRYPOINT="codex"
        VOLUME_FLAGS=("-v" "${HOME}/.codex:/home/dev/.codex")
        CONFIG_DIRS=("${HOME}/.codex")
        ;;
    copilot)
        ENTRYPOINT="copilot"
        DEFAULT_AGENT_ARGS=(--no-mouse)
        VOLUME_FLAGS=(
            "-v" "${HOME}/.config/github-copilot:/home/dev/.config/github-copilot"
            "-v" "${HOME}/.copilot:/home/dev/.copilot"
        )
        CONFIG_DIRS=("${HOME}/.config/github-copilot" "${HOME}/.copilot")
        ENV_FLAGS=("-e" "GH_TOKEN")
        ;;
    *)
        usage
        ;;
esac

if WORKSPACE=$(git rev-parse --show-toplevel 2>/dev/null); then
    :
else
    WORKSPACE="$PWD"
fi

for dir in "${CONFIG_DIRS[@]}"; do
    mkdir -p "$dir"
done
[ "$TOOL" = "claude" ] && touch "${HOME}/.claude.json"

DOCKER_ARGS=()
AGENT_ARGS=()
sep=false
for arg in "$@"; do
    if [ "$arg" = "--" ]; then sep=true
    elif [ "$sep" = true ]; then DOCKER_ARGS+=("$arg")
    else AGENT_ARGS+=("$arg")
    fi
done

docker run --rm -it \
    --entrypoint "$ENTRYPOINT" \
    -e HOME=/home/dev \
    -e XDG_CONFIG_HOME=/home/dev/.config \
    "${ENV_FLAGS[@]}" \
    -v "${WORKSPACE}:/workspace" \
    "${VOLUME_FLAGS[@]}" \
    "${DOCKER_ARGS[@]}" \
    ia-sandbox \
    "${DEFAULT_AGENT_ARGS[@]}" \
    "${AGENT_ARGS[@]}"
