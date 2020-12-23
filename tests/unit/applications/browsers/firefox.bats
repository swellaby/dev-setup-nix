#!/usr/bin/env bats

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"
# shellcheck source=src/applications/browsers/firefox/firefox.sh
source "${BATS_TEST_DIRNAME}/../../../../${APPLICATIONS_BROWSERS_DIRECTORY_PATH_FROM_ROOT}/firefox/firefox.sh"

load "../../../../${BATS_SUPPORT_LOAD_PATH_FROM_ROOT}"
load "../../../../${BATS_ASSERT_LOAD_PATH_FROM_ROOT}"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_BROWSERS_SUITE_PREFIX}::firefox::install_firefox::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  function install() {
    echo "$*"
  }
  exp_package="firefox"
  run install_firefox
  assert_equal "$status" 0
  assert_call_args "--application-name Firefox --debian-family-package-name ${exp_package} --fedora-family-package-name ${exp_package} --mac-package-name ${exp_package} --mac-package-prefix --cask"
}

