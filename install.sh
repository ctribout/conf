#! /bin/sh

set -ex
scriptDir=$(dirname $0 | xargs -i readlink -f {})
# Check if files in this folder are present in the user home directory
#  - if yes: backup (move)
# Then, create a symlink to our file
for file in $(find ${scriptDir} -maxdepth 1 -name ".*" \! -name "." \! -name ".git"); do
    origf=~/$(basename ${file})
    test $(readlink ${origf}) = ${file} && continue
    if [ -e ${origf} ]; then
        mv ${origf} ${origf}.backup
    fi
    ln -s ${file} ${origf}
done

