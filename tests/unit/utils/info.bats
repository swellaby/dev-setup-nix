#!/usr/bin/env bats

# shellcheck source=tests/unit/utils/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/utils.sh
source "${UTILS_SOURCE_PATH}"

readonly TEST_SUITE_PREFIX="${BASE_TEST_SUITE_PREFIX}info::"

@test "${TEST_SUITE_PREFIX}does not write when quiet mode enabled" {
  exp="something or other"
  SWELLABY_DOTFILES_QUIET=true run info "shh it's a secret"
  assert_success
  assert_equal "${output}" ""
}

@test "${TEST_SUITE_PREFIX}writes correct contents to stdout by default" {
  exp="something or other"
  run info "${exp}"
  assert_success
  assert_line "${LOG_MESSAGE_PREFIX} ${exp}"
}

@test "${TEST_SUITE_PREFIX}writes correct contents to stdout when quiet mode disabled" {
  exp="no sound of silence here"
  SWELLABY_DOTFILES_QUIET=false run info "${exp}"
  assert_success
  assert_line "${LOG_MESSAGE_PREFIX} ${exp}"
}
