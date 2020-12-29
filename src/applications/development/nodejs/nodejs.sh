# shellcheck shell=bash

local_dir_name=$(dirname "${BASH_SOURCE[0]}")
source "${local_dir_name}/../../misc/curl/curl.sh"

function install_nodejs() {
  if ! tool_installed "curl"; then
    install_curl
  fi

  local install_version="v0.37.2"
  local install_url="https://raw.githubusercontent.com/nvm-sh/nvm/${install_version}/install.sh"

  curl -o- "${install_url}" | bash

  if ! tool_installed "nvm"; then
    source "$HOME/.nvm/nvm.sh"
  fi

  local current_lts="lts/*"
  local -a node_versions=(
    "lts/carbon"
    "lts/dubnium"
    "lts/erbium"
    "lts/fermium"
    "${current_lts}"
  )

  for node_version in "${node_versions[@]}"; do
    nvm install "${node_version}"
  done

  nvm alias default "${current_lts}"
}
