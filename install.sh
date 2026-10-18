#! /bin/bash
set -euo pipefail

scriptDir=$(dirname "$(readlink -f "$0")")
cd "${scriptDir}"

all_yes=0
update=0
temp_dirs=()

cleanup() {
    local dir
    for dir in "${temp_dirs[@]}"; do
        rm -rf -- "${dir}"
    done
}
trap cleanup EXIT

usage() {
    cat << EOF
Usage: $(basename "$0") [--help] [--yes] [--update]

  --help: this inline help
  --yes: answer yes to all prompts
  --update: update existing tools and install missing ones
EOF
    exit "${1:-0}"
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
            --update)
                update=1
                ;;
            *)
                echo "Invalid parameter '${param}'"
                usage 1
                ;;
        esac
    done
}

download_file() {
    local url=$1
    local destination=$2

    if command -v curl >/dev/null 2>&1; then
        curl --proto '=https' --tlsv1.2 -fLsS --output "${destination}" "${url}"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "${destination}" "${url}"
    else
        echo "Couldn't download ${url}: please install curl or wget" >&2
        return 1
    fi
}

new_temp_dir() {
    temp_dir=$(mktemp -d "${1:-${TMPDIR:-/tmp}/conf-install.XXXXXX}")
    temp_dirs+=("${temp_dir}")
}

yes_no() {
    if [ ${all_yes} -ne 0 ]; then return 0; fi
    local answer="Y"
    local question="$1"
    local default="$2"
    if [ "${default}" = "N" ]; then
        read -rp "${question} [y/N] " answer
    elif [ "${default}" = "Y" ]; then
        read -rp "${question} [Y/n] " answer
    else
        echo "invalid default value"
        exit 1
    fi
    if [ -z "${answer}" ]; then answer="${default}"; fi
    if [ "${answer}" = "Y" ] || [ "${answer}" = "y" ]; then
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
    while IFS= read -r conf_file_folder; do
        if [ ! -e "${conf_file_folder}/location.sh" ]; then
            continue
        fi
        for target_folder in $("${conf_file_folder}"/location.sh); do
            while IFS= read -r conf_file; do
                target_file=${target_folder}/${conf_file}
                if [ "$(readlink -f "${target_file}")" = "$(readlink -f "${conf_file_folder}/${conf_file}")" ]; then
                    # Already installed
                    # echo "  - $(readlink -f "${conf_file_folder}/${conf_file}") already installed"
                    continue
                fi
                if [ -e "${target_file}" ] || [ -L "${target_file}" ]; then
                    # File already exists, save it just in case...
                    mv "${target_file}" "${target_file}.backup"
                fi
                mkdir -p "$(dirname "${target_file}")"
                ln -s "${conf_file_folder}/${conf_file}" "${target_file}"
                echo "  - $(readlink -f "${conf_file_folder}/${conf_file}") installed"
            done < <(cd "${conf_file_folder}" && find . -mindepth 1 \( -type f -o -type l \) -a -not -name "location.sh")
        done
    done < <(find "${scriptDir}/files/" -mindepth 1 -maxdepth 1 -type d)

    chmod 700 "${HOME}/.ssh"
    chmod 600 "${scriptDir}/files/dotfiles/.ssh/config"
    install_neovim_conf
    echo "Installed configuration files."
}

install_neovim_conf() {
    local target=~/.config/nvim
    local source=${scriptDir}/files/neovim

    if [ -L "${target}" ] && [ "$(readlink -f "${target}")" = "${source}" ]; then
        return 0
    fi
    if [ -e "${target}" ] || [ -L "${target}" ]; then
        if [ -e "${target}.backup" ] || [ -L "${target}.backup" ]; then
            echo "Cannot back up ${target}: ${target}.backup already exists" >&2
            return 1
        fi
        mv "${target}" "${target}.backup"
    fi
    mkdir -p "$(dirname "${target}")"
    ln -s "${source}" "${target}"
    echo "  - ${source} installed"
}

