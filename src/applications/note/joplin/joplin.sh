# shellcheck shell=bash

function install_joplin() {
  install \
    --application-name "Joplin" \
    --snap-name "joplin-desktop" \
    --prefer-snap \
    --mac-package-prefix "--cask" \
    --mac-package-name "joplin"
}
