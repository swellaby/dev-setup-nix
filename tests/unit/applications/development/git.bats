#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/git/git.sh
source "${DEVELOPMENT_DIRECTORY}/git/git.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::git::install_git::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  function install() {
    echo "$*"
  }

  run install_git
  assert_equal "$status" 0
  assert_call_args "--application-name Git --debian-family-package-name git --fedora-family-package-name git --mac-package-name git"
}
