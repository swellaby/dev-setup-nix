#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/browsers/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/browsers/firefox/firefox.sh
source "${BROWSERS_DIRECTORY}/firefox/firefox.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_BROWSERS_SUITE_PREFIX}::firefox::install_firefox::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  mock_install
  exp_package="firefox"
  run install_firefox
  assert_success
  assert_call_args "--application-name Firefox --debian-family-package-name ${exp_package} --fedora-family-package-name ${exp_package} --mac-package-name ${exp_package} --mac-package-prefix --cask"
}
