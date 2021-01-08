# shellcheck shell=bash

function install_lynis() {
  if [ "${OPERATING_SYSTEM}" == "${LINUX_OS}" ]; then
    local key_url
    local package_repository
    local dependencies
    if [ "${LINUX_DISTRO_FAMILY}" == "${DEBIAN_DISTRO_FAMILY}" ]; then
      key_url="https://packages.cisofy.com/keys/cisofy-software-public.key"
      package_repository="deb https://packages.cisofy.com/community/lynis/deb/ stable main"
      dependencies=(
        "apt-transport-https"
      )
    elif [ "${LINUX_DISTRO_FAMILY}" == "${FEDORA_DISTRO_FAMILY}" ]; then
      key_url="https://packages.cisofy.com/keys/cisofy-software-rpms-public.key"
      package_repository="https://packages.cisofy.com/community/lynis/rpm/"

      local dependencies
      case "${LINUX_DISTRO}" in
        "${RHEL_DISTRO}" | "${CENTOS_DISTRO}")
          dependencies=(
            "ca-certificates"
            "curl"
            "nss"
            "openssl"
          )
          ;;
        *) ;;
      esac
    else
      error "Lynis installation not yet supported Linux Distro: '${LINUX_DISTRO}'"
      return 1
    fi
    for package in "${dependencies[@]}"; do
      install_package -n "${package}"
    done
    add_remote_signing_key --key-url "${key_url}"
    add_package_repository --package-repository "${package_repository}"
    update_package_lists
  fi

  local package_name="lynis"
  install \
    --application-name "Lynis" \
    --debian-family-package-name "${package_name}" \
    --fedora-family-package-name "${package_name}" \
    --mac-package-name "${package_name}"
}
