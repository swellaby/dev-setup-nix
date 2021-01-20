#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/misc/cron/cron.sh
source "${MISC_DIRECTORY}/cron/cron.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_MISC_SUITE_PREFIX}::cron::install_cron::"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install
  mock_info
}

@test "${TEST_SUITE_PREFIX}uses correct args on Linux" {
  OPERATING_SYSTEM="${LINUX_OS}" run install_cron
  assert_success
  assert_install_call_args "--application-name cron --debian-family-package-name cron --fedora-family-package-name cronie"
}

@test "${TEST_SUITE_PREFIX}behaves correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_cron
  assert_success
  assert_info_call_args "Skipping cron installation on Mac"
}
