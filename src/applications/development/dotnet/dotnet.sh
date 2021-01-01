# shellcheck shell=bash

function install_dotnet_sdk() {
  if [ "${OPERATING_SYSTEM}" == "${LINUX_OS}" ]; then
    local key="https://packages.microsoft.com/keys/microsoft.asc"
    add_remote_signing_key --key-url "${key}"
    local repo="https://packages.microsoft.com/${LINUX_DISTRO}/${LINUX_DISTRO_VERSION_ID}/prod"
    add_package_repository --package-repository "${repo}"
    update_package_lists
    if [ "${LINUX_DISTRO_FAMILY}" == "${DEBIAN_DISTRO_FAMILY}" ]; then
      install_package -n "apt-transport-https"
      update_package_lists
    fi
  fi

  local linux_package_name="dotnet-sdk-5.0"
  install \
    --application-name ".NET 5" \
    --debian-family-package-name "${linux_package_name}" \
    --fedora-family-package-name "${linux_package_name}" \
    --mac-package-name "dotnet-sdk" \
    --mac-package-prefix "--cask"
}
