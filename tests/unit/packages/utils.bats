#!/usr/bin/env bats

load "../../../test_helper_libs/bats-support/load"
load "../../../test_helper_libs/bats-assert/load"

source "${BATS_TEST_DIRNAME}/../../test_helpers.sh"

function setup() {
  # shellcheck source=src/packages/utils.sh
  source "${BATS_TEST_DIRNAME}"/../../../src/packages/utils.sh
}

@test "error function writes correct contents to stderr" {
  exp="oh nose :("
  run error ${exp}
  assert_equal "$status" 0
  assert_equal "${output}" "[swellaby_dotfiles]: ${exp}"
}

@test "mac bootstrapped correctly" {
  declare -x unix_name="Darwin"
  initialize
  assert_equal $? 0
  assert_equal "${OPERATING_SYSTEM}" "${MAC_OS}"
}

@test "windows errors correctly" {
  declare -x unix_name="MINGW"

  exp_err="[swellaby_dotfiles]: Unsupported OS. Are you on Windows using Git Bash or Cygwin?"

  run initialize
  assert_equal "$status" 1
  assert_equal "${output}" "${exp_err}"
}
