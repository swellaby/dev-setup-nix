# shellcheck shell=bash

function install_anacron() {
  if [ "${OPERATING_SYSTEM}" == "${MAC_OS}" ]; then
    info "anacron installation not supported on Mac"
    return 0
  fi

  install \
    --application-name "anacron" \
    --debian-family-package-name "anacron" \
    --fedora-family-package-name "anacronie"
}
