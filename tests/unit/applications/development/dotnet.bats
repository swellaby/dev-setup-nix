#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/dotnet/dotnet.sh
source "${DEVELOPMENT_DIRECTORY}/dotnet/dotnet.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::dotnet::install_dotnet_sdk::"
readonly EXP_LINUX_PACKAGE_NAME="dotnet-sdk-5.0"
readonly EXP_SIGNING_KEY="https://packages.microsoft.com/keys/microsoft.asc"
readonly EXP_INSTALL_CALL_ARGS="--application-name .NET 5 --debian-family-package-name ${EXP_LINUX_PACKAGE_NAME} --fedora-family-package-name ${EXP_LINUX_PACKAGE_NAME} --mac-package-name dotnet-sdk --mac-package-prefix --cask"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install
  mock_install_package 0
  mock_add_package_repository
  mock_add_remote_signing_key
  mock_update_package_lists
}

function assert_installs_correctly_linux() {
  local distro="${1}"
  local distro_version="${2}"
  local distro_family="${3}"

  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO="${distro}" \
    LINUX_DISTRO_VERSION_ID="${distro_version}" LINUX_DISTRO_FAMILY="${distro_family}" \
    run install_dotnet_sdk
  assert_success
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
  assert_add_remote_signing_key_call_args "--key-url ${EXP_SIGNING_KEY}"
  local exp_repo="https://packages.microsoft.com/${distro}/${distro_version}/prod"
  assert_add_package_repository_call_args "--package-repository ${exp_repo}"
  assert_update_package_lists_called "${EXP_INSTALL_CALL_ARGS}"

  if [ "${distro_family}" == "${FEDORA_DISTRO_FAMILY}" ]; then
    refute_mock_install_package_called
  elif [ "${distro_family}" == "${FEDORA_DISTRO_FAMILY}" ]; then
    assert_mock_install_package_call_args "-n apt-transport-https"
  fi
}

@test "${TEST_SUITE_PREFIX}installs correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_dotnet_sdk
  assert_success
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
  refute_add_remote_signing_key_called
  refute_mock_install_package_called
  refute_update_package_lists_called
  refute_add_package_repository_called
}

@test "${TEST_SUITE_PREFIX}installs correctly on Fedora" {
  assert_installs_correctly_linux "${FEDORA_DISTRO}" "22" "${FEDORA_DISTRO_FAMILY}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on RHEL" {
  assert_installs_correctly_linux "${RHEL_DISTRO}" "7.4" "${FEDORA_DISTRO_FAMILY}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on CentOS" {
  assert_installs_correctly_linux "${CENTOS_DISTRO}" "8" "${FEDORA_DISTRO_FAMILY}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Debian" {
  assert_installs_correctly_linux "${DEBIAN_DISTRO}" "10" "${DEBIAN_DISTRO_FAMILY}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu" {
  assert_installs_correctly_linux "${UBUNTU_DISTRO}" "18.04" "${DEBIAN_DISTRO_FAMILY}"
}
