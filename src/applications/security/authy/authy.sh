# shellcheck shell=bash

function install_authy() {
  install \
    --application-name "Authy (Twilio)" \
    --snap-name "authy" \
    --snap-prefix "--beta" \
    --prefer-snap \
    --mac-package-name "authy" \
    --mac-package-prefix "--cask"
}
