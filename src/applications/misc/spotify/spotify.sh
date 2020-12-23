# shellcheck shell=bash

function install_spotify() {
  install \
    --application-name "Spotify" \
    --snap-name "spotify"
    --prefer-snap
    --mac-package-name "spotify" \
    --mac-package-prefix "--cask"
}
