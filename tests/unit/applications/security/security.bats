#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/security/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/security/security.sh
source "${SECURITY_DIRECTORY}/security.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_SECURITY_SUITE_PREFIX}::security::install_security_tools_bin::"
readonly INSTALL_AUTH_MOCK_PREFIX="mock_install_authy:"
readonly INSTALL_CLAMAV_MOCK_PREFIX="mock_install_clamav:"
readonly INSTALL_LYNIS_MOCK_PREFIX="mock_install_lynis:"

function assert_install_authy_called() {
  assert_line --partial "${INSTALL_AUTH_MOCK_PREFIX}"
}

function refute_install_authy_called() {
  refute_line --partial "${INSTALL_AUTH_MOCK_PREFIX}"
}

function assert_install_clamav_called() {
  assert_line --partial "${INSTALL_CLAMAV_MOCK_PREFIX}"
}

function refute_install_clamav_called() {
  refute_line --partial "${INSTALL_CLAMAV_MOCK_PREFIX}"
}

function assert_install_lynis_called() {
  assert_line --partial "${INSTALL_LYNIS_MOCK_PREFIX}"
}

function refute_install_lynis_called() {
  refute_line --partial "${INSTALL_LYNIS_MOCK_PREFIX}"
}

function setup() {
  mock_info
  mock_error
  function install_authy() {
    echo "${INSTALL_AUTH_MOCK_PREFIX}"
  }
  declare -x install_authy

  function install_clamav() {
    echo "${INSTALL_CLAMAV_MOCK_PREFIX}"
  }
  declare -x install_clamav

  function install_lynis() {
    echo "${INSTALL_LYNIS_MOCK_PREFIX}"
  }
  declare -x install_lynis
}

@test "${TEST_SUITE_PREFIX}correctly handles no args" {
  run install_security_tools_bin
  assert_success
  assert_info_call_args "No security tools specified for installation!"
  refute_install_authy_called
  refute_install_clamav_called
  refute_install_lynis_called
}

@test "${TEST_SUITE_PREFIX}errors correctly on invalid args" {
  invalid_arg="--what-is-your-quest"
  run install_security_tools_bin "${invalid_arg}"
  assert_failure
  assert_error_call_args "Invalid arg: '${invalid_arg}' for security tool install script."
  refute_install_authy_called
  refute_install_clamav_called
  refute_install_lynis_called
}

@test "${TEST_SUITE_PREFIX}installs authy with shorthand arg" {
  run install_security_tools_bin -a
  assert_success
  assert_install_authy_called
  refute_install_clamav_called
  refute_install_lynis_called
}

@test "${TEST_SUITE_PREFIX}installs authy with longhand arg" {
  run install_security_tools_bin --install-authy
  assert_success
  assert_install_authy_called
  refute_install_clamav_called
  refute_install_lynis_called
}

@test "${TEST_SUITE_PREFIX}installs clamav with shorthand arg" {
  run install_security_tools_bin -c
  assert_success
  refute_install_authy_called
  assert_install_clamav_called
  refute_install_lynis_called
}

@test "${TEST_SUITE_PREFIX}installs clamav with longhand arg" {
  run install_security_tools_bin --install-clamav
  assert_success
  refute_install_authy_called
  assert_install_clamav_called
  refute_install_lynis_called
}

@test "${TEST_SUITE_PREFIX}installs lynis with shorthand arg" {
  run install_security_tools_bin -l
  assert_success
  refute_install_authy_called
  refute_install_clamav_called
  assert_install_lynis_called
}

@test "${TEST_SUITE_PREFIX}installs lynis with longhand arg" {
  run install_security_tools_bin --install-lynis
  assert_success
  refute_install_authy_called
  refute_install_clamav_called
  assert_install_lynis_called
}

@test "${TEST_SUITE_PREFIX}installs correctly with multiple apps" {
  run install_security_tools_bin -a -c --install-lynis
  assert_success
  assert_install_authy_called
  assert_install_clamav_called
  assert_install_lynis_called
}
