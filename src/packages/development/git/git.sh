# shellcheck shell=bash

function install_git() {
  local git_package_name="git"
  install \
    --tool-name "Git" \
    --debian-family-package-name "${git_package_name}" \
    --fedora-family-package-name "${git_package_name}" \
    --mac-package-name "${git_package_name}"
}
