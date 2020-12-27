# shellcheck shell=bash

function install_shfmt() {
  local package_name="shfmt"
  install \
    --application-name "${package_name}" \
    --snap-name "${package_name}" \
    --prefer-snap \
    --mac-package-name "${package_name}"
}
