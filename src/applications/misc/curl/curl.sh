# shellcheck shell=bash

function install_curl() {
  local package_name="curl"
  install \
    --application-name "cURL" \
    --debian-family-package-name "${package_name}" \
    --fedora-family-package-name "${package_name}" \
    --mac-package-name "${package_name}"
}
