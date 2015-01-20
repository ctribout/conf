# source local file if relevant
test -f ~/.zshrc.local && source ~/.zshrc.local

autoload -U colors && colors

set_prompt_spe() {
    is_ssh=$1

    is_screen=$2
    is_vim=$3
    has_x=$4

    is_user_root=$5
    user=$6
    hostname=$7

    PROMPT=
    prompt_sfx=
    test ${is_screen} -eq 1 && prompt_sfx="${prompt_sfx}s"
    test ${is_vim} -eq 1 && prompt_sfx="${prompt_sfx}v"
    test ${has_x} -eq 1 && prompt_sfx="${prompt_sfx}x"

    test -n "${prompt_sfx}" && PROMPT="${PROMPT}%{%F{yellow}%}${prompt_sfx}|%{%f%}"

    if [ ${is_user_root} -eq 1 ]; then
        prompt_symb='#'
        PROMPT="${PROMPT}%{%F{red}%}"
    else
        prompt_symb='$'
        PROMPT="${PROMPT}%{%F{green}%}"
    fi
    PROMPT="${PROMPT}%n%{%f%}%{%F{yellow}%}@%{%f%}"
    prompt_hostname="%m"
    test -n "${hostname}" && prompt_hostname=${hostname}
    if [ ${is_ssh} -eq 1 ]; then
        prompt_hostname="%{%F{cyan}%}%B${prompt_hostname}%b%{%f%}"
    else
        prompt_hostname="%{%F{green}%}%B${prompt_hostname}%b%{%f%}"
    fi
    PROMPT="${PROMPT}${prompt_hostname}%{%F{yellow}%}(%h):%b%{%f%}%~%B${prompt_symb}%b "
}

# source common file
test -f ~/.shellrc && source ~/.shellrc
