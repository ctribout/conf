#!/usr/bin/env bash
set -euo pipefail

# Host env vars to forward into every container (only those actually set on the host).
# Each entry: NAME (forward host $NAME as-is) or HOST:CONTAINER (rename), e.g. a
# read-only token GH_TOKEN_RO:GH_TOKEN sets the container's GH_TOKEN from $GH_TOKEN_RO.
FORWARD_ENV=(
    GH_TOKEN GITHUB_TOKEN GH_HOST
    GITLAB_TOKEN GITLAB_HOST
)

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
        DEFAULT_AGENT_ARGS=(--allow-dangerously-skip-permissions)
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

LAUNCH_DIR="$PWD"
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

COMMON_ENV_FLAGS=()
for spec in "${FORWARD_ENV[@]}"; do
    host_var="${spec%%:*}"           # before ':' (or whole entry if no ':')
    cont_var="${spec##*:}"           # after ':'  (or whole entry if no ':')
    if [ -n "${!host_var:-}" ]; then
        # re-export under the container's name so the value never lands in argv (ps-safe)
        export "${cont_var}=${!host_var}"
        COMMON_ENV_FLAGS+=("-e" "$cont_var")
    fi
done

docker run --rm -it \
    --security-opt=no-new-privileges:true \
    --cap-drop=ALL \
    --entrypoint "$ENTRYPOINT" \
    -e HOME=/home/dev \
    -e XDG_CONFIG_HOME=/home/dev/.config \
    -e TERM -e COLORTERM \
    "${COMMON_ENV_FLAGS[@]}" \
    "${ENV_FLAGS[@]}" \
    -v "${WORKSPACE}:${WORKSPACE}" \
    -w "${LAUNCH_DIR}" \
    "${VOLUME_FLAGS[@]}" \
    "${DOCKER_ARGS[@]}" \
    ia-sandbox \
    "${DEFAULT_AGENT_ARGS[@]}" \
    "${AGENT_ARGS[@]}"
