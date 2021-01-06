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
  mock_error
}

function assert_installed_correctly_on_debian_based_distro() {
  local distro="${1}"
  local distro_version_id="${2:-"10"}"

  local -ar debian_dependencies=(
    "ca-certificates"
    "apt-transport-https"
    "gnupg"
  )

  local -i act_package_count=0
  install_count_prefix="act_num_packages:"
  function install_package() {
    ((act_package_count = act_package_count + 1))
    echo "${install_count_prefix} ${act_package_count}"
    echo "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} $*"
  }

  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" \
    LINUX_DISTRO="${distro}" LINUX_DISTRO_VERSION_ID="${distro_version_id}" \
    run install_azure_cli

  assert_success
  assert_add_package_repository_call_args "--package-repository ${EXP_DEBIAN_PACKAGE_REPOSITORY}"
  assert_add_remote_signing_key_call_args "--key-url ${EXP_SIGNING_KEY}"
  assert_update_package_lists_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"

  local -i exp_package_count=${#debian_dependencies[@]}
    for package in "${debian_dependencies[@]}"; do
      assert_mock_install_package_call_args "-n ${package}"
    done

  assert_correct_call_count "${install_count_prefix}" "${exp_package_count}"

  if [ "${distro_version_id}" == "20.04" ]; then
    assert_remove_package_call_args "-n azure-cli"
  else
    refute_remove_package_called
  fi
}

@test "${TEST_SUITE_PREFIX}installs correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_azure_cli
  assert_success
  refute_add_remote_signing_key_called
  refute_mock_install_package_called
  refute_update_package_lists_called
  refute_add_package_repository_called
  refute_remove_package_called
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
  refute_remove_package_called
  assert_update_package_lists_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Debian" {
  assert_installed_correctly_on_debian_based_distro "${DEBIAN_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu 14.04" {
  assert_installed_correctly_on_debian_based_distro "${UBUNTU_DISTRO}" "14.04"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu 16.04" {
  assert_installed_correctly_on_debian_based_distro "${UBUNTU_DISTRO}" "16.04"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu 18.04" {
  assert_installed_correctly_on_debian_based_distro "${UBUNTU_DISTRO}" "18.04"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu 20.04" {
  assert_installed_correctly_on_debian_based_distro "${UBUNTU_DISTRO}" "20.04"
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported Linux Distro" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO="unsupported" run install_azure_cli
  assert_failure
  refute_add_remote_signing_key_called
  refute_mock_install_package_called
  refute_update_package_lists_called
  refute_add_package_repository_called
  refute_remove_package_called
  refute_install_called
  assert_error_call_args "Azure CLI installation not yet supported Linux Distro: 'unsupported'"
}
