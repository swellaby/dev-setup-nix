# shellcheck shell=bash

function install_teams() {
  install \
    --application-name "Microsoft Teams" \
    --snap-name "teams" \
    --prefer-snap \
    --mac-package-name "microsoft-teams" \
    --mac-package-prefix "--cask"
}
