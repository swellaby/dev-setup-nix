# shellcheck shell=bash

function install_powershell() {
  function install_dependencies() {
    local -a dependencies_list=("$@")
    for package in "${dependencies_list[@]}"; do
      install_package -n "${package}"
    done
  }

  local -ar common_debian_based_dependencies=(
    "apt-transport-https"
  )

  local prefer_snap=false
  local -a dependencies
  if [ "${OPERATING_SYSTEM}" == "${LINUX_OS}" ]; then
    if [ "${LINUX_DISTRO}" == "${UBUNTU_DISTRO}" ]; then
      case "${LINUX_DISTRO_VERSION_ID}" in
        "16.04" | "18.04" | "20.04")
          dependencies=(
            "${common_debian_based_dependencies[@]}"
            "software-properties-common"
          )
          ;;
        "18.10" | "19.10" | "20.10")
          prefer_snap=true
          ;;
        *)
          error "PowerShell not supported on Ubuntu version: '${LINUX_DISTRO_VERSION_ID}'"
          return 1
          ;;
      esac
    elif [ "${LINUX_DISTRO}" == "${DEBIAN_DISTRO}" ]; then
      case "${LINUX_DISTRO_VERSION_ID}" in
        "8")
          dependencies=(
            "${common_debian_based_dependencies[@]}"
          )
          ;;
        "9")
          dependencies=(
            "${common_debian_based_dependencies[@]}"
            "gnupg"
          )
          ;;
        "10")
          ;;
        *)
          error "PowerShell not supported on Debian version: '${LINUX_DISTRO_VERSION_ID}'"
          return 1
          ;;
      esac
    elif [ "${LINUX_DISTRO}" == "${FEDORA_DISTRO}" ]; then
      dependencies=(
        "compat-openssl10"
      )
    fi
    install_dependencies "${dependencies[@]}"
    local key="https://packages.microsoft.com/keys/microsoft.asc"
    add_remote_signing_key --key-url "${key}"
    local repo="https://packages.microsoft.com/${LINUX_DISTRO}/${LINUX_DISTRO_VERSION_ID}/prod"
    add_package_repository --package-repository "${repo}"
    update_package_lists
  fi

  local package_name="powershell"
  local prefer_snap_arg
  if [ "${prefer_snap}" == true ]; then
    prefer_snap_arg="--prefer-snap"
  fi
  install \
    ${prefer_snap_arg} \
    --application-name "PowerShell" \
    --debian-family-package-name "${package_name}" \
    --fedora-family-package-name "${package_name}" \
    --snap-name "${package_name}" \
    --snap-prefix "--classic" \
    --mac-package-name "${package_name}" \
    --mac-package-prefix "--cask"
}
