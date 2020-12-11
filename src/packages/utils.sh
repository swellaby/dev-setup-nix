# shellcheck shell=bash

# Enable easier mocking in tests
USER_ID=${UID}
unix_name=$(uname)

readonly MAC_OS="macos"
readonly LINUX_OS="linux"
declare -x OPERATING_SYSTEM=""

# This file should be present on the vast majority of modern versions
# of most major distributions, as well as anything running systemd
declare -x LINUX_DISTRO_OS_IDENTIFICATION_FILE="/etc/os-release"

LINUX_DISTRO=""
SNAP_AVAILABLE=true
readonly UBUNTU_DISTRO="ubuntu"
readonly DEBIAN_DISTRO="debian"
readonly FEDORA_DISTRO="fedora"
readonly RHEL_DISTRO="rhel"
readonly CENTOS_DISTRO="centos"

declare -x LINUX_DISTRO_FAMILY=""
readonly DEBIAN_DISTRO_FAMILY=${DEBIAN_DISTRO}
readonly FEDORA_DISTRO_FAMILY=${FEDORA_DISTRO}

# Configure package managers.
# Maybe one day these can be added...
# FreeBSD = pkg
# SUSE = zypper
# Arch = pacman
# Gentoo = portage
PACKAGE_MANAGER=""
readonly DEBIAN_PACKAGE_MANAGER="apt"
readonly DEBIAN_INSTALL_SUBCOMMAND="install"
readonly DEBIAN_INSTALLER_SUFFIX="-y --no-install-recommends"

readonly FEDORA_PACKAGE_MANAGER="dnf"
readonly FEDORA_INSTALL_SUBCOMMAND="install"
readonly FEDORA_INSTALLER_SUFFIX="-y"

readonly MACOS_PACKAGE_MANAGER="brew"
readonly MACOS_INSTALL_SUBCOMMAND="install"

INSTALLER_PREFIX=""
INSTALLER_SUFFIX=""
INSTALL_SUBCOMMAND=""
declare -x INSTALL_COMMAND=""

function error() {
  echo "[swellaby_dotfiles]: $*" >&2
}

function info() {
  echo "[swellaby_dotfiles]: $*" >&1
}

function set_debian_variables() {
  LINUX_DISTRO_FAMILY=${DEBIAN_DISTRO_FAMILY}
  PACKAGE_MANAGER=${DEBIAN_PACKAGE_MANAGER}
  INSTALLER_SUFFIX=${DEBIAN_INSTALLER_SUFFIX}
  INSTALL_SUBCOMMAND=${DEBIAN_INSTALL_SUBCOMMAND}
}

function set_fedora_variables() {
  LINUX_DISTRO_FAMILY=${FEDORA_DISTRO_FAMILY}
  PACKAGE_MANAGER=${FEDORA_PACKAGE_MANAGER}
  INSTALLER_SUFFIX=${FEDORA_INSTALLER_SUFFIX}
  INSTALL_SUBCOMMAND=${FEDORA_INSTALL_SUBCOMMAND}
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
  info "Detected Linux distro: '${LINUX_DISTRO}'"

  if [ ${USER_ID} -ne 0 ]; then
    INSTALLER_PREFIX="sudo"
  fi

  case $id in
    "${DEBIAN_DISTRO}")
      set_debian_variables
      ;;
    "${UBUNTU_DISTRO}")
      set_debian_variables
      ;;
    "${FEDORA_DISTRO}")
      set_fedora_variables
      ;;
    "${RHEL_DISTRO}")
      set_fedora_variables
      ;;
    "${CENTOS_DISTRO}")
      set_fedora_variables
      ;;
    *)
      error "Unsupported distro: '${LINUX_DISTRO}'"
      exit 1
      ;;
  esac
}

function set_macos_variables() {
  OPERATING_SYSTEM=${MAC_OS}
  PACKAGE_MANAGER=${MACOS_PACKAGE_MANAGER}
  INSTALL_SUBCOMMAND=${MACOS_INSTALL_SUBCOMMAND}
  SNAP_AVAILABLE=false
}

function install_snap() {
  local snap_name
  local snap_prefix
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -n|--snap-name)
        snap_name="${2}"
        shift
        ;;
      -p|--snap-prefix)
        snap_prefix="${2}"
        shift
        ;;
      *)
        error "Invalid 'install_snap' arg: '${1}'. This is a bug!"
        exit 1
        ;;
    esac
    shift
  done

  if [ -z ${snap_name} ]; then
    error "No snap name provided to 'install_snap'"
    return 1
  fi

  "${INSTALLER_PREFIX}" snap install "${snap_prefix}" "${snap_name}"
}

function install_package() {
  local package_name
  local package_prefix
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -n|--package-name)
        package_name="${2}"
        shift
        ;;
      -p|--package-prefix)
        package_prefix="${2}"
        shift
        ;;
      *)
        error "Invalid 'install_package' arg. This is a bug!"
        exit 1
        ;;
    esac
    shift
  done

  if [ -z "${package_name}" ]; then
    error "No package name provided to 'install_package'"
    return 1
  fi

  ${INSTALL_COMMAND} ${package_prefix} ${package_name}
}

function install() {
  local prefer_snap
  local package_name
  local package_prefix
  local snap_name
  local snap_prefix

  if [ $# -eq 0 ]; then
    error "No args passed to 'install' but at a minimum a snap or package name must be provided. This is a bug!"
    exit 1
  fi

  prefer_snap=false

  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -pfs|--prefer-snap)
        prefer_snap=true
        ;;
      -n|--package-name)
        package_name="${2}"
        shift
        ;;
      -pp|--package-prefix)
        package_prefix="${2}"
        shift
        ;;
      -s|--snap-name)
        snap_name="${2}"
        shift
        ;;
      -sp|--snap-prefix)
        snap_prefix="${2}"
        shift
        ;;
      *)
        error "Invalid 'install' arg: '${1}'. This is a bug!"
        exit 1
        ;;
    esac
    shift
  done

  if [ "${prefer_snap}" == true ]; then
    if [ ${SNAP_AVAILABLE} != true ]; then
      error "Snap install preferred but Snap not available. This is a bug!"
    else
      install_snap -n "${snap_name}"
      # shellcheck disable=SC2181
      if [ $? -eq 0 ]; then
        return 0
      else
        error "Attempted but failed to install Snap: '${snap_name}'"
        error "Falling back to package manager"
      fi
    fi
  fi

  if [ -z ${package_name} ]; then
    echo "# no package name?" >&3
    error "No package name provided for installation"
    return 1
  fi

  install_package -n "${package_name}"
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

  INSTALL_COMMAND="${INSTALLER_PREFIX} ${PACKAGE_MANAGER} ${INSTALL_SUBCOMMAND} ${INSTALLER_SUFFIX}"

  readonly unix_name
  readonly OPERATING_SYSTEM
  readonly LINUX_DISTRO_OS_IDENTIFICATION_FILE
  readonly LINUX_DISTRO
  readonly LINUX_DISTRO_FAMILY
  readonly INSTALLER_PREFIX
  readonly INSTALLER_SUFFIX
  readonly PACKAGE_MANAGER
  readonly INSTALL_COMMAND
  readonly INSTALL_SUBCOMMAND
  readonly SNAP_AVAILABLE
}

# Don't auto initialize during when sourced for running tests
# https://github.com/bats-core/bats-core#special-variables
if [[ -z ${BATS_TEST_NAME} ]]; then
  initialize
  unset set_debian_variables
  unset set_fedora_variables
  unset set_linux_variables
  unset set_macos_variables
  unset initialize
fi
