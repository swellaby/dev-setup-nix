# shellcheck shell=bash

readonly APPLICATION_BROWSER_DIR_FOR_LIB=$(dirname "${BASH_SOURCE[0]}")

source "${APPLICATION_BROWSER_DIR_FOR_LIB}/chromium/chromium.sh"
source "${APPLICATION_BROWSER_DIR_FOR_LIB}/firefox/firefox.sh"

function install_browsers_tools_bin() {
  local chromium=false
  local firefox=false

  if [ "$#" -eq 0 ]; then
    info "No browser tools specified for installation!"
    return 0
  fi

  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --install-chromium)
        chromium=true
        ;;
      -f | --install-firefox)
        firefox=true
        ;;
      *)
        error "Invalid arg: '${1}' for browser tool install script."
        exit 1
        ;;
    esac
    shift
  done

  if [ "${chromium}" == true ]; then
    install_chromium
  fi

  if [ "${firefox}" == true ]; then
    install_firefox
  fi
}
