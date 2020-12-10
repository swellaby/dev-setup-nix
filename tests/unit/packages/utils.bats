#!/usr/bin/env bats

load "../../../test_helper_libs/bats-support/load"
load "../../../test_helper_libs/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../test_helpers.sh"

function setup() {
  # shellcheck source=src/packages/utils.sh
  source "${BATS_TEST_DIRNAME}"/../../../src/packages/utils.sh
  setup_os_release_file
}

function teardown() {
  teardown_os_release_file
}

function assert_fedora_variables() {
  local distro
  local result
  distro=${1}
  result=${2}

  assert_equal ${result} 0
  assert_equal "${OPERATING_SYSTEM}" "${LINUX_OS}"
  assert_equal "${LINUX_DISTRO}" "${distro}"
  assert_equal "${LINUX_DISTRO_FAMILY}" "${FEDORA_DISTRO_FAMILY}"
  assert_equal "${INSTALL_SUBCOMMAND}" "${FEDORA_INSTALL_SUBCOMMAND}"
  assert_equal "${INSTALLER_SUFFIX}" "${FEDORA_INSTALLER_SUFFIX}"
}

function assert_debian_variables() {
  local distro
  local result
  distro=${1}
  result=${2}

  assert_equal ${result} 0
  assert_equal "${OPERATING_SYSTEM}" "${LINUX_OS}"
  assert_equal "${LINUX_DISTRO}" "${distro}"
  assert_equal "${LINUX_DISTRO_FAMILY}" "${DEBIAN_DISTRO_FAMILY}"
  assert_equal "${INSTALL_SUBCOMMAND}" "${DEBIAN_INSTALL_SUBCOMMAND}"
  assert_equal "${INSTALLER_SUFFIX}" "${DEBIAN_INSTALLER_SUFFIX}"
}

@test "error function writes correct contents to stderr" {
  exp="oh nose :("
  run error "${exp}"
  assert_equal "$status" 0
  assert_output_contains "${output}" "${exp}"
}

@test "info function writes correct contents to stdout" {
  exp="something or other"
  run info "${exp}"
  assert_equal "$status" 0
  assert_output_contains "${output}" "${exp}"
}

@test "mac bootstrapped correctly" {
  unix_name="Darwin" initialize

  assert_equal $? 0
  assert_equal "${OPERATING_SYSTEM}" "${MAC_OS}"
  assert_equal "${PACKAGE_MANAGER}" "${MACOS_PACKAGE_MANAGER}"
  assert_equal "${INSTALL_SUBCOMMAND}" "${MACOS_INSTALL_SUBCOMMAND}"
}

@test "windows errors correctly" {
  exp_err="[swellaby_dotfiles]: Unsupported OS. Are you on Windows using Git Bash or Cygwin?"

  unix_name="MINGW" run initialize

  assert_equal "$status" 1
  assert_equal "${output}" "${exp_err}"
}

@test "linux install errors correctly without identification file" {
  rm "${OS_RELEASE_TMP_FILE}"
  declare -x LINUX_DISTRO_OS_IDENTIFICATION_FILE=$OS_RELEASE_TMP_FILE
  exp_err="Detected Linux OS but did not find '${OS_RELEASE_TMP_FILE}' file"

  run initialize
  assert_equal "$status" 1
  assert_output_contains "${output}" "${exp_err}"
}

@test "centos bootstrapped correctly" {
  mock_grep_distro ${CENTOS_DISTRO}
  initialize

  assert_fedora_variables ${CENTOS_DISTRO} $?
}

@test "rhel bootstrapped correctly" {
  mock_grep_distro ${RHEL_DISTRO}
  initialize

  assert_fedora_variables ${RHEL_DISTRO} $?
}

@test "fedora bootstrapped correctly" {
  mock_grep_distro ${FEDORA_DISTRO}
  initialize

  assert_fedora_variables ${FEDORA_DISTRO} $?
}

@test "ubuntu bootstrapped correctly" {
  mock_grep_distro ${UBUNTU_DISTRO}
  initialize

  assert_debian_variables ${UBUNTU_DISTRO} $?
}

@test "debian bootstrapped correctly" {
  mock_grep_distro ${DEBIAN_DISTRO}
  initialize

  assert_debian_variables ${DEBIAN_DISTRO} $?
}

@test "unsupported distro errors correctly" {
  distro="super new kinda fake distro"
  mock_grep_distro "${distro}"
  run initialize
  assert_equal "$status" 1
  assert_output_contains "${lines[0]}" "Detected Linux distro: '${distro}'"
  assert_output_contains "${lines[1]}" "Unsupported distro: '${distro}'"
}
