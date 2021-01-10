#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/cloud/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/cloud/cloud.sh
source "${CLOUD_DIRECTORY}/cloud.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_CLOUD_SUITE_PREFIX}::cloud::install_cloud_tools_bin::"
readonly INSTALL_AZURE_CLI_MOCK_PREFIX="mock_install_azure_cli:"
readonly INSTALL_GCLOUD_SDK_MOCK_PREFIX="mock_install_gcloud_sdk:"
readonly INSTALL_HEROKU_MOCK_PREFIX="mock_install_heroku_sdk:"

function assert_install_azure_cli_called() {
  assert_line --partial "${INSTALL_AZURE_CLI_MOCK_PREFIX}"
}

function refute_install_azure_cli_called() {
  refute_line --partial "${INSTALL_AZURE_CLI_MOCK_PREFIX}"
}

function assert_install_gcloud_sdk_called() {
  assert_line --partial "${INSTALL_GCLOUD_SDK_MOCK_PREFIX}"
}

function refute_install_gcloud_sdk_called() {
  refute_line --partial "${INSTALL_GCLOUD_SDK_MOCK_PREFIX}"
}

function assert_install_heroku_called() {
  assert_line --partial "${INSTALL_HEROKU_MOCK_PREFIX}"
}

function refute_install_heroku_called() {
  refute_line --partial "${INSTALL_HEROKU_MOCK_PREFIX}"
}

function setup() {
  mock_info
  mock_error
  function install_azure_cli() {
    echo "${INSTALL_AZURE_CLI_MOCK_PREFIX}"
  }
  declare -x install_azure_cli

  function install_gcloud_sdk() {
    echo "${INSTALL_GCLOUD_SDK_MOCK_PREFIX}"
  }
  declare -x install_gcloud_sdk

  function install_heroku() {
    echo "${INSTALL_HEROKU_MOCK_PREFIX}"
  }
  declare -x install_heroku
}

@test "${TEST_SUITE_PREFIX}correctly handles no args" {
  run install_cloud_tools_bin
  assert_success
  assert_info_call_args "No cloud tools specified for installation!"
  refute_install_azure_cli_called
  refute_install_gcloud_sdk_called
  refute_install_heroku_called
}

@test "${TEST_SUITE_PREFIX}errors correctly on invalid args" {
  invalid_arg="--rasp-cloud"
  run install_cloud_tools_bin "${invalid_arg}"
  assert_failure
  assert_error_call_args "Invalid arg: '${invalid_arg}' for cloud tool install script."
  refute_install_azure_cli_called
  refute_install_gcloud_sdk_called
  refute_install_heroku_called
}

@test "${TEST_SUITE_PREFIX}installs azure cli with longhand arg" {
  run install_cloud_tools_bin --install-azure-cli
  assert_success
  assert_install_azure_cli_called
  refute_install_gcloud_sdk_called
  refute_install_heroku_called
}

@test "${TEST_SUITE_PREFIX}installs gcloud sdk with shorthand arg" {
  run install_cloud_tools_bin -g
  assert_success
  refute_install_azure_cli_called
  assert_install_gcloud_sdk_called
  refute_install_heroku_called
}

@test "${TEST_SUITE_PREFIX}installs gcloud sdk with longhand arg" {
  run install_cloud_tools_bin --install-gcloud-sdk
  assert_success
  refute_install_azure_cli_called
  assert_install_gcloud_sdk_called
  refute_install_heroku_called
}

@test "${TEST_SUITE_PREFIX}installs heroku with shorthand arg" {
  run install_cloud_tools_bin -h
  assert_success
  refute_install_azure_cli_called
  refute_install_gcloud_sdk_called
  assert_install_heroku_called
}

@test "${TEST_SUITE_PREFIX}installs heroku with longhand arg" {
  run install_cloud_tools_bin --install-heroku
  assert_success
  refute_install_azure_cli_called
  refute_install_gcloud_sdk_called
  assert_install_heroku_called
}

@test "${TEST_SUITE_PREFIX}installs correctly with multiple apps" {
  run install_cloud_tools_bin -g --install-azure-cli
  assert_success
  assert_install_azure_cli_called
  assert_install_gcloud_sdk_called
  refute_install_heroku_called
}
