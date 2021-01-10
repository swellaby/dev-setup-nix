# shellcheck shell=bash

function install_firefox() {
  local package_name="firefox"
  install \
    --application-name "Firefox" \
    --debian-family-package-name "${package_name}" \
    --fedora-family-package-name "${package_name}" \
    --mac-package-name "${package_name}" \
    --mac-package-prefix "--cask"
}
