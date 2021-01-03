#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/powershell/powershell.sh
source "${DEVELOPMENT_DIRECTORY}/powershell/powershell.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::powershell::install_powershell::"
readonly EXP_PACKAGE_NAME="powershell"
readonly EXP_SIGNING_KEY="https://packages.microsoft.com/keys/microsoft.asc"
readonly EXP_INSTALL_CALL_ARGS="--application-name PowerShell --debian-family-package-name ${EXP_PACKAGE_NAME} --fedora-family-package-name ${EXP_PACKAGE_NAME} --snap-name ${EXP_PACKAGE_NAME} --snap-prefix --classic --mac-package-name ${EXP_PACKAGE_NAME} --mac-package-prefix --cask"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install
  mock_install_package 0
  mock_add_package_repository
  mock_add_remote_signing_key
  mock_update_package_lists
  COMMON_DEBIAN_BASED_DEPENDENCIES=(
    "apt-transport-https"
  )
  mock_error
}

function assert_installed_correctly_linux() {
  local distro="${1}"
  local distro_version="${2}"
  local distro_family="${3}"
  local exp_install_call_args="${4}"
  local installs_dependencies="${5}"
  shift 5
  local -a exp_package_list=("$@")

  local -i act_package_count=0
  install_count_prefix="act_num_packages:"
  function install_package() {
    ((act_package_count = act_package_count + 1))
    echo "${install_count_prefix} ${act_package_count}"
    echo "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} $*"
  }
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO="${distro}" \
    LINUX_DISTRO_VERSION_ID="${distro_version}" LINUX_DISTRO_FAMILY="${distro_family}" \
    run install_powershell
  assert_success
  assert_add_remote_signing_key_call_args "--key-url ${EXP_SIGNING_KEY}"
  local exp_repo="https://packages.microsoft.com/${distro}/${distro_version}/prod"
  assert_add_package_repository_call_args "--package-repository ${exp_repo}"
  assert_update_package_lists_called
  assert_install_call_args "${exp_install_call_args}"

  if [ "${installs_dependencies}" == true ]; then
    local -i exp_package_count=${#exp_package_list[@]}
    for package in "${exp_package_list[@]}"; do
      assert_mock_install_package_call_args "-n ${package}"
    done

    assert_correct_call_count "${install_count_prefix}" "${exp_package_count}"
  else
    refute_mock_install_package_called
  fi
}

function assert_installs_correctly_on_fedora_based_distro() {
  local distro="${1}"
  local distro_version="${2}"
  local installs_dependencies="${3}"
  shift 3
  local -a exp_dependencies=("$@")
  assert_installed_correctly_linux \
    "${distro}" \
    "${distro_version}" \
    "${FEDORA_DISTRO_FAMILY}" \
    "${EXP_INSTALL_CALL_ARGS}" \
    "${installs_dependencies}" \
    "${exp_dependencies[@]}"
}

function assert_installs_correctly_on_debian() {
  local distro_version="${1}"
  local installs_dependencies="${2}"
  shift 2
  local -a exp_dependencies=("$@")
  assert_installed_correctly_linux \
    "${DEBIAN_DISTRO}" \
    "${distro_version}" \
    "${DEBIAN_DISTRO_FAMILY}" \
    "${EXP_INSTALL_CALL_ARGS}" \
    "${installs_dependencies}" \
    "${exp_dependencies[@]}"
}

function assert_installs_correctly_on_ubuntu() {
  local distro_version="${1}"
  local exp_install_call_args="${2}"
  local installs_dependencies="${3}"
  local -ar exp_dependencies=(
    "${COMMON_DEBIAN_BASED_DEPENDENCIES[@]}"
    "software-properties-common"
  )

  assert_installed_correctly_linux \
    "${UBUNTU_DISTRO}" \
    "${distro_version}" \
    "${DEBIAN_DISTRO_FAMILY}" \
    "${exp_install_call_args}" \
    "${installs_dependencies}" \
    "${exp_dependencies[@]}"
}

function assert_installs_correctly_on_ubuntu_interim() {
  assert_installs_correctly_on_ubuntu \
    "${1}" \
    "--prefer-snap ${EXP_INSTALL_CALL_ARGS}" \
    false
}

function assert_installs_correctly_on_ubuntu_lts() {
  assert_installs_correctly_on_ubuntu \
    "${1}" \
    "${EXP_INSTALL_CALL_ARGS}" \
    true
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu 16.04" {
  assert_installs_correctly_on_ubuntu_lts "16.04"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu 18.04" {
  assert_installs_correctly_on_ubuntu_lts "18.04"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu 20.04" {
  assert_installs_correctly_on_ubuntu_lts "20.04"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu 18.10 interim release" {
  assert_installs_correctly_on_ubuntu_interim "18.10"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu 19.10 interim release" {
  assert_installs_correctly_on_ubuntu_interim "19.10"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Ubuntu 20.10 interim release" {
  assert_installs_correctly_on_ubuntu_interim "20.10"
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported Ubuntu version" {
  unsupported_version=12.10
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO="${UBUNTU_DISTRO}" \
    LINUX_DISTRO_VERSION_ID="${unsupported_version}"
    run install_powershell

  assert_failure
  assert_error_call_args "PowerShell not supported on Ubuntu version: '${unsupported_version}'"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Debian 8" {
  assert_installs_correctly_on_debian "8" true "${COMMON_DEBIAN_BASED_DEPENDENCIES[@]}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Debian 9" {
  local -ar exp_dependencies=(
    "${COMMON_DEBIAN_BASED_DEPENDENCIES[@]}"
    "gnupg"
  )
  assert_installs_correctly_on_debian "9" true "${exp_dependencies[@]}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Debian 10" {
  assert_installs_correctly_on_debian "10" false
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported Debian version" {
  unsupported_version=2
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO="${DEBIAN_DISTRO}" \
    LINUX_DISTRO_VERSION_ID="${unsupported_version}"
    run install_powershell

  assert_failure
  assert_error_call_args "PowerShell not supported on Debian version: '${unsupported_version}'"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Fedora" {
  local -ar exp_dependencies=(
    "compat-openssl10"
  )
  assert_installs_correctly_on_fedora_based_distro \
    "${FEDORA_DISTRO}" \
    "32" \
    true \
  "${exp_dependencies[@]}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on RHEL" {
  assert_installs_correctly_on_fedora_based_distro \
    "${RHEL_DISTRO}" \
    "8.0" \
    false
}

@test "${TEST_SUITE_PREFIX}installs correctly on CentOS" {
  assert_installs_correctly_on_fedora_based_distro \
    "${CENTOS_DISTRO}" \
    "7" \
    false
}

@test "${TEST_SUITE_PREFIX}installs correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_powershell
  assert_success
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
  refute_add_remote_signing_key_called
  refute_mock_install_package_called
  refute_update_package_lists_called
  refute_add_package_repository_called
}
