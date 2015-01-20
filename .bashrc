# source local file if relevant
test -f ~/.bashrc.local && source ~/.bashrc.local

set_prompt_spe() {
    is_ssh=$1

    is_screen=$2
    is_vim=$3
    has_x=$4

    is_user_root=$5
    user=$6
    hostname=$7

    C_NC="\["$(echo -n '\e[0m')"\]" # No Color
    C_BOLD="\["$(echo -n '\e[1m')"\]"
    C_WHITE="\["$(echo -n '\e[1;37m')"\]"
    C_BLACK="\["$(echo -n '\e[0;30m')"\]"
    C_BLUE="\["$(echo -n '\e[0;34m')"\]"
    C_LIGHT_BLUE="\["$(echo -n '\e[1;34m')"\]"
    C_GREEN="\["$(echo -n '\e[0;32m')"\]"
    C_LIGHT_GREEN="\["$(echo -n '\e[1;32m')"\]"
    C_CYAN="\["$(echo -n '\e[0;36m')"\]"
    C_LIGHT_CYAN="\["$(echo -n '\e[1;36m')"\]"
    C_RED="\["$(echo -n '\e[0;31m')"\]"
    C_LIGHT_RED="\["$(echo -n '\e[1;31m')"\]"
    C_PURPLE="\["$(echo -n '\e[0;35m')"\]"
    C_LIGHT_PURPLE="\["$(echo -n '\e[1;35m')"\]"
    C_BROWN="\["$(echo -n '\e[0;33m')"\]"
    C_YELLOW="\["$(echo -n '\e[1;33m')"\]"
    C_GRAY="\["$(echo -n '\e[0;30m')"\]"
    C_LIGHT_GRAY="\["$(echo -n '\e[0;37m')"\]"

    PS1=
    prompt_sfx=
    test ${is_screen} -eq 1 && prompt_sfx="${prompt_sfx}s"
    test ${is_vim} -eq 1 && prompt_sfx="${prompt_sfx}v"
    test ${has_x} -eq 1 && prompt_sfx="${prompt_sfx}x"

    test -n "${prompt_sfx}" && PS1="${PS1}${C_BROWN}${prompt_sfx}|${C_NC}"

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

