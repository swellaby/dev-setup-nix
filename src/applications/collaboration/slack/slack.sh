# shellcheck shell=bash

function install_slack() {
  install \
    --application-name "Slack" \
    --snap-name "slack" \
    --snap-prefix "--classic" \
    --prefer-snap \
    --mac-package-name "slack" \
    --mac-package-prefix "--cask"
}
