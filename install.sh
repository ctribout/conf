#! /bin/sh

set -e
scriptDir=$(dirname $0 | xargs -i readlink -f {})
cd ${scriptDir}
# Check if files in this folder are present in the user home directory
#  - if yes: backup (move)
# Then, create a symlink to our file

echo "Installing configuration files..."

for conf_file_folder in $(find ${scriptDir}/files/ -mindepth 1 -maxdepth 1 -type d); do
    for target_folder in $(${conf_file_folder}/location.sh); do
        for conf_file in $(find ${conf_file_folder} -mindepth 1 -maxdepth 1 -not -name "location.sh"); do
            target_file=${target_folder}/$(basename ${conf_file})
            if [ "$(readlink ${target_file})" = "${conf_file}" ]; then
                # Already installed
                continue
            fi
            if [ -e ${target_file} -o -L ${target_file} ]; then
                # File already exists, save it just in case...
                mv ${target_file} ${target_file}.backup
            fi
            ln -s ${conf_file} ${target_file}
            echo "  - ${conf_file}"
        done
    done
done

if [ ! -d fonts ]; then
    echo "Installing fonts..."
    git clone https://github.com/powerline/fonts
    ./fonts/install.sh
    echo "Done."
fi

