#!/usr/bin/env bats

# shellcheck source=tests/unit/utils/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${BASE_TEST_SUITE_PREFIX}install_snap::"
readonly MOCK_SNAP_PREFIX="mock_snap_install: "

function snap() {
  echo "${MOCK_SNAP_PREFIX}$*"
}

function assert_snap_called_with() {
  local exp_args="${1}"

  assert_equal "${output}" "${MOCK_SNAP_PREFIX}install ${exp_args}"
}

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  setup_os_release_file
  declare -f snap
  mock_error
}

function teardown() {
  teardown_os_release_file
}

@test "${TEST_SUITE_PREFIX}errors correctly on invalid args" {
  invalid_arg="--crackle-pop"
  run install_snap "${invalid_arg}"
  assert_equal "${status}" 1
  assert_error_call_args "Invalid 'install_snap' arg: '${invalid_arg}'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly on no package name" {
  run install_snap
  assert_equal "${status}" 1
  assert_error_call_args "No snap name provided to 'install_snap'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}correctly installs snap with short arg name and no prefix" {
  snap_name="discord"
  run install_snap -n "${snap_name}"
  assert_equal "${status}" 0
  assert_snap_called_with "${snap_name}"
}

@test "${TEST_SUITE_PREFIX}correctly installs snap with long arg name and no prefix" {
  snap_name="shfmt"
  run install_snap --snap-name "${snap_name}"
  assert_equal "${status}" 0
  assert_snap_called_with "${snap_name}"
}

@test "${TEST_SUITE_PREFIX}correctly installs snap with short arg name and prefix" {
  snap_name="code"
  prefix="--classic"
  run install_snap -n "${snap_name}" -p "${prefix}"
  assert_equal "${status}" 0
  assert_snap_called_with "${prefix} ${snap_name}"
}

@test "${TEST_SUITE_PREFIX}correctly installs snap with long arg name and prefix" {
  snap_name="slack"
  prefix="--classic"
  run install_snap --snap-name "${snap_name}" --snap-prefix "${prefix}"
  assert_equal "${status}" 0
  assert_snap_called_with "${prefix} ${snap_name}"
}
