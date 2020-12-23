# shellcheck shell=bash

function install_slack() {
  install \
    --application-name "Slack" \
    --snap-name "slack" \
    --prefer-snap \
    --mac-package-name "slack" \
    --mac-package-prefix "--cask"
}
