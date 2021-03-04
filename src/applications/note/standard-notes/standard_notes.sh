# shellcheck shell=bash

function install_standard_notes() {
  local package_name="standard-notes"
  install \
    --application-name "Standard Notes" \
    --snap-name "${package_name}" \
    --prefer-snap \
    --mac-package-prefix "--cask" \
    --mac-package-name "${package_name}"
}
