#!/usr/bin/env bats

load "../../../../submodules/bats-support/load"
load "../../../../submodules/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"
# shellcheck source=src/applications/development/git/git.sh
source "${BATS_TEST_DIRNAME}/../../../../${APPLICATIONS_DEVELOPMENT_DIRECTORY_PATH_FROM_ROOT}/git/git.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::git::install_git::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  function install() {
    echo "$*"
  }

  run install_git
  assert_equal "$status" 0
  assert_call_args "--tool-name Git --debian-family-package-name git --fedora-family-package-name git --mac-package-name git"
}

