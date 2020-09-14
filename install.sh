#! /bin/bash

set -e
# set -x
scriptDir=$(dirname "$0" | xargs -i readlink -f "{}")
cd "${scriptDir}"
# Check if files in this folder are present in the user home directory
#  - if yes: backup (move)
# Then, create a symlink to our file

echo "Installing configuration files..."

if [ ! -d ~/.vim/bundle/neobundle.vim ]; then
    ./install_vim_neobundle.sh
fi

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
            mkdir -p ""$(dirname "${target_file}")""
            ln -s "${conf_file_folder}/${conf_file}" "${target_file}"
            echo "  - $(readlink -f "${conf_file_folder}/${conf_file}") installed"
        done < <(cd "${conf_file_folder}" && find . -mindepth 1 -type f -a -not -name "location.sh")
    done
done

if [ ! -d fonts ]; then
    echo "Installing fonts..."
    git clone https://github.com/powerline/fonts
    ./fonts/install.sh
    echo "Done."
fi

if [ ! -d tools/diff-so-fancy ]; then
    git clone https://github.com/so-fancy/diff-so-fancy tools/diff-so-fancy
fi
