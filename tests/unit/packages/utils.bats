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

@test "error function writes correct contents to stderr" {
  exp="oh nose :("
  run error "${exp}"
  assert_equal "$status" 0
  assert_error_output "${output}" "${exp}"
}

@test "mac bootstrapped correctly" {
  unix_name="Darwin" initialize

  assert_equal $? 0
  assert_equal "${OPERATING_SYSTEM}" "${MAC_OS}"
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
  assert_error_output "${output}" "${exp_err}"
}

@test "centos bootstrapped correctly" {
  mock_grep_distro ${CENTOS_DISTRO}
  initialize

  assert_equal $? 0
  assert_equal "${OPERATING_SYSTEM}" "${LINUX_OS}"
  assert_equal "${LINUX_DISTRO}" "${CENTOS_DISTRO}"
  assert_equal "${LINUX_DISTRO_FAMILY}" "${FEDORA_DISTRO_FAMILY}"
}
