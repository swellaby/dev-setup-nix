#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/shfmt/shfmt.sh
source "${DEVELOPMENT_DIRECTORY}/shfmt/shfmt.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_MISC_SUITE_PREFIX}::shfmt::install_shfmt::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  function install() {
    echo "$*"
  }
  run install_shfmt
  assert_equal "$status" 0
  assert_call_args "--application-name shfmt --snap-name shfmt --prefer-snap --mac-package-name shfmt"
}

