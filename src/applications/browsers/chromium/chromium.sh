# shellcheck shell=bash

function install_chromium() {
  install \
    --application-name "Chromium" \
    --debian-family-package-name "chromium-browser" \
    --fedora-family-package-name "chromium" \
    --mac-package-name "chromium" \
    --mac-package-prefix "--cask"
}
