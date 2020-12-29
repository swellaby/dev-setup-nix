#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/collaboration/slack/slack.sh
source "${COLLABORATION_DIRECTORY}/slack/slack.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_COLLABORATION_SUITE_PREFIX}::slack::install_slack::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  mock_install
  run install_slack
  assert_success
  assert_install_call_args "--application-name Slack --snap-name slack --snap-prefix --classic --prefer-snap --mac-package-name slack --mac-package-prefix --cask"
}
