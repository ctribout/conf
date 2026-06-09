#!/usr/bin/env bash
# Claude Code statusLine command
# Mirrors the starship prompt style: user@host:dir [git] | model | context%

input=$(cat)

user=$(whoami)
host=$(hostname -s)

# Extract fields — fall back gracefully if jq is missing
if command -v jq > /dev/null 2>&1; then
    cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')
    model=$(printf '%s' "$input" | jq -r '.model.display_name // ""')
    used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
else
    cwd=""
    model=""
    used=""
fi

# Fall back to shell cwd if JSON gave nothing
[ -z "$cwd" ] && cwd="$PWD"

# Shorten home directory to ~
short_cwd="${cwd/#$HOME/\~}"

# ANSI color helpers
green='\033[0;32m'
bold_green='\033[1;32m'
yellow='\033[1;33m'
cyan='\033[0;36m'
magenta='\033[0;35m'
orange='\033[0;33m'
reset='\033[0m'

# Git branch (skip optional locks)
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    [ -n "$branch" ] && git_info=$(printf " ${magenta}[%s]${reset}" "$branch")
fi

# Context usage
ctx_info=""
[ -n "$used" ] && ctx_info=$(printf " ${orange}%.0f%%ctx${reset}" "$used")

# Model info
model_info=""
[ -n "$model" ] && model_info=$(printf " ${cyan}%s${reset}" "$model")

# Container indicator — shown only when running inside a container
container_info=""
if [ -f /.dockerenv ] || [ -f /run/.containerenv ] \
    || grep -qaE '(docker|containerd|kubepods|lxc)' /proc/1/cgroup 2>/dev/null; then
    container_info=" 🐳"
fi

printf "${green}%s${reset}${yellow}@${reset}${bold_green}%s${reset}${yellow}:${reset}%s%s%s%s%s\n" \
    "$user" "$host" "$short_cwd" "$git_info" "$model_info" "$ctx_info" "$container_info"
