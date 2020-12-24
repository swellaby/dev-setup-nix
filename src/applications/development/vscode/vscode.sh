# shellcheck shell=bash

function install_vscode() {
  local name="VS Code"
  install \
    --application-name "${name}" \
    --snap-name "code" \
    --snap-prefix "--classic" \
    --prefer-snap \
    --mac-package-name "visual-studio-code" \
    --mac-package-prefix "--cask"
}
