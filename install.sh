#! /bin/bash
set -euo pipefail

scriptDir=$(dirname "$0" | xargs -i readlink -f "{}")
cd "${scriptDir}"

all_yes=0
force_reinstall=0

usage() {
    cat << EOF
Usage: $(basename "$0") [--help] [--yes] [--reinstall]

  --help: this inline help
  --yes: don't ask for installation and consider all answers to questions are "yes"
  --reinstall: force the full reinstallation of elements if already installed
EOF
    exit 1
}

parse_command_line() {
    for param in "$@"; do
        case "${param}" in
            --help|-h)
                usage
                ;;
            --yes)
                all_yes=1
                ;;
            --reinstall)
                force_reinstall=1
                ;;
            *)
                echo "Invalid parameter '${param}'"
                usage
                ;;
        esac
    done
}


yes_no() {
    if [ ${all_yes} -ne 0 ]; then return 0; fi
    local answer="Y"
    local question="$1"
    local default="$2"
    if [ "${default}" = "N" ]; then
        read -p "${question} [y/N] " answer
    elif [ "${default}" = "Y" ]; then
        read -p "${question} [Y/n] " answer
    else
        echo "invalid default value"
        exit 1
    fi
    if [ -z "${answer}" ]; then answer="${default}"; fi
    if [ "${answer}" = "Y" -o "${answer}" = "y" ]; then
        return 0
    fi
    return 1
}

install_conf_files() {
    if ! yes_no "Install configuration/dot files?" "Y"; then return 0; fi

    echo "Installing configuration files..."

    # Check if files in this folder are present in the user home directory
    #  - if yes: backup (move)
    # Then, create a symlink to our file
    for conf_file_folder in $(find "${scriptDir}/files/" -mindepth 1 -maxdepth 1 -type d); do
        if [ ! -e "${conf_file_folder}/location.sh" ]; then
            continue
        fi
        for target_folder in $(${conf_file_folder}/location.sh); do
            while IFS= read -r conf_file; do
                target_file=${target_folder}/${conf_file}
                if [ "$(readlink -f "${target_file}")" = "$(readlink -f "${conf_file_folder}/${conf_file}")" ]; then
                    # Already installed
                    # echo "  - $(readlink -f "${conf_file_folder}/${conf_file}") already installed"
                    continue
                fi
                if [ -e "${target_file}" -o -L "${target_file}" ]; then
                    # File already exists, save it just in case...
                    mv "${target_file}" "${target_file}.backup"
                fi
                mkdir -p "$(dirname "${target_file}")"
                ln -s "${conf_file_folder}/${conf_file}" "${target_file}"
                echo "  - $(readlink -f "${conf_file_folder}/${conf_file}") installed"
            done < <(cd "${conf_file_folder}" && find . -mindepth 1 \( -type f -o -type l \) -a -not -name "location.sh")
        done
    done

    echo "Installed configuration files."
}

install_neovim() {
    local url=https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
    local target_exe=~/.local/bin/nvim
    local fallback_exe=~/.local/bin/vim
    local app_folder=~/.local/app/nvim-linux-x86_64
    local target_conf_folder=~/.config/nvim

    if [ ${force_reinstall} -eq 0 -a -e "${target_exe}" ]; then return 0; fi
    if ! yes_no "Install neovim?" "Y"; then return 0; fi
    if [ ${force_reinstall} -ne 0 ]; then
        rm -rf "${app_folder}" "${target_exe}" "${fallback_exe}"
    fi

    echo "Installing neovim..."

    mkdir -p "$(dirname "${app_folder}")" "$(dirname "${target_exe}")"

    if type curl 2>&1 1>/dev/null; then
        curl --proto '=https' --tlsv1.2 -LsSf "${url}" | tar -zxC "$(dirname "${app_folder}")"
    elif type wget 2>&1 1>/dev/null; then
        wget -qO - "${url}" | tar -zxC "$(dirname "${app_folder}")"
    else
        echo "Couldn't download neovim: please install curl or wget"
    fi
    ln -s "${app_folder}/bin/nvim" "${target_exe}"
    ln -s "nvim" "${fallback_exe}"

    if [ -d "${target_conf_folder}" ]; then
        if [ -L "${target_conf_folder}.backup" ]; then
            rm -f "${target_conf_folder}.backup"
        elif [ -d "${target_conf_folder}.backup" ]; then
            rm -rf "${target_conf_folder}.backup"
        fi
        mv "${target_conf_folder}" "${target_conf_folder}.backup"
    fi
    ln -sf "${scriptDir}/files/neovim" "${target_conf_folder}"

    echo "Installed neovim."
}

install_starship() {
    local url=https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz
    local target_exe=~/.local/bin/starship

    if [ ${force_reinstall} -eq 0 -a -e "${target_exe}" ]; then return 0; fi
    if ! yes_no "Install starship?" "Y"; then return 0; fi
    if [ ${force_reinstall} -ne 0 ]; then
        rm -rf "${target_exe}"
    fi

    echo "Installing starship..."

    mkdir -p "$(dirname "${target_exe}")"

    if type curl 2>&1 1>/dev/null; then
        curl --proto '=https' --tlsv1.2 -LsSf "${url}" | tar -zxC "$(dirname "${target_exe}")"
    elif type wget 2>&1 1>/dev/null; then
        wget -qO - "${url}" | tar -zxC "$(dirname "${target_exe}")"
    else
        echo "Couldn't download starship: please install curl or wget"
    fi
    echo "Installed starship."
}

