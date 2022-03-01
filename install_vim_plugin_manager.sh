#! /bin/sh
set -e

type git 2>&1 1>/dev/null || {
  echo 'Please install git or update your PATH to include the git executable'
  exit 1
}

DEIN_REPO=https://github.com/Shougo/dein.vim
PM_DIR=~/.vim/plugin_manager
BUNDLES_DIR=~/.vim/bundles
DEIN_DIR=${PM_DIR}/dein.vim
MARKER_INSTALL_DONE=${PM_DIR}/.installation_ok

if [ -f "${MARKER_INSTALL_DONE}" ]; then
    echo "dein.vim already installed"
    exit 0
fi
if ! type git 2>&1 1> /dev/null; then
    echo "git not available"
    exit 1
fi

rm -rf "${PM_DIR}"
mkdir -p "${PM_DIR}"

git clone "${DEIN_REPO}" "${DEIN_DIR}"

mkdir -p "${BUNDLES_DIR}"

echo "date=$(date) - plugin_manager_hash=$(git -C "${DEIN_DIR}" rev-parse HEAD)" > "${MARKER_INSTALL_DONE}"
echo "dein.vim installed"
