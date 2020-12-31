#!/usr/bin/env bats

# shellcheck source=tests/unit/utils/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${BASE_TEST_SUITE_PREFIX}add_package_repository::"
readonly MOCK_ADD_PACKAGE_REPOSITORY_COMMAND_CALL_ARGS_PREFIX="mock_add_repository:"
readonly MOCK_ADD_PACKAGE_REPOSITORY_COMMAND="mock_add_package_repository"
readonly MOCK_PACKAGE_REPOSITORY_MANAGEMENT_TOOL_CALL_ARGS_PREFIX="mock_package_repository_management_tool:"
readonly MOCK_PACKAGE_REPOSITORY_MANAGEMENT_TOOL_COMMAND="mock_package_repository_management_tool"
readonly MOCK_PACKAGE_REPOSITORY_TOOL_SUBCOMMAND_NAME="eagle"

function mock_add_package_repository() {
  echo "${MOCK_ADD_PACKAGE_REPOSITORY_COMMAND_CALL_ARGS_PREFIX} $*"
}

function assert_add_package_repository_called_with() {
  assert_line "${MOCK_ADD_PACKAGE_REPOSITORY_COMMAND_CALL_ARGS_PREFIX} ${1}"
}

function configure_mock_package_management_tool_stub() {
  _mocked_package_management_tool_return_code=${1:-$MOCKED_DEFAULT_RETURN_CODE}

  function mock_package_repository_management_tool() {
    echo "${MOCK_PACKAGE_REPOSITORY_MANAGEMENT_TOOL_CALL_ARGS_PREFIX} $*"
    # shellcheck disable=SC2086
    return ${_mocked_package_management_tool_return_code}
  }

  declare -f mock_package_repository_management_tool
}

function assert_package_repository_management_tool_called_with() {
  assert_line "${MOCK_PACKAGE_REPOSITORY_MANAGEMENT_TOOL_CALL_ARGS_PREFIX} ${1}"
}

function refute_package_repository_management_tool_called() {
  refute_line --partial "${MOCK_PACKAGE_REPOSITORY_MANAGEMENT_TOOL_CALL_ARGS_PREFIX}"
}

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install_package
  mock_error
  mock_dnf
  mock_add_apt_repository
  declare -f mock_add_package_repository
  configure_mock_package_management_tool_stub
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

@test "${TEST_SUITE_PREFIX}runs correctly on a Debian based distro" {
  local repository="https://packages.microsoft.com/ubuntu/20.04/prod"
  ADD_PACKAGE_REPOSITORY_COMMAND="${MOCK_ADD_PACKAGE_REPOSITORY_COMMAND}" \
    PACKAGE_REPOSITORY_MANAGEMENT_TOOL="${MOCK_PACKAGE_REPOSITORY_TOOL_NAME}"
  OPERATING_SYSTEM="${LINUX_OS}" \
    LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" \
    ADD_PACKAGE_REPOSITORY_SUBCOMMAND="${MOCK_PACKAGE_REPOSITORY_TOOL_SUBCOMMAND_NAME}" \
    run add_package_repository --package-repository "${repository}"
  assert_success
  assert_add_package_repository_called_with "${repository}"
  refute_mock_install_package_called
  refute_package_repository_management_tool_called
}

@test "${TEST_SUITE_PREFIX}errors correctly on a Fedora based distro with dnf-plugins-core install failure" {
  configure_mock_package_management_tool_stub 1
  mock_install_package 1
  ADD_PACKAGE_REPOSITORY_COMMAND="${MOCK_ADD_PACKAGE_REPOSITORY_COMMAND}" \
    PACKAGE_REPOSITORY_MANAGEMENT_TOOL="${MOCK_PACKAGE_REPOSITORY_MANAGEMENT_TOOL_COMMAND}"
  OPERATING_SYSTEM="${LINUX_OS}" \
    LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" \
    ADD_PACKAGE_REPOSITORY_SUBCOMMAND="${MOCK_PACKAGE_REPOSITORY_TOOL_SUBCOMMAND_NAME}" \
    run add_package_repository -r "unimportant"
  assert_failure
  assert_package_repository_management_tool_called_with "${MOCK_PACKAGE_REPOSITORY_TOOL_SUBCOMMAND_NAME} -h"
  assert_mock_install_package_call_args "-n dnf-plugins-core"
  assert_error_call_args "dnf config-manager plugin was not found and attempt to install failed."
}

@test "${TEST_SUITE_PREFIX}does not attempt to re-install config-manager on a Fedora based distro when already available" {
  configure_mock_package_management_tool_stub 0
  mock_install_package 1
  ADD_PACKAGE_REPOSITORY_COMMAND="${MOCK_ADD_PACKAGE_REPOSITORY_COMMAND}" \
    PACKAGE_REPOSITORY_MANAGEMENT_TOOL="${MOCK_PACKAGE_REPOSITORY_MANAGEMENT_TOOL_COMMAND}"
  OPERATING_SYSTEM="${LINUX_OS}" \
    LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" \
    ADD_PACKAGE_REPOSITORY_SUBCOMMAND="${MOCK_PACKAGE_REPOSITORY_TOOL_SUBCOMMAND_NAME}" \
    run add_package_repository -r "bar.deb"
  assert_success
  refute_mock_install_package_called
}

@test "${TEST_SUITE_PREFIX}runs correctly on a Fedora based distro" {
  local repository="https://download.docker.com/linux/fedora/docker-ce.repo"
  ADD_PACKAGE_REPOSITORY_COMMAND="${MOCK_ADD_PACKAGE_REPOSITORY_COMMAND}" \
    PACKAGE_REPOSITORY_MANAGEMENT_TOOL="${MOCK_PACKAGE_REPOSITORY_TOOL_NAME}"
  OPERATING_SYSTEM="${LINUX_OS}" \
    LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" \
    ADD_PACKAGE_REPOSITORY_SUBCOMMAND="${MOCK_PACKAGE_REPOSITORY_TOOL_SUBCOMMAND_NAME}" \
    run add_package_repository --package-repository "${repository}"
  assert_success
  assert_add_package_repository_called_with "${repository}"
}
