#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/docker/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${DOCKER_TEST_PREFIX}::install_docker_dependencies::"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install_curl
  mock_install_package
  mock_error
  OPERATING_SYSTEM="${LINUX_OS}"
}

@test "${TEST_SUITE_PREFIX}does nothing on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_docker_dependencies
  assert_success
  assert_output ""
}

@test "${TEST_SUITE_PREFIX}does nothing on a Fedora based distro" {
  LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" run install_docker_dependencies
  assert_success
  assert_output ""
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported Linux distro" {
  local distro="unsupported"
  LINUX_DISTRO="${distro}" run install_docker_dependencies
  assert_failure
  refute_mock_install_package_called
  assert_error_call_args "Unsupported distro for docker installation: '${distro}'"
}

@test "${TEST_SUITE_PREFIX}installs correct dependent packages on a Debian based distro" {
  local -a exp_package_list=(
    "apt-transport-https"
    "ca-certificates"
    "gnupg-agent"
    "software-properties-common"
  )

  local -i act_package_count=0
  install_count_prefix="act_num_packages:"
  function install_package() {
    ((act_package_count = act_package_count + 1))
    echo "${install_count_prefix} ${act_package_count}"
    echo "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} $*"
  }
  LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" run install_docker_dependencies
  assert_success
  assert_install_curl_called

  local -i exp_package_count=${#exp_package_list[@]}
  for package in "${exp_package_list[@]}"; do
    assert_line "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} -n ${package}"
  done
  assert_correct_call_count "${install_count_prefix}" ${exp_package_count}
}
