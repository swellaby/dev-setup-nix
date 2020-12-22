#!/usr/bin/env bats

load "../../../../submodules/bats-support/load"
load "../../../../submodules/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"

readonly MOCK_PACKAGE_MANAGER_PREFIX="mock_pm_install: "
readonly MOCK_INSTALL_COMMAND="mock_package_manager"
readonly TEST_SUITE_PREFIX="packages::utils::install_package::"

function mock_package_manager() {
  echo "${MOCK_PACKAGE_MANAGER_PREFIX}$*"
}

function assert_package_manager_called_with() {
  local exp_args="${1}"

  assert_equal "${output}" "${MOCK_PACKAGE_MANAGER_PREFIX}${exp_args}"
}

function setup() {
  # shellcheck source=src/packages/utils.sh
  source "${BATS_TEST_DIRNAME}"/../../../../src/packages/utils.sh
  setup_os_release_file
  declare -f mock_package_manager
  declare -x INSTALL_COMMAND="${MOCK_INSTALL_COMMAND}"
}

function teardown() {
  teardown_os_release_file
}

@test "${TEST_SUITE_PREFIX}errors correctly on invalid args" {
  invalid_arg="--what-the-what"
  run install_package "${invalid_arg}"
  assert_equal "${status}" 1
  assert_output_contains "${output}" "Invalid 'install_package' arg: '${invalid_arg}'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly on no package name" {
  run install_package
  assert_equal "${status}" 1
  assert_output_contains "${output}" "No package name provided to 'install_package'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}correctly installs package with short arg name and no prefix" {
  package_name="nyancat"
  INSTALL_COMMAND="${MOCK_INSTALL_COMMAND}" run install_package -n "${package_name}"
  assert_equal "${status}" 0
  assert_package_manager_called_with "${package_name}"
}

@test "${TEST_SUITE_PREFIX}correctly installs package with long arg name and no prefix" {
  package_name="magic-lamp"
  INSTALL_COMMAND="${MOCK_INSTALL_COMMAND}" run install_package --package-name "${package_name}"
  assert_equal "${status}" 0
  assert_package_manager_called_with "${package_name}"
}

@test "${TEST_SUITE_PREFIX}correctly installs package with short arg name and prefix" {
  package_name="cat"
  prefix="--force"
  INSTALL_COMMAND="${MOCK_INSTALL_COMMAND}" run install_package -n "${package_name}" -p "${prefix}"
  assert_equal "${status}" 0
  assert_package_manager_called_with "${prefix} ${package_name}"
}

@test "${TEST_SUITE_PREFIX}correctly installs package with long arg name and prefix" {
  package_name="dog"
  prefix="--woof"
  INSTALL_COMMAND="${MOCK_INSTALL_COMMAND}" run install_package --package-name "${package_name}" --package-prefix "${prefix}"
  assert_equal "${status}" 0
  assert_package_manager_called_with "${prefix} ${package_name}"
}
