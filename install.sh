#! /bin/sh

set -e
scriptDir=$(dirname $0 | xargs -i readlink -f {})
cd ${scriptDir}
# Check if files in this folder are present in the user home directory
#  - if yes: backup (move)
# Then, create a symlink to our file

echo "Installing configuration files..."
for file in $(find ${scriptDir} -maxdepth 1 -name ".*" \! -name "." \! -name ".git"); do
    origf=~/$(basename ${file})
    if [ "$(readlink ${origf})" = "${file}" ]; then
        continue
    fi
    if [ -e ${origf} ]; then
        mv ${origf} ${origf}.backup
    fi
    ln -s ${file} ${origf}
    echo "  - $(basename ${file})"
done

if [ ! -d fonts ]; then
    echo "Installing fonts..."
    git clone https://github.com/powerline/fonts
    ./fonts/install.sh
    echo "Done."
fi
