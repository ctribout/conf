# source local file if relevant
bindkey -e # emacs-keymap, "fixes" tmux bindings and commands history navigation
test -f ~/.zshrc.local && source ~/.zshrc.local

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt NO_HIST_BEEP

autoload -U colors && colors

set_prompt_spe() {
    local is_ssh=$1
    local is_container=$2

    local is_screen=$3
    local is_vim=$4
    local has_x=$5

    local is_user_root=$6
    local user=$7
    local hostname=$8

    local prompt_sfx=
    local prompt_symb=
    local prompt_hostname=
    local prompt_username=

    PROMPT=

    test ${is_vim} -eq 1 && prompt_sfx="${prompt_sfx}%B%{%F{red}%}v%b%{%f%}"
    test ${is_screen} -eq 1 && prompt_sfx="${prompt_sfx}%{%F{yellow}%}s%{%f%}"
    test ${has_x} -eq 1 && prompt_sfx="${prompt_sfx}%{%F{yellow}%}x%{%f%}"

    test -n "${prompt_sfx}" && PROMPT="${PROMPT}${prompt_sfx}%{%F{yellow}%}|%{%f%}"

    if [ ${is_user_root} -eq 1 ]; then
        prompt_symb='#'
        PROMPT="${PROMPT}%{%F{red}%}"
    else
        prompt_symb='$'
        PROMPT="${PROMPT}%{%F{green}%}"
    fi
    prompt_username="${user}"
    test -z "${prompt_username}" && prompt_username="%f"
    PROMPT="${PROMPT}${prompt_username}%{%f%}%{%F{yellow}%}@%{%f%}"
    prompt_hostname="%m"
    test -n "${hostname}" && prompt_hostname=${hostname}
    if [ ${is_ssh} -eq 1 -o ${is_container} -eq 1 ]; then
        prompt_hostname="%{%F{cyan}%}%B${prompt_hostname}%b%{%f%}"
    else
        prompt_hostname="%{%F{green}%}%B${prompt_hostname}%b%{%f%}"
    fi
    PROMPT="${PROMPT}${prompt_hostname}%{%F{yellow}%}(%h):%b%{%f%}%~%B${prompt_symb}%b "
}

# source common file
test -f ~/.shellrc && source ~/.shellrc

if [ -n "${TMUX}" ]; then
    preexec () {
      refresh
    }
fi

# Initialize starship prompt
which starship &> /dev/null && eval "$(starship init zsh)"
