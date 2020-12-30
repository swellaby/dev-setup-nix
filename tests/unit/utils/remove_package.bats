#!/usr/bin/env bats

# shellcheck source=tests/unit/utils/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${BASE_TEST_SUITE_PREFIX}remove_package::"
readonly MOCK_PACKAGE_MANAGER_PREFIX="mock_pm_remove:"
readonly MOCK_REMOVE_COMMAND="mock_package_manager"

function mock_package_manager() {
  echo "${MOCK_PACKAGE_MANAGER_PREFIX} $*"
}

function assert_package_manager_called_with() {
  assert_line "${MOCK_PACKAGE_MANAGER_PREFIX} ${1}"
}

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  setup_os_release_file
  declare -f mock_package_manager
  declare -x REMOVE_COMMAND="${MOCK_REMOVE_COMMAND}"
  mock_error
}

function teardown() {
  teardown_os_release_file
}

@test "${TEST_SUITE_PREFIX}errors correctly on invalid args" {
  invalid_arg="--abc-123"
  run remove_package "${invalid_arg}"
  assert_failure
  assert_error_call_args "Invalid 'remove_package' arg: '${invalid_arg}'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly on no package name" {
  run remove_package
  assert_failure
  assert_error_call_args "No package name provided to 'remove_package'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}correctly removes package with short arg name and no prefix" {
  package_name="nyancat"
  REMOVE_COMMAND="${MOCK_REMOVE_COMMAND}" run remove_package -n "${package_name}"
  assert_success
  assert_package_manager_called_with "${package_name}"
}

@test "${TEST_SUITE_PREFIX}correctly removes package with long arg name and no prefix" {
  package_name="magic-lamp"
  REMOVE_COMMAND="${MOCK_REMOVE_COMMAND}" run remove_package --package-name "${package_name}"
  assert_success
  assert_package_manager_called_with "${package_name}"
}

@test "${TEST_SUITE_PREFIX}correctly removes package with short arg name and prefix" {
  package_name="cat"
  prefix="--force"
  REMOVE_COMMAND="${MOCK_REMOVE_COMMAND}" run remove_package -n "${package_name}" -p "${prefix}"
  assert_success
  assert_package_manager_called_with "${prefix} ${package_name}"
}

@test "${TEST_SUITE_PREFIX}correctly removes package with long arg name and prefix" {
  package_name="dog"
  prefix="--woof"
  REMOVE_COMMAND="${MOCK_REMOVE_COMMAND}" run remove_package --package-name "${package_name}" --package-prefix "${prefix}"
  assert_success
  assert_package_manager_called_with "${prefix} ${package_name}"
}
