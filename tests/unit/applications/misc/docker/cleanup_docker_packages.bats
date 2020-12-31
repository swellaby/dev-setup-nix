#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/docker/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${DOCKER_TEST_PREFIX}::cleanup_docker_packages::"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_remove_package
  mock_error
  EXP_DEBIAN_PACKAGES=(
    "docker"
    "docker-engine"
    "docker.io"
    "containerd"
    "runc"
  )
  EXP_FEDORA_BASED_COMMON_PACKAGES=(
    "docker"
    "docker-client"
    "docker-client-latest"
    "docker-common"
    "docker-latest"
    "docker-latest-logrotate"
    "docker-logrotate"
    "docker-engine"
  )
  OPERATING_SYSTEM="${LINUX_OS}"
}

@test "${TEST_SUITE_PREFIX}does nothing on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run cleanup_docker_packages
  assert_success
  assert_output ""
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported Linux distro" {
  local distro="fake"
  LINUX_DISTRO="${distro}" run cleanup_docker_packages
  assert_failure
  refute_remove_package_called
  assert_error_call_args "Unsupported distro: '${distro}'"
}

function assert_correct_packages_removed() {
  local distro="${1}"
  shift
  local -a exp_package_list=("$@")

  local -i act_package_count=0
  install_count_prefix="act_num_extensions:"
  function remove_package() {
    ((act_package_count = act_package_count + 1))
    echo "${install_count_prefix} ${act_package_count}"
    echo "${MOCKED_REMOVE_PACKAGE_CALL_ARGS_PREFIX} $*"
  }
  LINUX_DISTRO="${distro}" run cleanup_docker_packages
  assert_success

  local -i exp_package_count=${#exp_package_list[@]}
  for extension in "${exp_package_list[@]}"; do
    assert_remove_package_call_args "-n ${extension}"
  done

  assert_correct_call_count "${install_count_prefix}" ${exp_package_count}
}

@test "${TEST_SUITE_PREFIX}removes correct packages on Debian" {
  assert_correct_packages_removed "${DEBIAN_DISTRO}" "${EXP_DEBIAN_PACKAGES[@]}"
}

@test "${TEST_SUITE_PREFIX}removes correct packages on Ubuntu" {
  assert_correct_packages_removed "${UBUNTU_DISTRO}" "${EXP_DEBIAN_PACKAGES[@]}"
}

@test "${TEST_SUITE_PREFIX}removes correct packages on CentOS" {
  assert_correct_packages_removed "${CENTOS_DISTRO}" "${EXP_FEDORA_BASED_COMMON_PACKAGES[@]}"
}

@test "${TEST_SUITE_PREFIX}removes correct packages on RHEL" {
  assert_correct_packages_removed "${RHEL_DISTRO}" "${EXP_FEDORA_BASED_COMMON_PACKAGES[@]}"
}

@test "${TEST_SUITE_PREFIX}removes correct packages on Fedora" {
  local -a se=(
    "docker-selinux"
    "docker-engine-selinux"
  )
  local -a exp=(
    "${EXP_FEDORA_BASED_COMMON_PACKAGES[@]}"
    "${se[@]}"
  )
  assert_correct_packages_removed "${FEDORA_DISTRO}" "${exp[@]}"
}
