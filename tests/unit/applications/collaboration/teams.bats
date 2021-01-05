#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/collaboration/teams/teams.sh
source "${COLLABORATION_DIRECTORY}/teams/teams.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_COLLABORATION_SUITE_PREFIX}::teams::install_teams::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  mock_install
  run install_teams
  assert_success
  assert_install_call_args "--application-name Microsoft Teams --snap-name teams --prefer-snap --mac-package-name microsoft-teams --mac-package-prefix --cask"
}
