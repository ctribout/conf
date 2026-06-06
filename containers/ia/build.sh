#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

CLEAN=false
REINSTALL_AGENTS=false
for arg in "$@"; do
    case "$arg" in
        -c|--clean)             CLEAN=true ;;
        -r|--reinstall-agents)  REINSTALL_AGENTS=true ;;
        *) echo "Usage: $(basename "$0") [-c|--clean] [-r|--reinstall-agents]" >&2; exit 1 ;;
    esac
done

NPM_CACHEBUST=stable
if [ "$REINSTALL_AGENTS" = true ]; then
    NPM_CACHEBUST="$(date +%s)"
fi

docker build \
    --build-arg UID="$(id -u)" \
    --build-arg GID="$(id -g)" \
    --build-arg NPM_CACHEBUST="$NPM_CACHEBUST" \
    -t ia-sandbox \
    .
docker image prune -f

if [ "$CLEAN" = true ]; then
    docker builder prune -f
fi
