# shellcheck shell=bash

function install_shellcheck() {
  install \
    --application-name "ShellCheck" \
    --debian-family-package-name "shellcheck" \
    --fedora-family-package-name "ShellCheck" \
    --mac-package-name "shellcheck"
}
