# shellcheck shell=bash

local_dir_name=$(dirname "${BASH_SOURCE[0]}")
source "${local_dir_name}/../../misc/curl/curl.sh"

# shellcheck shell=bash

function install_zoom() {
  local download_url_prefix="https://zoom.us/client"
  local version_for_64_bit="latest"
  local version_for_32_bit="5.4.53391.1108"
  local base_64_bit_download_url="${download_url_prefix}/${version_for_64_bit}"
  local base_32_bit_download_url="${download_url_prefix}/${version_for_32_bit}"

  local debian_package_target
  local fedora_package_target
  if [ "${OPERATING_SYSTEM}" == "${LINUX_OS}" ]; then
    if [ "${LINUX_DISTRO_FAMILY}" == "${DEBIAN_DISTRO_FAMILY}" ]; then
      local deb_download_url
      if [ "${BITNESS}" == "64" ]; then
        deb_download_url="${base_64_bit_download_url}/zoom_amd64.deb"
      elif [ "${BITNESS}" == "32" ]; then
        deb_download_url="${base_64_bit_download_url}/zoom_i386.deb"
      else
        error "Unsupported architecture bitness: '${BITNESS}' for Zoom installation"
        return 1
      fi
        if ! tool_installed "curl"; then
          install_curl
        fi
        local tmpdir="${TMPDIR:-/tmp}"
        debian_package_target="${tmpdir}/zoom.deb"
        rm -f "${linux_package_target}" || true
        curl -sSL "${deb_download_url}" -o "${debian_package_target}"
    elif [ "${LINUX_DISTRO_FAMILY}" == "${FEDORA_DISTRO_FAMILY}" ]; then
      if [ "${BITNESS}" == "64" ]; then
        fedora_package_target="${base_64_bit_download_url}/zoom_x86_64.rpm"
      elif [ "${BITNESS}" == "32" ]; then
        fedora_package_target="${base_32_bit_download_url}/zoom_i686.rpm"
      else
        error "Unsupported architecture bitness: '${BITNESS}' for Zoom installation"
        return 1
      fi
      local key="https://zoom.us/linux/download/pubkey"
      add_remote_signing_key --key-url "${key}"
    fi
  fi

  local dfpn
  local ffpn
  if [ -n "${debian_package_target}" ];then
    dfpn="--debian-family-package-name ${debian_package_target}"
  fi

  if [ -n "${fedora_package_target}" ];then
    ffpn="--fedora-family-package-name ${fedora_package_target}"
  fi

  install \
    ${dfpn} \
    ${ffpn} \
    --application-name "Zoom" \
    --mac-package-name "zoom" \
    --mac-package-prefix "--cask"
}
