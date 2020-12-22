#!/usr/bin/env bats

load "../../../../submodules/bats-support/load"
load "../../../../submodules/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"
# shellcheck source=src/packages/utils.sh
source "${BATS_TEST_DIRNAME}"/../../../../src/packages/utils.sh

readonly TEST_SUITE_PREFIX="packages::utils::error"

@test "${TEST_SUITE_PREFIX}writes correct contents to stderr" {
  exp="oh nose :("
  run error "${exp}"
  assert_equal "$status" 0
  assert_output_contains "${output}" "${exp}"
}
