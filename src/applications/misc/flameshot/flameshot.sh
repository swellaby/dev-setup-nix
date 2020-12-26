# shellcheck shell=bash

function install_flameshot() {
  local application_name="Flameshot"
  if [ "${OPERATING_SYSTEM}" == "${MAC_OS}" ]; then
    error "${application_name} installation is not currently supported on Mac"
    return
  fi
  local package_name="flameshot"
  install \
    --application-name "${application_name}" \
    --debian-family-package-name "${package_name}" \
    --fedora-family-package-name "${package_name}" \
}
