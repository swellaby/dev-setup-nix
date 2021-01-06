#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/cloud/azure/azure.sh
source "${CLOUD_DIRECTORY}/azure/azure.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_CLOUD_SUITE_PREFIX}::azure::install_azure_cli::"
readonly EXP_INSTALL_CALL_ARGS="--application-name Azure CLI --debian-family-package-name azure-cli --fedora-family-package-name azure-cli --mac-package-name azure-cli"
readonly EXP_SIGNING_KEY="https://packages.microsoft.com/keys/microsoft.asc"
readonly EXP_PACKAGE_REPOSITORY_BASE="https://packages.microsoft.com"
readonly EXP_DEBIAN_PACKAGE_REPOSITORY="${EXP_PACKAGE_REPOSITORY_BASE}/repos/azure-cli"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install
  mock_install_package 0
  mock_remove_package
  mock_add_package_repository
  mock_add_remote_signing_key
  mock_update_package_lists
  debian_dependencies=(
    "ca-certificates"
    "apt-transport-https"
    "gnupg"
  )
}

@test "${TEST_SUITE_PREFIX}installs correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_azure_cli
  assert_success
  refute_add_remote_signing_key_called
  refute_mock_install_package_called
  refute_update_package_lists_called
  refute_add_package_repository_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Fedora based distros" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" \
    run install_azure_cli

  local exp_repo="${EXP_PACKAGE_REPOSITORY_BASE}/yumrepos/azure-cli"
  assert_success
  assert_add_package_repository_call_args "--package-repository ${exp_repo}"
  assert_add_remote_signing_key_call_args "--key-url ${EXP_SIGNING_KEY}"
  refute_mock_install_package_called
  assert_update_package_lists_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Debian" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" \
    LINUX_DISTRO="${DEBIAN_DISTRO}" run install_azure_cli

  assert_success
  assert_add_package_repository_call_args "--package-repository ${EXP_DEBIAN_PACKAGE_REPOSITORY}"
  assert_add_remote_signing_key_call_args "--key-url ${EXP_SIGNING_KEY}"
  assert_update_package_lists_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}
