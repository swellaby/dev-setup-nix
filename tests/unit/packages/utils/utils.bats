#!/usr/bin/env bats

load "../../../../test_helper_libs/bats-support/load"
load "../../../../test_helper_libs/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"

readonly TEST_SUITE_PREFIX="packages::utils::"

function setup() {
  # shellcheck source=src/packages/utils.sh
  source "${BATS_TEST_DIRNAME}"/../../../../src/packages/utils.sh
  setup_os_release_file
}

function teardown() {
  teardown_os_release_file
}

@test "${TEST_SUITE_PREFIX}error::writes correct contents to stderr" {
  exp="oh nose :("
  run error "${exp}"
  assert_equal "$status" 0
  assert_output_contains "${output}" "${exp}"
}

@test "${TEST_SUITE_PREFIX}info::writes correct contents to stdout" {
  exp="something or other"
  run info "${exp}"
  assert_equal "$status" 0
  assert_output_contains "${output}" "${exp}"
}

@test "${TEST_SUITE_PREFIX}check_snapd_availability::sets global correctly" {
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

@test "${TEST_SUITE_PREFIX}check_snapd_availability::uses correct tool name" {
  local prefix="mocked check_snapd_availability: "
  function tool_installed() {
    echo "${prefix}$*"
    return 0
  }

  run check_snapd_availability
  assert_equal "${status}" 0
  assert_equal "${output}" "${prefix}snap"
}
