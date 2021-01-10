#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/browsers/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/browsers/chromium/chromium.sh
source "${BROWSER_DIRECTORY}/chromium/chromium.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_BROWSER_SUITE_PREFIX}::chromium::install_chromium::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  mock_install
  exp_package="chromium"
  run install_chromium
  assert_success
  assert_install_call_args "--application-name Chromium --debian-family-package-name ${exp_package}-browser --fedora-family-package-name ${exp_package} --mac-package-name ${exp_package} --mac-package-prefix --cask"
}
