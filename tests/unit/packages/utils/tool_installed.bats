#!/usr/bin/env bats

load "../../../../test_helper_libs/bats-support/load"
load "../../../../test_helper_libs/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"

readonly TEST_SUITE_PREFIX="packages::utils::tool_installed::"

function setup() {
  # shellcheck source=src/packages/utils.sh
  source "${BATS_TEST_DIRNAME}"/../../../../src/packages/utils.sh
  setup_os_release_file
}

function teardown() {
  teardown_os_release_file
}

@test "${TEST_SUITE_PREFIX}correctly handles missing tool" {
  local tool_name="some-really-really-fake-tool-that-definitely-does-not-exist"
  function command() {
    if [ "${1}" == "-v" ] && [ "${2}" == "${tool_name}" ]; then
      return 1
    fi
    exit 23
  }

  # shellcheck disable=SC2030
  declare -x command

  run tool_installed "${tool_name}"

  assert_equal "${status}" 1
}

@test "${TEST_SUITE_PREFIX}correctly handles installed tool" {
  local tool_name="curl"
  function command() {
    if [ "${1}" == "-v" ] && [ "${2}" == "${tool_name}" ]; then
      return 0
    fi
    exit 8
  }

  # shellcheck disable=SC2031
  declare -x command

  run tool_installed "${tool_name}"

  assert_equal "${status}" 0
}
