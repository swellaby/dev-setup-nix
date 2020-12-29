#!/usr/bin/env bats

# shellcheck source=tests/unit/utils/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
readonly TEST_SUITE_PREFIX="${BASE_TEST_SUITE_PREFIX}tool_installed::"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
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

  assert_failure
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

  assert_success
}
