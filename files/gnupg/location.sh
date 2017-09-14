#! /bin/sh
if [ ! -e ~/.gnupg ]; then
    mkdir -p ~/.gnupg
    chmod 700 ~/.gnupg
fi
echo ~/.gnupg/
