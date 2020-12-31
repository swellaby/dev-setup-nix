#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/docker/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${DOCKER_TEST_PREFIX}::install_docker::"
readonly MOCK_CLEANUP_DOCKER_PACKAGES_PREFIX="mock_cleanup_docker_packages:"
readonly MOCK_INSTALL_DOCKER_DEPENDENCIES_PREFIX="mock_install_docker_dependencies:"
readonly MOCK_ADD_DOCKER_REPOSITORY_PREFIX="mock_add_docker_repository:"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install_package
  mock_update_package_lists
  mock_install
  mock_add_remote_signing_key
  mock_error
  function cleanup_docker_packages() {
    echo "${MOCK_CLEANUP_DOCKER_PACKAGES_PREFIX}"
  }
  declare -f cleanup_docker_packages
  function install_docker_dependencies() {
    echo "${MOCK_INSTALL_DOCKER_DEPENDENCIES_PREFIX}"
  }
  declare -f install_docker_dependencies
  function add_docker_repository() {
    echo "${MOCK_ADD_DOCKER_REPOSITORY_PREFIX}"
  }
  declare -f add_docker_repository
}

@test "${TEST_SUITE_PREFIX}installs correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_docker
  assert_success
  assert_install_call_args "--application-name Docker --mac-package-name docker"
  refute_line "${MOCK_CLEANUP_DOCKER_PACKAGES_PREFIX}"
  refute_update_package_lists_called
  refute_line "${MOCK_INSTALL_DOCKER_DEPENDENCIES_PREFIX}"
  refute_line "${MOCK_ADD_DOCKER_REPOSITORY_PREFIX}"
  refute_add_remote_signing_key_called
}

@test "${TEST_SUITE_PREFIX}installs correctly on Linux" {
  local -i act_package_count=0
  install_count_prefix="act_num_packages:"
  function install_package() {
    ((act_package_count = act_package_count + 1))
    echo "${install_count_prefix} ${act_package_count}"
    echo "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} $*"
  }
  OPERATING_SYSTEM="${LINUX_OS}" run install_docker
  assert_success
  refute_install_called
  assert_line "${MOCK_CLEANUP_DOCKER_PACKAGES_PREFIX}"
  assert_update_package_lists_called
  assert_line "${MOCK_INSTALL_DOCKER_DEPENDENCIES_PREFIX}"
  assert_line "${MOCK_ADD_DOCKER_REPOSITORY_PREFIX}"
  refute_add_remote_signing_key_called

  local -a exp_package_list=(
    "docker-ce"
    "docker-ce-cli"
    "containerd.io"
  )
  local -i exp_package_count=${#exp_package_list[@]}
  for package in "${exp_package_list[@]}"; do
    assert_line "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} -n ${package}"
  done
  assert_correct_call_count "${install_count_prefix}" ${exp_package_count}

}
