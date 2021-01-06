# shellcheck shell=bash

function install_azure_cli() {
  local package_name="azure-cli"
  if [ "${OPERATING_SYSTEM}" == "${LINUX_OS}" ]; then
    local package_repository
    if [ "${LINUX_DISTRO_FAMILY}" == "${DEBIAN_DISTRO_FAMILY}" ]; then
      case "${LINUX_DISTRO}_${LINUX_DISTRO_VERSION_ID}" in
        "${UBUNTU_DISTRO}_20.04")
          remove_package -n "${package_name}"
          ;;
        *) ;;
      esac
      package_repository="https://packages.microsoft.com/repos/azure-cli"
      local -ar dependencies=(
        "ca-certificates"
        "apt-transport-https"
        "gnupg"
      )
      for package in "${dependencies[@]}"; do
        install_package -n "${package}"
      done
    elif [ "${LINUX_DISTRO_FAMILY}" == "${FEDORA_DISTRO_FAMILY}" ]; then
      package_repository="https://packages.microsoft.com/yumrepos/azure-cli"
    else
      error "Azure CLI installation not yet supported Linux Distro: '${LINUX_DISTRO}'"
      return 1
    fi

    local key="https://packages.microsoft.com/keys/microsoft.asc"
    add_remote_signing_key --key-url "${key}"
    add_package_repository --package-repository "${package_repository}"
    update_package_lists
  fi

  install \
    --application-name "Azure CLI" \
    --debian-family-package-name "${package_name}" \
    --fedora-family-package-name "${package_name}" \
    --mac-package-name "${package_name}"
}
