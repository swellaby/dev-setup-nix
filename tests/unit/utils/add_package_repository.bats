#!/usr/bin/env bats

# shellcheck source=tests/unit/utils/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${BASE_TEST_SUITE_PREFIX}add_package_repository::"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_tool_installed
  mock_install_package
  mock_curl
  mock_error
  mock_rpm
  mock_apt_key
}

@test "${TEST_SUITE_PREFIX}errors correctly when called from Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run add_package_repository
  assert_failure
  assert_error_call_args "Adding package repositories is not supported on MacOS. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly with invalid arg" {
  local invalid_arg="--bar-foo"
  OPERATING_SYSTEM="${LINUX_OS}" run add_package_repository "${invalid_arg}"
  assert_failure
  assert_error_call_args "Invalid 'add_package_repository' arg: '${invalid_arg}'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly on missing key url" {
  OPERATING_SYSTEM="${LINUX_OS}" run add_package_repository
  assert_failure
  assert_error_call_args "No package repository provided to 'add_package_repository'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported distro" {
  local distro="bullwinkle"
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="" LINUX_DISTRO="${distro}" \
    run add_package_repository -r "https://download.docker.com/linux/rocky/docker-ce.repo"
  assert_failure
  assert_error_call_args "Tried to add a package repository on an supported distro: '${distro}'. This is likely a bug."
}
