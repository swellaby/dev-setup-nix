# shellcheck shell=bash

readonly APPLICATION_SECURITY_DIR_FOR_LIB=$(dirname "${BASH_SOURCE[0]}")

source "${APPLICATION_SECURITY_DIR_FOR_LIB}/authy/authy.sh"
source "${APPLICATION_SECURITY_DIR_FOR_LIB}/clamav/clamav.sh"
source "${APPLICATION_SECURITY_DIR_FOR_LIB}/lynis/lynis.sh"

function install_security_tools_bin() {
  local install_authy=false
  local install_clamav=false
  local install_lynis=false

  if [ "$#" -eq 0 ]; then
    info "No security tools specified for installation!"
    return 0
  fi

  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -a | --install-authy)
        install_authy=true
        ;;
      -c | --install-clamav)
        install_clamav=true
        ;;
      -l | --install-lynis)
        install_lynis=true
        ;;
      *)
        error "Invalid arg: '${1}' for security tool install script."
        exit 1
        ;;
    esac
    shift
  done

  if [ "${install_authy}" == true ]; then
    install_authy
  fi

  if [ "${install_clamav}" == true ]; then
    install_clamav
  fi

  if [ "${install_lynis}" == true ]; then
    install_lynis
  fi
}
