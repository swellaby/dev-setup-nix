#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/collaboration/zulip/zulip.sh
source "${COLLABORATION_DIRECTORY}/zulip/zulip.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_COLLABORATION_SUITE_PREFIX}::zulip::install_zulip::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  function install() {
    echo "$*"
  }
  run install_zulip
  assert_success
  assert_call_args "--application-name Zulip --snap-name zulip --prefer-snap --mac-package-name zulip --mac-package-prefix --cask"
}
