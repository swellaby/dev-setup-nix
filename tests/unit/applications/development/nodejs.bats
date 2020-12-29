#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/nodejs/nodejs.sh
source "${DEVELOPMENT_DIRECTORY}/nodejs/nodejs.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::nodejs::install_nodejs::"
readonly INSTALL_CURL_CALL_ARGS_PREFIX="mock_install_curl:"
readonly TOOL_INSTALLED_CALL_ARGS_PREFIX="mock_tool_installed:"
readonly BASH_CALL_ARGS_PREFIX="mock_bash:"
readonly SOURCE_CALL_ARGS_PREFIX="mock_source:"
readonly NVM_CALL_ARGS_PREFIX="mock_nvm:"

function setup() {
  function curl() {
    echo "$*" >&"${STD_OUT_TMP_FILE}"
  }
  declare -f curl

  function install_curl() {
    echo "${INSTALL_CURL_CALL_ARGS_PREFIX}"
  }
  declare -f install_curl

  function tool_installed() {
    echo "${TOOL_INSTALLED_CALL_ARGS_PREFIX} $*"
    return 0
  }
  declare -f tool_installed

  function bash() {
    echo "${BASH_CALL_ARGS_PREFIX}"
  }
  declare -f bash

  function nvm() {
    echo "${NVM_CALL_ARGS_PREFIX} $*"
  }
  declare -f nvm
}

function teardown() {
  rm -f "${STD_OUT_TMP_FILE}" || true
}

function assert_curl_call_args() {
  act=$(cat "${STD_OUT_TMP_FILE}")
  assert_equal "${act}" "${1}"
}

function assert_install_curl_called() {
  assert_line "${INSTALL_CURL_CALL_ARGS_PREFIX}"
}

function assert_tool_installed_call_args() {
  assert_line "${TOOL_INSTALLED_CALL_ARGS_PREFIX} ${1}"
}

function assert_bash_call_args() {
  assert_line "${BASH_CALL_ARGS_PREFIX}"
}

@test "${TEST_SUITE_PREFIX}installs curl if not available" {
  function tool_installed() {
    echo "${TOOL_INSTALLED_CALL_ARGS_PREFIX} ${1}"
    return 1
  }
  run install_nodejs
  assert_success
  assert_tool_installed_call_args "curl"
  assert_install_curl_called
}

@test "${TEST_SUITE_PREFIX}does not attempt to install curl if available" {
  run install_nodejs
  assert_success
  assert_tool_installed_call_args "curl"
  refute_line "${INSTALL_CURL_CALL_ARGS_PREFIX}"
}

@test "${TEST_SUITE_PREFIX}uses correct curl options" {
  run install_nodejs
  assert_success
  assert_curl_call_args "-o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh"
}

@test "${TEST_SUITE_PREFIX}uses correct bash pipe options" {
  run install_nodejs
  assert_success
  assert_bash_call_args ""
}

@test "${TEST_SUITE_PREFIX}sources nvm.sh if not already available" {
  function source() {
    echo "${SOURCE_CALL_ARGS_PREFIX} $*"
  }
  declare -f source
  function tool_installed() {
    echo "${TOOL_INSTALLED_CALL_ARGS_PREFIX} $*"
    if [ "${1}" == "nvm" ]; then
      return 1
    else
      return 0
    fi
  }
  run install_nodejs
  assert_line "${SOURCE_CALL_ARGS_PREFIX} $HOME/.nvm/nvm.sh"
}
