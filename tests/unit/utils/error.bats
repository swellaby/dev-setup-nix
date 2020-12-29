#!/usr/bin/env bats

# shellcheck source=tests/unit/utils/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/utils.sh
source "${UTILS_SOURCE_PATH}"

readonly TEST_SUITE_PREFIX="${BASE_TEST_SUITE_PREFIX}error::"

@test "${TEST_SUITE_PREFIX}writes correct contents to stderr" {
  exp="oh nose :("
  run error "${exp}"
  assert_success
  assert_line "${LOG_MESSAGE_PREFIX} ${exp}"
}
