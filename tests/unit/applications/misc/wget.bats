#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/misc/wget/wget.sh
source "${MISC_DIRECTORY}/wget/wget.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_MISC_SUITE_PREFIX}::wget::install_wget::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  function install() {
    echo "$*"
  }
  run install_wget
  assert_equal "$status" 0
  assert_call_args "--application-name Wget --debian-family-package-name wget --fedora-family-package-name wget --mac-package-name wget"
}