install_neovim() {
    local url=https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
    local target_exe=~/.local/bin/nvim
    local fallback_exe=~/.local/bin/vim
    local app_folder=~/.local/app/nvim-linux-x86_64
    local old_folder

    if [ -e "${target_exe}" ] || [ -L "${target_exe}" ]; then
        if [ ${update} -eq 0 ]; then return 0; fi
        if [ "$(readlink -f "${target_exe}")" != "${app_folder}/bin/nvim" ]; then
            echo "Skipping Neovim update: ${target_exe} is not managed by this script"
            return 0
        fi
    fi
    if ! yes_no "Install neovim?" "Y"; then return 0; fi

    echo "Installing neovim..."
    mkdir -p "$(dirname "${app_folder}")" "$(dirname "${target_exe}")"
    new_temp_dir "$(dirname "${app_folder}")/.nvim-install.XXXXXX"
    download_file "${url}" "${temp_dir}/nvim.tar.gz"
    tar -xzf "${temp_dir}/nvim.tar.gz" -C "${temp_dir}"
    test -x "${temp_dir}/nvim-linux-x86_64/bin/nvim"
    if [ -e "${target_exe}" ] && [ -f "${app_folder}/bin/nvim" ] && cmp -s "${temp_dir}/nvim-linux-x86_64/bin/nvim" "${app_folder}/bin/nvim"; then
        echo "Neovim is already up to date."
        return 0
    fi

    if [ -e "${app_folder}" ]; then
        old_folder=${temp_dir}/old-nvim
        mv "${app_folder}" "${old_folder}"
    fi
    if ! mv "${temp_dir}/nvim-linux-x86_64" "${app_folder}"; then
        if [ -n "${old_folder:-}" ]; then
            mv "${old_folder}" "${app_folder}"
        fi
        return 1
    fi
    if [ ! -e "${target_exe}" ] && [ ! -L "${target_exe}" ]; then
        ln -s "${app_folder}/bin/nvim" "${target_exe}"
    fi
    if [ ! -e "${fallback_exe}" ] && [ ! -L "${fallback_exe}" ]; then
        ln -s "nvim" "${fallback_exe}"
    fi

    echo "Installed neovim."
}

install_tree_sitter() {
    local url=https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz
    local target_exe=~/.local/bin/tree-sitter

    if [ -L "${target_exe}" ]; then
        echo "Skipping tree-sitter: ${target_exe} is managed elsewhere"
        return 0
    fi
    if [ ${update} -eq 0 ] && [ -e "${target_exe}" ]; then return 0; fi
    if ! yes_no "Install tree-sitter CLI (builds nvim treesitter parsers)?" "Y"; then return 0; fi

    echo "Installing tree-sitter CLI..."
    mkdir -p "$(dirname "${target_exe}")"
    new_temp_dir
    download_file "${url}" "${temp_dir}/tree-sitter.gz"
    gunzip -c "${temp_dir}/tree-sitter.gz" > "${temp_dir}/tree-sitter"
    if [ -f "${target_exe}" ] && cmp -s "${temp_dir}/tree-sitter" "${target_exe}"; then
        echo "tree-sitter is already up to date."
        return 0
    fi
    chmod +x "${temp_dir}/tree-sitter"
    mv -f "${temp_dir}/tree-sitter" "${target_exe}"
    echo "Installed tree-sitter CLI."
}

install_starship() {
    local url=https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz
    local target_exe=~/.local/bin/starship

    if [ -L "${target_exe}" ]; then
        echo "Skipping Starship: ${target_exe} is managed elsewhere"
        return 0
    fi
    if [ ${update} -eq 0 ] && [ -e "${target_exe}" ]; then return 0; fi
    if ! yes_no "Install starship?" "Y"; then return 0; fi

    echo "Installing starship..."
    mkdir -p "$(dirname "${target_exe}")"
    new_temp_dir
    download_file "${url}" "${temp_dir}/starship.tar.gz"
    tar -xzf "${temp_dir}/starship.tar.gz" -C "${temp_dir}" starship
    if [ -f "${target_exe}" ] && cmp -s "${temp_dir}/starship" "${target_exe}"; then
        echo "Starship is already up to date."
        return 0
    fi
    mv -f "${temp_dir}/starship" "${target_exe}"
    echo "Installed starship."
}

install_fonts() {
    local my_font=~/.local/share/fonts/LiterationMonoNerdFont-Regular.ttf
    local target=${scriptDir}/files/fonts/LiterationMonoNerdFont-Regular.ttf

    if [ -L "${my_font}" ]; then
        echo "Skipping font: ${my_font} is managed elsewhere"
        return 0
    fi
    if [ -e "${my_font}" ]; then
        if [ ${update} -eq 0 ] || cmp -s "${target}" "${my_font}"; then return 0; fi
    fi
    if ! yes_no "Install Nerd font?" "Y"; then return 0; fi

    echo "Installing fonts..."
    mkdir -p "$(dirname "${my_font}")"
    cp -f "${target}" "${my_font}"

    if command -v fc-cache >/dev/null 2>&1; then
        echo "Resetting font cache, this may take a moment..."
        fc-cache -f "$(dirname "${my_font}")"
    fi
    echo "Installed fonts."
}

install_diff_so_fancy() {
    local install_path="${scriptDir}/tools/diff-so-fancy"

    if [ -d "${install_path}" ]; then
        if [ ${update} -eq 0 ]; then return 0; fi
        if [ ! -d "${install_path}/.git" ]; then
            echo "Skipping diff-so-fancy update: ${install_path} is not a Git checkout" >&2
            return 0
        fi
        if ! yes_no "Update diff-so-fancy?" "Y"; then return 0; fi
        git -C "${install_path}" pull --ff-only
        return 0
    fi
    if ! yes_no "Install diff-so-fancy?" "Y"; then return 0; fi

    echo "Installing diff-so-fancy..."
    git clone --quiet https://github.com/so-fancy/diff-so-fancy "${install_path}"
    echo "Installed diff-so-fancy."
}