install_fonts() {
    local my_font=~/.local/share/fonts/LiterationMonoNerdFont-Regular.ttf
    local target=${scriptDir}/files/fonts/LiterationMonoNerdFont-Regular.ttf

    if [ ${force_reinstall} -eq 0 -a -e "${my_font}" ]; then return 0; fi
    if ! yes_no "Install Nerd font?" "Y"; then return 0; fi

    echo "Installing fonts..."
    mkdir -p "$(dirname "${my_font}")"
    cp -f "${target}" "${my_font}"

    if which fc-cache >/dev/null 2>&1; then
        echo "Resetting font cache, this may take a moment..."
        rm -rf "${scriptDir}/.buildfonts"
        mkdir "${scriptDir}/.buildfonts"
        cd "${scriptDir}/.buildfonts"
        fc-cache -f "$(dirname "${my_font}")"
        cd "${scriptDir}"
        rm -rf "${scriptDir}/.buildfonts"
    fi
    echo "Installed fonts."
}

install_diff_so_fancy() {
    local install_path="${scriptDir}/tools/diff-so-fancy"

    if [ ${force_reinstall} -eq 0 -a -d "${install_path}" ]; then return 0; fi
    if ! yes_no "Install diff-so-fancy?" "Y"; then return 0; fi
    if [ ${force_reinstall} -ne 0 ]; then
        rm -rf "${install_path}"
    fi

    echo "Installing diff-so-fancy..."
    git clone --quiet https://github.com/so-fancy/diff-so-fancy "${install_path}"
    echo "Installed diff-so-fancy."
}

install_python_tools() {
    if ! yes_no "Install Python tools?" "N"; then return 0; fi

    echo "Installing Python tools..."
    pip --quiet install --user --upgrade pip || pip3 --quiet install --user --upgrade pip
    echo "Installed Python tools."
}

install_rust_tools() {
    local rustup_path=~/.cargo/bin/rustup

    if [ ${force_reinstall} -eq 0 -a -e "${rustup_path}" ]; then return 0; fi
    if ! yes_no "Install rust tools?" "N"; then return 0; fi
    if [ ${force_reinstall} -ne 0 ]; then
        rm -rf ~/.cargo
    fi

    if [ -e "${rustup_path}" ]; then
        echo "Updating rust tools..."
        "${rustup_path}" update
        echo "Updated rust tools."
        return 0
    fi

    echo "Installing rust tools..."
    if type curl 2>&1 1>/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --quiet --no-modify-path -y
    elif type wget 2>&1 1>/dev/null; then
        wget -qO - https://sh.rustup.rs | sh -s -- --quiet --no-modify-path -y
    else
        echo "Couldn't download rust installer: please install curl or wget"
    fi
    echo "Installed rust tools."
}

install_latex_tools() {
    local texlab_path=~/.local/bin/texlab

    if [ ${force_reinstall} -eq 0 -a -e "${texlab_path}" ]; then return 0; fi
    if ! yes_no "Install LaTeX tools?" "N"; then return 0; fi
    if [ ${force_reinstall} -ne 0 ]; then
        rm -f "${texlab_path}"
    fi

    echo "Installing LaTeX tools..."
    if type curl 2>&1 1>/dev/null; then
        curl --proto '=https' --tlsv1.2 -LsSf https://github.com/latex-lsp/texlab/releases/latest/download/texlab-x86_64-linux.tar.gz | tar -zxC "$(dirname "${texlab_path}")"
    elif type wget 2>&1 1>/dev/null; then
        wget -qO - https://github.com/latex-lsp/texlab/releases/latest/download/texlab-x86_64-linux.tar.gz | tar -zxC "$(dirname "${texlab_path}")"
    else
        echo "Couldn't download texlab binaries: please install curl or wget"
    fi
    echo "Installed LaTeX tools."
}

nodejs_top_folder=~/.nodejs
npm_bin_folder="${nodejs_top_folder}/bin"
npm_path="${npm_bin_folder}/npm"

install_nodejs() {
    if [ ${force_reinstall} -eq 0 -a -e "${npm_path}" ]; then return 0; fi

    if ! yes_no "Install nodejs tools?" "N"; then return 0; fi
    if [ ${force_reinstall} -ne 0 ]; then
        rm -rf "${nodejs_top_folder}"
    fi

    echo "Installing nodejs tools..."
    mkdir -p "${nodejs_top_folder}"
    if type curl 2>&1 1>/dev/null; then
        curl --proto '=https' --tlsv1.2 -LsSf https://nodejs.org/dist/v24.2.0/node-v24.2.0-linux-x64.tar.xz | tar -JxC "${nodejs_top_folder}"
    elif type wget 2>&1 1>/dev/null; then
        wget -qO - https://nodejs.org/dist/v24.2.0/node-v24.2.0-linux-x64.tar.xz | tar -JxC "${nodejs_top_folder}"
    else
        echo "Couldn't download nodejs binaries: please install curl or wget"
    fi
    mv "${nodejs_top_folder}"/node-*/* "${nodejs_top_folder}"
    rm -rf "${nodejs_top_folder}"/node-*
    "${npm_path}" install --global npm
    echo "Installed nodejs tools."
}

parse_command_line "$@"

install_conf_files
install_neovim
install_starship
install_fonts
install_diff_so_fancy
install_python_tools
install_rust_tools
install_latex_tools
install_nodejs
