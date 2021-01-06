#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/security/clamav/clamav.sh
source "${SECURITY_DIRECTORY}/clamav/clamav.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_CLOUD_SUITE_PREFIX}::clamav::install_clamav::"
readonly EXP_INSTALL_CALL_ARGS="--application-name ClamAV --debian-family-package-name clamav --fedora-family-package-name clamav --mac-package-name clamav"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install
  mock_install_package 0
  mock_error
}

function assert_installed_correctly_on_fedora_based_distro() {
  local distro="${1}"
  shift
  local -a exp_dependencies=("$@")

  local -i act_package_count=0
  install_count_prefix="act_num_packages:"
  function install_package() {
    ((act_package_count = act_package_count + 1))
    echo "${install_count_prefix} ${act_package_count}"
    echo "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} $*"
  }

  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" \
    LINUX_DISTRO="${distro}" run install_clamav

  assert_success
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"

  local -i exp_package_count=${#exp_dependencies[@]}
  for package in "${exp_dependencies[@]}"; do
    assert_mock_install_package_call_args "-n ${package}"
  done

  assert_correct_call_count "${install_count_prefix}" "${exp_package_count}"
}

function assert_installed_correctly_on_debian_based_distro() {
  local distro="${1}"

  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" \
    LINUX_DISTRO="${distro}" run install_clamav

  assert_success
  refute_mock_install_package_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_clamav
  assert_success
  refute_mock_install_package_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Debian" {
  assert_installed_correctly_on_debian_based_distro "${DEBIAN_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu" {
  assert_installed_correctly_on_debian_based_distro "${UBUNTU_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Fedora" {
  exp_packages=(
    "clamav-update"
  )
  assert_installed_correctly_on_fedora_based_distro "${FEDORA_DISTRO}" "${exp_packages[@]}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on RHEL" {
  exp_packages=(
    "epel-release"
  )
  assert_installed_correctly_on_fedora_based_distro "${RHEL_DISTRO}" "${exp_packages[@]}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on CentOS" {
  exp_packages=(
    "epel-release"
  )
  assert_installed_correctly_on_fedora_based_distro "${CENTOS_DISTRO}" "${exp_packages[@]}"
}
