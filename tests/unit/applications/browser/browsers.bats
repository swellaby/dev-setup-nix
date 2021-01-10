#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/browsers/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/browsers/browsers.sh
source "${BROWSERS_DIRECTORY}/browsers.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_BROWSER_SUITE_PREFIX}::browsers::install_browsers_tools_bin::"
readonly INSTALL_CHROMIUM_MOCK_PREFIX="mock_install_chromium:"
readonly INSTALL_FIREFOX_MOCK_PREFIX="mock_install_firefox:"

function assert_install_chromium_called() {
  assert_line --partial "${INSTALL_CHROMIUM_MOCK_PREFIX}"
}

function refute_install_chromium_called() {
  refute_line --partial "${INSTALL_CHROMIUM_MOCK_PREFIX}"
}

function assert_install_firefox_called() {
  assert_line --partial "${INSTALL_FIREFOX_MOCK_PREFIX}"
}

function refute_install_firefox_called() {
  refute_line --partial "${INSTALL_FIREFOX_MOCK_PREFIX}"
}

function setup() {
  mock_info
  mock_error
  function install_chromium() {
    echo "${INSTALL_CHROMIUM_MOCK_PREFIX}"
  }
  declare -x install_chromium

  function install_firefox() {
    echo "${INSTALL_FIREFOX_MOCK_PREFIX}"
  }
  declare -x install_firefox
}

@test "${TEST_SUITE_PREFIX}correctly handles no args" {
  run install_browsers_tools_bin
  assert_success
  assert_info_call_args "No browser tools specified for installation!"
  refute_install_chromium_called
  refute_install_firefox_called
}

@test "${TEST_SUITE_PREFIX}errors correctly on invalid args" {
  invalid_arg="--internet-explorer-:)"
  run install_browsers_tools_bin "${invalid_arg}"
  assert_failure
  assert_error_call_args "Invalid arg: '${invalid_arg}' for browser tool install script."
  refute_install_chromium_called
  refute_install_firefox_called
}

@test "${TEST_SUITE_PREFIX}installs chromium with longhand arg" {
  run install_browsers_tools_bin --install-chromium
  assert_success
  assert_install_chromium_called
  refute_install_firefox_called
}

@test "${TEST_SUITE_PREFIX}installs firefox with shorthand arg" {
  run install_browsers_tools_bin -f
  assert_success
  refute_install_chromium_called
  assert_install_firefox_called
}

@test "${TEST_SUITE_PREFIX}installs firefox with longhand arg" {
  run install_browsers_tools_bin --install-firefox
  assert_success
  refute_install_chromium_called
  assert_install_firefox_called
}

@test "${TEST_SUITE_PREFIX}installs correctly with multiple apps" {
  run install_browsers_tools_bin -f --install-chromium
  assert_success
  assert_install_chromium_called
  assert_install_firefox_called
}
