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
    five_pct=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
    five_reset=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
    week_pct=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
    week_reset=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
else
    cwd=""
    model=""
    used=""
    five_pct=""
    week_pct=""
fi

# Fall back to shell cwd if JSON gave nothing
[ -z "$cwd" ] && cwd="$PWD"

# Shorten home directory to ~
short_cwd="${cwd/#$HOME/\~}"

# ANSI color helpers
green='\033[0;32m'
bold_green='\033[1;32m'
yellow='\033[1;33m'
red='\033[0;31m'
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

# Format seconds-until-reset as a short duration: Xd Yh, Xh Ym, or Xm
format_remaining() {
    local secs=$1
    [ "$secs" -lt 0 ] && secs=0
    local days=$((secs / 86400))
    local hours=$(((secs % 86400) / 3600))
    local mins=$(((secs % 3600) / 60))
    if [ "$days" -gt 0 ]; then
        printf "%dd%dh" "$days" "$hours"
    elif [ "$hours" -gt 0 ]; then
        printf "%dh%dm" "$hours" "$mins"
    else
        printf "%dm" "$mins"
    fi
}

# Color a usage percentage by severity: green <50%, yellow <85%, red >=85%
color_for_pct() {
    local int_pct=${1%.*}
    if [ "$int_pct" -ge 85 ]; then
        printf '%s' "$red"
    elif [ "$int_pct" -ge 50 ]; then
        printf '%s' "$yellow"
    else
        printf '%s' "$green"
    fi
}

# Rate limit usage — 5h and weekly windows, shown as remaining-time:used% (Pro/Max only)
rate_info=""
if [ -n "$five_pct" ] && [ -n "$week_pct" ]; then
    now=$(date +%s)
    five_str=$(format_remaining $((five_reset - now)))
    week_str=$(format_remaining $((week_reset - now)))
    five_color=$(color_for_pct "$five_pct")
    week_color=$(color_for_pct "$week_pct")
    rate_info=$(printf " [${five_color}%s:%.0f%%${reset}|${week_color}%s:%.0f%%${reset}]" \
        "$five_str" "$five_pct" "$week_str" "$week_pct")
fi

# Container indicator — shown only when running inside a container
container_info=""
if [ -f /.dockerenv ] || [ -f /run/.containerenv ] \
    || grep -qaE '(docker|containerd|kubepods|lxc)' /proc/1/cgroup 2>/dev/null; then
    container_info=" 🐳"
fi

printf "${green}%s${reset}${yellow}@${reset}${bold_green}%s${reset}${yellow}:${reset}%s%s%s%s%s%s\n" \
    "$user" "$host" "$short_cwd" "$git_info" "$model_info" "$ctx_info" "$rate_info" "$container_info"
