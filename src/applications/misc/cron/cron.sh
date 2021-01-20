# shellcheck shell=bash

function install_cron() {
  # Cron should already be available everywhere, but it's
  # easier to have a fall back in the Linux cases than for Mac.
  if [ "${OPERATING_SYSTEM}" == "${MAC_OS}" ]; then
    info "Skipping cron installation on Mac"
    return 0
  fi

  install \
    --application-name "cron" \
    --debian-family-package-name "cron" \
    --fedora-family-package-name "cronie"
}
