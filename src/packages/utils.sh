# shellcheck shell=bash

readonly MAC_OS="macos"
readonly LINUX_OS="linux"
declare -x OPERATING_SYSTEM=""

unix_name=$(uname)

function error() {
  echo "[swellaby_dotfiles]: $*" >&2
}

function set_linux_variables() {
  OPERATING_SYSTEM=$LINUX_OS
  return 0
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

  readonly OPERATING_SYSTEM
  readonly unix_name
}

# Don't auto initialize during when sourced for running tests
# https://github.com/bats-core/bats-core#special-variables
if [[ -z ${BATS_TEST_NAME} ]]; then
  initialize
fi
