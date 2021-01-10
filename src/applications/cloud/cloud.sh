# shellcheck shell=bash

readonly APPLICATION_CLOUD_DIR_FOR_LIB=$(dirname "${BASH_SOURCE[0]}")

source "${APPLICATION_CLOUD_DIR_FOR_LIB}/azure/azure.sh"
source "${APPLICATION_CLOUD_DIR_FOR_LIB}/gcp/gcp.sh"
source "${APPLICATION_CLOUD_DIR_FOR_LIB}/heroku/heroku.sh"

function install_cloud_tools_bin() {
  local azure=false
  local gcp=false
  local heroku=false

  if [ "$#" -eq 0 ]; then
    info "No cloud tools specified for installation!"
    return 0
  fi

  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --install-azure-cli)
        azure=true
        ;;
      -g | --install-gcloud-sdk)
        gcp=true
        ;;
      -h | --install-heroku)
        heroku=true
        ;;
      *)
        error "Invalid arg: '${1}' for cloud tool install script."
        exit 1
        ;;
    esac
    shift
  done

  if [ "${azure}" == true ]; then
    install_azure_cli
  fi

  if [ "${gcp}" == true ]; then
    install_gcloud_sdk
  fi

  if [ "${heroku}" == true ]; then
    install_heroku
  fi
}
