# shellcheck shell=bash

function install_zulip() {
  local name="zulip"
  install \
    --application-name "Zulip" \
    --snap-name "${name}" \
    --prefer-snap \
    --mac-package-name "${name}" \
    --mac-package-prefix "--cask"
}
