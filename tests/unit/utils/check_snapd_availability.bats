#!/usr/bin/env bats

# shellcheck source=tests/unit/utils/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${BASE_TEST_SUITE_PREFIX}check_snapd_availability::"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  setup_os_release_file
}

function teardown() {
  teardown_os_release_file
}

@test "${TEST_SUITE_PREFIX}sets global correctly" {
  function tool_installed() {
    return 1
  }

  set +e
  check_snapd_availability
  status=$?
  set -e

  assert_equal "${status}" 0
  assert_equal "${SNAP_AVAILABLE}" 1
}

@test "${TEST_SUITE_PREFIX}uses correct tool name" {
  local prefix="mocked check_snapd_availability: "
  function tool_installed() {
    echo "${prefix}$*"
    return 0
  }

  run check_snapd_availability
  assert_equal "${status}" 0
  assert_equal "${output}" "${prefix}snap"
}