install_rust_tools() {
    local rustup_path=~/.cargo/bin/rustup

    if [ -e "${rustup_path}" ]; then
        if [ ${update} -eq 0 ]; then return 0; fi
        if ! yes_no "Update Rust tools?" "Y"; then return 0; fi
        echo "Updating rust tools..."
        "${rustup_path}" update
        echo "Updated rust tools."
        return 0
    fi
    if ! yes_no "Install rust tools?" "N"; then return 0; fi

    echo "Installing rust tools..."
    new_temp_dir
    download_file https://sh.rustup.rs "${temp_dir}/rustup-init.sh"
    sh "${temp_dir}/rustup-init.sh" --quiet --no-modify-path -y
    echo "Installed rust tools."
}

install_latex_tools() {
    local texlab_path=~/.local/bin/texlab

    if [ -L "${texlab_path}" ]; then
        echo "Skipping texlab: ${texlab_path} is managed elsewhere"
        return 0
    fi
    if [ ${update} -eq 0 ] && [ -e "${texlab_path}" ]; then return 0; fi
    if [ -e "${texlab_path}" ]; then
        if ! yes_no "Update LaTeX tools?" "Y"; then return 0; fi
    elif ! yes_no "Install LaTeX tools?" "N"; then
        return 0
    fi

    echo "Installing LaTeX tools..."
    mkdir -p "$(dirname "${texlab_path}")"
    new_temp_dir
    download_file https://github.com/latex-lsp/texlab/releases/latest/download/texlab-x86_64-linux.tar.gz "${temp_dir}/texlab.tar.gz"
    tar -xzf "${temp_dir}/texlab.tar.gz" -C "${temp_dir}" texlab
    if [ -f "${texlab_path}" ] && cmp -s "${temp_dir}/texlab" "${texlab_path}"; then
        echo "texlab is already up to date."
        return 0
    fi
    mv -f "${temp_dir}/texlab" "${texlab_path}"
    echo "Installed LaTeX tools."
}

nodejs_top_folder=~/.nodejs
npm_bin_folder="${nodejs_top_folder}/bin"
npm_path="${npm_bin_folder}/npm"

install_nodejs() {
    local releases=https://nodejs.org/dist/latest-v24.x
    local archive checksum_line version

    if [ -L "${nodejs_top_folder}" ]; then
        echo "Skipping Node.js: ${nodejs_top_folder} is managed elsewhere"
        return 0
    fi
    if [ -e "${npm_path}" ]; then
        if [ ${update} -eq 0 ]; then return 0; fi
        if ! yes_no "Update Node.js?" "Y"; then return 0; fi
    elif ! yes_no "Install Node.js?" "N"; then
        return 0
    fi

    new_temp_dir
    download_file "${releases}/SHASUMS256.txt" "${temp_dir}/SHASUMS256.txt"
    archive=$(awk '$2 ~ /^node-v24[.][0-9]+[.][0-9]+-linux-x64[.]tar[.]xz$/ { print $2; exit }' "${temp_dir}/SHASUMS256.txt")
    if [ -z "${archive}" ]; then
        echo "Could not find a Linux x64 Node.js archive" >&2
        return 1
    fi
    version=${archive#node-}
    version=${version%-linux-x64.tar.xz}
    if [ -x "${npm_bin_folder}/node" ] && [ "$("${npm_bin_folder}/node" --version)" = "${version}" ]; then
        echo "Node.js ${version} is already installed."
        return 0
    fi

    echo "Installing Node.js ${version}..."
    download_file "${releases}/${archive}" "${temp_dir}/${archive}"
    checksum_line=$(awk -v name="${archive}" '$2 == name { print; exit }' "${temp_dir}/SHASUMS256.txt")
    printf '%s\n' "${checksum_line}" | (cd "${temp_dir}" && sha256sum -c --status)
    mkdir "${temp_dir}/extracted"
    tar -xJf "${temp_dir}/${archive}" --strip-components=1 -C "${temp_dir}/extracted"
    mkdir -p "${nodejs_top_folder}"
    cp -a "${temp_dir}/extracted/." "${nodejs_top_folder}/"
    echo "Installed Node.js ${version}."
}

install_apt_packages() {
    if ! yes_no "Install common apt packages (xclip, fd-find, ripgrep, fzf; requires sudo)?" "N"; then return 0; fi

    echo "Installing apt packages"
    sudo apt update
    sudo apt install -y xclip fd-find ripgrep fzf
    echo "Installed apt packages."
}

parse_command_line "$@"

install_conf_files
install_neovim
install_tree_sitter
install_starship
install_fonts
install_diff_so_fancy
install_rust_tools
install_latex_tools
install_nodejs
install_apt_packages
