#!/usr/bin/env bats

# shellcheck source=tests/unit/utils/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${BASE_TEST_SUITE_PREFIX}install_package::"
readonly MOCK_PACKAGE_MANAGER_PREFIX="mock_pm_install: "
readonly MOCK_INSTALL_COMMAND="mock_package_manager"

function mock_package_manager() {
  echo "${MOCK_PACKAGE_MANAGER_PREFIX}$*"
}

function assert_package_manager_called_with() {
  local exp_args="${1}"

  assert_equal "${output}" "${MOCK_PACKAGE_MANAGER_PREFIX}${exp_args}"
}

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  setup_os_release_file
  declare -f mock_package_manager
  declare -x INSTALL_COMMAND="${MOCK_INSTALL_COMMAND}"
  mock_error
}

function teardown() {
  teardown_os_release_file
}

@test "${TEST_SUITE_PREFIX}errors correctly on invalid args" {
  invalid_arg="--what-the-what"
  run install_package "${invalid_arg}"
  assert_failure
  assert_error_call_args "Invalid 'install_package' arg: '${invalid_arg}'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly on no package name" {
  run install_package
  assert_failure
  assert_error_call_args "No package name provided to 'install_package'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}correctly installs package with short arg name and no prefix" {
  package_name="nyancat"
  INSTALL_COMMAND="${MOCK_INSTALL_COMMAND}" run install_package -n "${package_name}"
  assert_success
  assert_package_manager_called_with "${package_name}"
}

@test "${TEST_SUITE_PREFIX}correctly installs package with long arg name and no prefix" {
  package_name="magic-lamp"
  INSTALL_COMMAND="${MOCK_INSTALL_COMMAND}" run install_package --package-name "${package_name}"
  assert_success
  assert_package_manager_called_with "${package_name}"
}

@test "${TEST_SUITE_PREFIX}correctly installs package with short arg name and prefix" {
  package_name="cat"
  prefix="--force"
  INSTALL_COMMAND="${MOCK_INSTALL_COMMAND}" run install_package -n "${package_name}" -p "${prefix}"
  assert_success
  assert_package_manager_called_with "${prefix} ${package_name}"
}

@test "${TEST_SUITE_PREFIX}correctly installs package with long arg name and prefix" {
  package_name="dog"
  prefix="--woof"
  INSTALL_COMMAND="${MOCK_INSTALL_COMMAND}" run install_package --package-name "${package_name}" --package-prefix "${prefix}"
  assert_success
  assert_package_manager_called_with "${prefix} ${package_name}"
}
