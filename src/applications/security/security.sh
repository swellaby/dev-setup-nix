# shellcheck shell=bash

readonly APPLICATION_SECURITY_DIR_FOR_LIB=$(dirname "${BASH_SOURCE[0]}")

source "${APPLICATION_SECURITY_DIR_FOR_LIB}/authy/authy.sh"
source "${APPLICATION_SECURITY_DIR_FOR_LIB}/clamav/clamav.sh"
source "${APPLICATION_SECURITY_DIR_FOR_LIB}/lynis/lynis.sh"

function install_security_tools() {
  local authy=false
  local clamav=false
  local lynis=false

  if [ "$#" -eq 0 ]; then
    info "No security tools specified for installation!"
    return 0
  fi

  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -a | --install-authy)
        authy=true
        ;;
      -c | --install-clamav)
        clamav=true
        ;;
      -l | --install-lynis)
        lynis=true
        ;;
      *)
        error "Invalid arg: '${1}' for security tool install script."
        exit 1
        ;;
    esac
    shift
  done

  if [ "${authy}" == true ]; then
    install_authy
  fi

  if [ "${clamav}" == true ]; then
    install_clamav
  fi

  if [ "${lynis}" == true ]; then
    install_lynis
  fi
}
