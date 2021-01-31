# shellcheck shell=bash

function install_ncdu() {
  if [ "${OPERATING_SYSTEM}" == "${LINUX_OS}" ]; then
    if [ "${LINUX_DISTRO_FAMILY}" == "${FEDORA_DISTRO_FAMILY}" ]; then
      install_package -n "epel-release"
    fi
  fi

  local package_name="ncdu"
  install \
    --application-name "${package_name}" \
    --debian-family-package-name "${package_name}" \
    --fedora-family-package-name "${package_name}" \
    --mac-package-name "${package_name}"
}
