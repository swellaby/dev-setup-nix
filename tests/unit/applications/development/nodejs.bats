#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/nodejs/nodejs.sh
source "${DEVELOPMENT_DIRECTORY}/nodejs/nodejs.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::nodejs::install_nodejs::"
readonly BASH_CALL_ARGS_PREFIX="mock_bash:"
readonly SOURCE_CALL_ARGS_PREFIX="mock_source:"
readonly NVM_CALL_ARGS_PREFIX="mock_nvm:"

function setup() {
  mock_curl
  mock_tool_installed
  mock_install_curl

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

function assert_bash_call_args() {
  assert_line "${BASH_CALL_ARGS_PREFIX}"
}

@test "${TEST_SUITE_PREFIX}installs curl if not available" {
  mock_tool_installed 1
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

@test "${TEST_SUITE_PREFIX}does not source nvm.sh if already available" {
  function source() {
    echo "${SOURCE_CALL_ARGS_PREFIX} $*"
  }
  declare -f source
  run install_nodejs
  refute_line "${SOURCE_CALL_ARGS_PREFIX} $HOME/.nvm/nvm.sh"
}

@test "${TEST_SUITE_PREFIX}installs correct Node.js versions" {
  exp_node_versions=(
    "lts/carbon"
    "lts/dubnium"
    "lts/erbium"
    "lts/fermium"
    "lts/*"
  )
  local -i exp_node_v_count=${#exp_node_versions[@]}
  local -i act_node_v_count=0

  install_node_v_prefix="act_num_versions:"
  function nvm() {
    if [ "${1}" == "install" ]; then
      ((act_node_v_count = act_node_v_count + 1))
      echo "${install_node_v_prefix} ${act_node_v_count}"
    fi
    echo "${NVM_CALL_ARGS_PREFIX} $*"
  }
  declare -f nvm

  run install_nodejs

  assert_success
  for node_version in "${exp_node_versions[@]}"; do
    assert_line "${NVM_CALL_ARGS_PREFIX} install ${node_version}"
  done

  assert_line "${install_node_v_prefix} ${exp_node_v_count}"
  local -i exp_plus_one=exp_node_v_count+1
  refute_line "${install_node_v_prefix} ${exp_plus_one}"
}

@test "${TEST_SUITE_PREFIX}sets correct nvm default alias" {
  run install_nodejs
  assert_success
  assert_line "${NVM_CALL_ARGS_PREFIX} alias default lts/*"
}
