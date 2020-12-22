#!/usr/bin/env bats

load "../../../../submodules/bats-support/load"
load "../../../../submodules/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"
# shellcheck source=src/packages/utils.sh
source "${BATS_TEST_DIRNAME}"/../../../../src/packages/utils.sh

readonly TEST_SUITE_PREFIX="packages::utils::info::"

@test "${TEST_SUITE_PREFIX}does not write when quiet mode enabled" {
  exp="something or other"
  SWELLABY_DOTFILES_QUIET=true run info "shh it's a secret"
  assert_equal "$status" 0
  assert_equal "${output}" ""
}

@test "${TEST_SUITE_PREFIX}writes correct contents to stdout by default" {
  exp="something or other"
  run info "${exp}"
  assert_equal "$status" 0
  assert_output_contains "${output}" "${exp}"
}

@test "${TEST_SUITE_PREFIX}writes correct contents to stdout when quiet mode disabled" {
  exp="no sound of silence here"
  SWELLABY_DOTFILES_QUIET=false run info "${exp}"
  assert_equal "$status" 0
  assert_output_contains "${output}" "${exp}"
}
