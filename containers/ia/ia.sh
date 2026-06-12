#!/usr/bin/env bash
set -euo pipefail

# Host env vars to forward into every container (only those actually set on the host).
# Each entry: NAME (forward host $NAME as-is) or HOST:CONTAINER (rename), e.g. a
# read-only token GH_TOKEN_RO:GH_TOKEN sets the container's GH_TOKEN from $GH_TOKEN_RO.
# Per-host additions can be provided via $IA_CONTAINER_FORWARD_ENV (whitespace-
# separated entries with the same syntax), typically set in ~/.shellrc.local
FORWARD_ENV=(
    GH_TOKEN GITHUB_TOKEN GH_HOST
    GITLAB_TOKEN GITLAB_HOST
)
if [ -n "${IA_CONTAINER_FORWARD_ENV:-}" ]; then
    # Intentional word-splitting on whitespace.
    # shellcheck disable=SC2206
    FORWARD_ENV+=(${IA_CONTAINER_FORWARD_ENV})
fi

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
EXTRA_MOUNTS=()

# Dotfiles installed by ../../install.sh are symlinks whose targets live under
# this repo's files/ dir (absolute paths). Mount that dir read-only at its real
# path so those symlinks (e.g. ~/.claude/statusline-command.sh) resolve inside
# the container instead of dangling.
CONF_FILES_DIR=$(readlink -f "$(dirname "$0")/../../files" 2>/dev/null || true)

if WORKSPACE=$(git rev-parse --show-toplevel 2>/dev/null); then
    WORKSPACE=$(readlink -f "$WORKSPACE")
    # In a linked worktree, .git is a file pointing to an absolute path under
    # the main repo's .git directory. That path is outside WORKSPACE, so git
    # inside the container cannot resolve it. Mount the common git dir at the
    # same absolute path so both the per-worktree gitdir (which lives under
    # it) and shared objects/refs/config are reachable.
    if COMMON_GIT_DIR=$(git rev-parse --git-common-dir 2>/dev/null) \
        && [ -n "$COMMON_GIT_DIR" ]; then
        COMMON_GIT_DIR=$(readlink -f "$COMMON_GIT_DIR")
        case "$COMMON_GIT_DIR/" in
            "$WORKSPACE"/*) ;;  # regular repo: .git already inside WORKSPACE
            *) EXTRA_MOUNTS+=("-v" "$COMMON_GIT_DIR:$COMMON_GIT_DIR") ;;
        esac
    fi
else
    WORKSPACE="$PWD"
fi

# Add the read-only files/ mount unless it already lives inside WORKSPACE (in
# which case the workspace mount covers it and we avoid shadowing it read-only).
if [ -n "$CONF_FILES_DIR" ] && [ -d "$CONF_FILES_DIR" ]; then
    case "$CONF_FILES_DIR/" in
        "$WORKSPACE"/*) ;;  # already reachable via the workspace mount
        *) EXTRA_MOUNTS+=("-v" "$CONF_FILES_DIR:$CONF_FILES_DIR:ro") ;;
    esac
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

# --network=host avoids docker bridge NAT/DNS overhead, which on some
# corp networks made API calls ~5x slower than on the host. Trade-off:
# the container shares the host's network namespace (can reach loopback
# services on the host). To override for a one-off run that needs
# isolation or published ports, pass through to docker, e.g.:
#   ia.sh <tool> -- --network=bridge -p 127.0.0.1:3000:3000
docker run --rm -it \
    --network=host \
    --security-opt=no-new-privileges:true \
    --cap-drop=ALL \
    --entrypoint "$ENTRYPOINT" \
    -e HOME=/home/dev \
    -e XDG_CONFIG_HOME=/home/dev/.config \
    -e TERM -e COLORTERM \
    "${COMMON_ENV_FLAGS[@]}" \
    "${ENV_FLAGS[@]}" \
    -v "${WORKSPACE}:${WORKSPACE}" \
    "${EXTRA_MOUNTS[@]}" \
    -w "${LAUNCH_DIR}" \
    "${VOLUME_FLAGS[@]}" \
    "${DOCKER_ARGS[@]}" \
    ia-sandbox \
    "${DEFAULT_AGENT_ARGS[@]}" \
    "${AGENT_ARGS[@]}"
