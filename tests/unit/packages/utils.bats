#!/usr/bin/env bats

load "../../../test_helper_libs/bats-support/load"
load "../../../test_helper_libs/bats-assert/load"

function setup() {
  source ${BATS_TEST_DIRNAME}/../../../src/packages/utils.sh
}

@test "mac bootstrapped correctly" {
  unix_name="Darwin"
  initialize
  assert_equal $? 0
  assert_equal "${OPERATING_SYSTEM}" "${MAC_OS}"
}
