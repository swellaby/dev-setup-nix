# shellcheck shell=bash

function install_wget() {
  local package_name="wget"
  install \
    --application-name "Wget" \
    --debian-family-package-name "${package_name}" \
    --fedora-family-package-name "${package_name}" \
    --mac-package-name "${package_name}"
}
