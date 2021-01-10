# shellcheck shell=bash

function install_chromium() {
  local package_name="chromium"
  install \
    --application-name "Chromium" \
    --debian-family-package-name "${package_name}-browser" \
    --fedora-family-package-name "${package_name}" \
    --mac-package-name "${package_name}" \
    --mac-package-prefix "--cask"
}
