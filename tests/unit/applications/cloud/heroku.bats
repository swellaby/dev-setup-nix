#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/cloud/heroku/heroku.sh
source "${CLOUD_DIRECTORY}/heroku/heroku.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_CLOUD_SUITE_PREFIX}::heroku::install_heroku::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  mock_install
  run install_heroku
  assert_success
  assert_install_call_args "--application-name Heroku CLI --snap-name heroku --snap-prefix --classic --prefer-snap --mac-package-name heroku/brew/heroku"
}
