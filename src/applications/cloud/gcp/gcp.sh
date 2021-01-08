# shellcheck shell=bash

function install_gcloud_sdk() {
  local package_name="google-cloud-sdk"
  if [ "${OPERATING_SYSTEM}" == "${LINUX_OS}" ]; then
    local key_url
    local package_repository
    if [ "${LINUX_DISTRO_FAMILY}" == "${DEBIAN_DISTRO_FAMILY}" ]; then
      key_url="https://packages.cloud.google.com/apt/doc/apt-key.gpg"
      package_repository="deb https://packages.cloud.google.com/apt cloud-sdk main"
      local -ar dependencies=(
        "ca-certificates"
        "apt-transport-https"
        "gnupg"
      )
      for package in "${dependencies[@]}"; do
        install_package -n "${package}"
      done
    elif [ "${LINUX_DISTRO_FAMILY}" == "${FEDORA_DISTRO_FAMILY}" ]; then
      key_url="https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg"
      package_repository="https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64"
    else
      error "GCloud SDK installation not yet supported Linux Distro: '${LINUX_DISTRO}'"
      return 1
    fi

    add_remote_signing_key --key-url "${key_url}"
    add_package_repository --package-repository "${package_repository}"
    update_package_lists
  fi

  install \
    --application-name "GCloud SDK" \
    --debian-family-package-name "${package_name}" \
    --fedora-family-package-name "${package_name}" \
    --mac-package-prefix "--cask" \
    --mac-package-name "${package_name}"
}
