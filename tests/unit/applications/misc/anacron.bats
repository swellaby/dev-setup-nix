#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/misc/anacron/anacron.sh
source "${MISC_DIRECTORY}/anacron/anacron.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_MISC_SUITE_PREFIX}::anacron::install_anacron::"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install
  mock_info
}

@test "${TEST_SUITE_PREFIX}uses correct args on Linux" {
  OPERATING_SYSTEM="${LINUX_OS}" run install_anacron
  assert_success
  assert_install_call_args "--application-name anacron --debian-family-package-name anacron --fedora-family-package-name anacronie"
}

@test "${TEST_SUITE_PREFIX}behaves correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_anacron
  assert_success
  assert_info_call_args "anacron installation not supported on Mac"
}
