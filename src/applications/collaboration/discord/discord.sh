# shellcheck shell=bash

function install_discord() {
  install \
    --application-name "Discord" \
    --snap-name "discord" \
    --prefer-snap \
    --mac-package-name "discord" \
    --mac-package-prefix "--cask"
}
