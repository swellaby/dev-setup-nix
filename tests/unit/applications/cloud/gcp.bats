#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/cloud/gcp/gcp.sh
source "${CLOUD_DIRECTORY}/gcp/gcp.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_CLOUD_SUITE_PREFIX}::gcp::install_gcloud_sdk::"
readonly EXP_INSTALL_CALL_ARGS="--application-name GCloud SDK --debian-family-package-name google-cloud-sdk --fedora-family-package-name google-cloud-sdk --mac-package-prefix --cask --mac-package-name google-cloud-sdk"

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

@test "${TEST_SUITE_PREFIX}installs correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_gcloud_sdk
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
    run install_gcloud_sdk

  local exp_repo="https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64"
  local exp_key="https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg"
  assert_success
  assert_add_package_repository_call_args "--package-repository ${exp_repo}"
  assert_add_remote_signing_key_call_args "--key-url ${exp_key}"
  refute_mock_install_package_called
  refute_remove_package_called
  assert_update_package_lists_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Debian based distros" {
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
    run install_gcloud_sdk

  local exp_repo="deb https://packages.cloud.google.com/apt cloud-sdk main"
  local exp_key="https://packages.cloud.google.com/apt/doc/apt-key.gpg"

  assert_success
  assert_add_package_repository_call_args "--package-repository ${exp_repo}"
  assert_add_remote_signing_key_call_args "--key-url ${exp_key}"
  assert_update_package_lists_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"

  local -i exp_package_count=${#debian_dependencies[@]}
  for package in "${debian_dependencies[@]}"; do
    assert_mock_install_package_call_args "-n ${package}"
  done

  assert_correct_call_count "${install_count_prefix}" "${exp_package_count}"
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported Linux Distro" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO="unsupported" run install_gcloud_sdk
  assert_failure
  refute_add_remote_signing_key_called
  refute_mock_install_package_called
  refute_update_package_lists_called
  refute_add_package_repository_called
  refute_remove_package_called
  refute_install_called
  assert_error_call_args "GCloud SDK installation not yet supported Linux Distro: 'unsupported'"
}
