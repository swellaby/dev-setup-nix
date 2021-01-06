# shellcheck shell=bash

function install_clamav() {
  local package_name="clamav"

  if [ "${OPERATING_SYSTEM}" == "${LINUX_OS}" ]; then
    local -a extra_packages
    case "${LINUX_DISTRO}" in
      "${FEDORA_DISTRO}")
        extra_packages=(
          "clamav-update"
        )
        ;;
      "${CENTOS_DISTRO}" | "${RHEL_DISTRO}")
        extra_packages=(
          "epel-release"
        )
        ;;
      *) ;;
    esac

    for package in "${extra_packages[@]}"; do
      install_package -n "${package}"
    done
  fi

  install \
    --application-name "ClamAV" \
    --debian-family-package-name "${package_name}" \
    --fedora-family-package-name "${package_name}" \
    --mac-package-name "${package_name}"
}
