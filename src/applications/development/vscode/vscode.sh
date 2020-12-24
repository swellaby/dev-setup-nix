# shellcheck shell=bash

declare -ar ENABLED_VSCODE_EXTENSIONS=(
  "swellaby.common-pack"
)

declare -ar DISABLED_VSCODE_EXTENSIONS=(
  "swellaby.rust-pack"
  "swellaby.node-pack"
  "swellaby.common-pack"
)

function install_vscode() {
  install \
    --application-name "VS Code" \
    --snap-name "code" \
    --snap-prefix "--classic" \
    --prefer-snap \
    --mac-package-name "visual-studio-code" \
    --mac-package-prefix "--cask"
}

function install_vscode_extension() {
  local extension_name="${1}"
  tool_installed "code"
  local -i vscode_available=$?

  if [ "${vscode_available}" -ne 0 ]; then
    error "Attempted to install VS Code extension '${extension_name}' but 'code' not on PATH"
    return 1
  fi

  info "Installing VS Code extension: '${extension_name}'"
  code --install-extension "${extension_name}" --force
}

function install_default_vscode_extensions() {
  for extension in "${ENABLED_VSCODE_EXTENSIONS[@]}"; do
    install_vscode_extension "${extension}"
  done

  # This collection of extensions are likely to be workspace
  # specific and often disabled/enabled depending on the project.
  # The VS Code cli does not yet support disabling an installed
  # extension in a permanent way, but it may some day.
  # https://github.com/microsoft/vscode/issues/52639
  for extension in "${DISABLED_VSCODE_EXTENSIONS[@]}"; do
    install_vscode_extension "${extension}"
  done
}
