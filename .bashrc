# source local file if relevant
test -f ~/.bashrc.local && source ~/.bashrc.local

set_prompt_spe() {
    local is_ssh=$1

    local is_screen=$2
    local is_vim=$3
    local has_x=$4

    local is_user_root=$5
    local user=$6
    local hostname=$7

    local C_NC="\["$(echo -n '\e[0m')"\]" # No Color
    local C_BOLD="\["$(echo -n '\e[1m')"\]"
    local C_WHITE="\["$(echo -n '\e[1;37m')"\]"
    local C_BLACK="\["$(echo -n '\e[0;30m')"\]"
    local C_BLUE="\["$(echo -n '\e[0;34m')"\]"
    local C_LIGHT_BLUE="\["$(echo -n '\e[1;34m')"\]"
    local C_GREEN="\["$(echo -n '\e[0;32m')"\]"
    local C_LIGHT_GREEN="\["$(echo -n '\e[1;32m')"\]"
    local C_CYAN="\["$(echo -n '\e[0;36m')"\]"
    local C_LIGHT_CYAN="\["$(echo -n '\e[1;36m')"\]"
    local C_RED="\["$(echo -n '\e[0;31m')"\]"
    local C_LIGHT_RED="\["$(echo -n '\e[1;31m')"\]"
    local C_PURPLE="\["$(echo -n '\e[0;35m')"\]"
    local C_LIGHT_PURPLE="\["$(echo -n '\e[1;35m')"\]"
    local C_BROWN="\["$(echo -n '\e[0;33m')"\]"
    local C_YELLOW="\["$(echo -n '\e[1;33m')"\]"
    local C_GRAY="\["$(echo -n '\e[0;30m')"\]"
    local C_LIGHT_GRAY="\["$(echo -n '\e[0;37m')"\]"

    local prompt_sfx=
    local prompt_symb=
    local prompt_hostname=

    PS1=

    test ${is_vim} -eq 1 && prompt_sfx="${prompt_sfx}${C_LIGHT_RED}v${C_NC}"
    test ${is_screen} -eq 1 && prompt_sfx="${prompt_sfx}${C_BROWN}s${C_NC}"
    test ${has_x} -eq 1 && prompt_sfx="${prompt_sfx}${C_BROWN}x${C_NC}"
    test -n "${prompt_sfx}" && PS1="${PS1}${prompt_sfx}${C_BROWN}|${C_NC}"

    if [ ${is_user_root} -eq 1 ]; then
        prompt_symb='#'
        PS1="${PS1}${C_RED}"
    else
        prompt_symb='$'
        PS1="${PS1}${C_GREEN}"
    fi
    PS1="${PS1}${user}${C_NC}${C_BROWN}@${C_NC}"
    if [ ${is_ssh} -eq 1 ]; then
        prompt_hostname="${C_LIGHT_CYAN}${hostname}${C_NC}"
    else
        prompt_hostname="${C_LIGHT_GREEN}${hostname}${C_NC}"
    fi
    PS1="${PS1}${prompt_hostname}${C_BROWN}"
    PS1=${PS1}"(\!):${C_NC}"'$(pwd | sed "s:^${HOME}/\?:~/:" | sed "s:/$::")'"${C_BOLD}${prompt_symb}${C_NC} "
}

# source common file
source ~/.shellrc

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

