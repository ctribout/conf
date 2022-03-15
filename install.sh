#! /bin/bash

set -e
# set -x
scriptDir=$(dirname "$0" | xargs -i readlink -f "{}")
cd "${scriptDir}"
# Check if files in this folder are present in the user home directory
#  - if yes: backup (move)
# Then, create a symlink to our file

echo "Installing configuration files..."

./install_vim_plugin_manager.sh

for conf_file_folder in $(find "${scriptDir}/files/" -mindepth 1 -maxdepth 1 -type d); do
    for target_folder in $(${conf_file_folder}/location.sh); do
        while IFS= read -r conf_file; do
            target_file=${target_folder}/${conf_file}
            if [ ""$(readlink -f "${target_file}")"" = ""$(readlink -f "${conf_file_folder}/${conf_file}")"" ]; then
                # Already installed
                echo "  - $(readlink -f "${conf_file_folder}/${conf_file}") already installed"
                continue
            fi
            if [ -e "${target_file}" -o -L "${target_file}" ]; then
                # File already exists, save it just in case...
                mv "${target_file}" "${target_file}.backup"
            fi
            mkdir -p "$(dirname "${target_file}")"
            ln -s "${conf_file_folder}/${conf_file}" "${target_file}"
            echo "  - $(readlink -f "${conf_file_folder}/${conf_file}") installed"
        done < <(cd "${conf_file_folder}" && find . -mindepth 1 -type f -a -not -name "location.sh")
    done
done

fonts_dir=~/.local/share/fonts/
my_font=${fonts_dir}/LiterationMonoNerdFontComplete.ttf
if [ ! -e "${my_font}" ]; then
    echo "Installing fonts..."
    mkdir -p ~/.local/share/fonts
    set -x
    curl --silent "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/LiberationMono/complete/Literation%20Mono%20Nerd%20Font%20Complete.ttf" > "${my_font}"
    if which fc-cache >/dev/null 2>&1; then
        echo "Resetting font cache, this may take a moment..."
        fc-cache -f ~/.local/share/fonts
    fi
    echo "Done."
fi

if [ ! -d tools/diff-so-fancy ]; then
    git clone https://github.com/so-fancy/diff-so-fancy tools/diff-so-fancy
fi
