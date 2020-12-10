# shellcheck shell=bash

unix_name=$(uname)

readonly MAC_OS="macos"
readonly LINUX_OS="linux"
declare -x OPERATING_SYSTEM=""

# This file should be present on the vast majority of modern versions
# of most major distributions, as well as anything running systemd
declare -x LINUX_DISTRO_OS_IDENTIFICATION_FILE="/etc/os-release"

LINUX_DISTRO=""
readonly UBUNTU_DISTRO="ubuntu"
readonly DEBIAN_DISTRO="debian"
readonly FEDORA_DISTRO="fedora"
readonly RHEL_DISTRO="rhel"
readonly CENTOS_DISTRO="centos"

declare -x LINUX_DISTRO_FAMILY=""
readonly DEBIAN_DISTRO_FAMILY=${DEBIAN_DISTRO}
readonly FEDORA_DISTRO_FAMILY=${FEDORA_DISTRO}

function error() {
  echo "[swellaby_dotfiles]: $*" >&2
}

function info() {
  echo "[swellaby_dotfiles]: $*" >&1
}

function set_debian_variables() {
  LINUX_DISTRO_FAMILY=${DEBIAN_DISTRO_FAMILY}
}

function set_fedora_variables() {
  LINUX_DISTRO_FAMILY=${FEDORA_DISTRO_FAMILY}
}

function set_linux_variables() {
  OPERATING_SYSTEM=$LINUX_OS
  if [ ! -f ${LINUX_DISTRO_OS_IDENTIFICATION_FILE} ]; then
    error "Detected Linux OS but did not find '${LINUX_DISTRO_OS_IDENTIFICATION_FILE}' file"
    exit 1
  fi

  local id
  id=$(grep -oP '(?<=^ID=).+' ${LINUX_DISTRO_OS_IDENTIFICATION_FILE} | tr -d '"')
  LINUX_DISTRO=$id
  info "Detected Linux distro: ${LINUX_DISTRO}"

  case $id in
    "${DEBIAN_DISTRO}") set_debian_variables ;;
    "${UBUNTU_DISTRO}") set_debian_variables ;;
    "${FEDORA_DISTRO}") set_fedora_variables ;;
    "${RHEL_DISTRO}") set_fedora_variables ;;
    "${CENTOS_DISTRO}") set_fedora_variables ;;
    *) error "Unsupported distro ${LINUX_DISTRO}" && exit 1 ;;
  esac
}

function set_macos_variables() {
  OPERATING_SYSTEM=${MAC_OS}
  return 0
}

function initialize() {
  if [ "${unix_name}" == "Darwin" ]; then
    set_macos_variables
  elif [ "${unix_name}" == "Linux" ]; then
    set_linux_variables
  else
    error "Unsupported OS. Are you on Windows using Git Bash or Cygwin?"
    exit 1
  fi

  readonly unix_name
  readonly OPERATING_SYSTEM
  readonly LINUX_DISTRO_OS_IDENTIFICATION_FILE
  readonly LINUX_DISTRO
  readonly LINUX_DISTRO_FAMILY
}

# Don't auto initialize during when sourced for running tests
# https://github.com/bats-core/bats-core#special-variables
if [[ -z ${BATS_TEST_NAME} ]]; then
  initialize
fi
