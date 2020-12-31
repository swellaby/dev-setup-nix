#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/docker/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${DOCKER_TEST_PREFIX}::add_docker_repository::"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_add_package_repository
  mock_install_package
  mock_error
  OPERATING_SYSTEM="${LINUX_OS}"
  LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}"
}

function assert_correct_repo_added_on_fedora_based_distro() {
  local distro="${1}"
  LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" LINUX_DISTRO="${distro}" \
    run add_docker_repository
  assert_success
  assert_mock_install_package_call_args "-n dnf-plugins-core"
  assert_add_package_repository_call_args \
    "-r https://download.docker.com/linux/${distro}/docker-ce.repo"
}

function assert_correct_repo_added_on_debian_based_distro() {
  local arch="${1}"
  local distro="${2}"
  mock_dpkg "${arch}"
  exp_codename="focal"
  lsb_release_prefix="mock_lsb_release"
  function lsb_release() {
    if [ "${1}" == "-cs" ]; then
      echo "${exp_codename}"
    else
      exit 1
    fi
  }
  declare -f lsb_release
  LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" LINUX_DISTRO="${distro}" run add_docker_repository
  assert_success
  local exp_rep_url="https://download.docker.com/linux/${distro}"
  assert_add_package_repository_call_args \
    "-r deb [arch=${arch}] ${exp_rep_url} ${exp_codename} stable"
}

@test "${TEST_SUITE_PREFIX}does nothing on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run add_docker_repository
  assert_success
  assert_output ""
}

@test "${TEST_SUITE_PREFIX}correctly adds repo on Fedora" {
  assert_correct_repo_added_on_fedora_based_distro "${FEDORA_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}correctly adds repo on RHEL" {
  assert_correct_repo_added_on_fedora_based_distro "${RHEL_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}correctly adds repo on CentOS" {
  assert_correct_repo_added_on_fedora_based_distro "${CENTOS_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported arch on a Debian-based distro" {
  local arch="mips"
  mock_dpkg "${arch}"
  LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" run add_docker_repository
  assert_failure
  assert_error_call_args "Unsupported processor architecture: '${arch}'. Unable to install Docker"
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported Linux distro" {
  local distro="unsupported"
  LINUX_DISTRO="${distro}" run add_docker_repository
  assert_failure
  refute_add_package_repository_called
  assert_error_call_args "Unsupported distro for docker installation: '${distro}'"
}

@test "${TEST_SUITE_PREFIX}adds correct repository with amd64 arch on Debian" {
  assert_correct_repo_added_on_debian_based_distro "amd64" "${DEBIAN_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}adds correct repository with arm64 arch on Debian" {
  assert_correct_repo_added_on_debian_based_distro "arm64" "${DEBIAN_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}adds correct repository with armhf arch on Debian" {
  assert_correct_repo_added_on_debian_based_distro "armhf" "${DEBIAN_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}adds correct repository with amd64 arch on Ubuntu" {
  assert_correct_repo_added_on_debian_based_distro "amd64" "${UBUNTU_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}adds correct repository with arm64 arch on Ubuntu" {
  assert_correct_repo_added_on_debian_based_distro "arm64" "${UBUNTU_DISTRO}"
}

@test "${TEST_SUITE_PREFIX}adds correct repository with armhf arch on Ubuntu" {
  assert_correct_repo_added_on_debian_based_distro "armhf" "${UBUNTU_DISTRO}"
}
