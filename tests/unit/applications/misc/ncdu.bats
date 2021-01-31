#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/misc/ncdu/ncdu.sh
source "${MISC_DIRECTORY}/ncdu/ncdu.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_MISC_SUITE_PREFIX}::ncdu::install_ncdu::"
readonly EXP_INSTALL_CALL_ARGS="--application-name ncdu --debian-family-package-name ncdu --fedora-family-package-name ncdu --mac-package-name ncdu"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install
  mock_install_package
  mock_info
}

@test "${TEST_SUITE_PREFIX}installs correctly on Fedora based distros" {
  OPERATING_SYSTEM="${LINUX_OS}"  LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" \
    run install_ncdu
  assert_success
  assert_mock_install_package_call_args "-n epel-release"
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Debian based distros" {
  OPERATING_SYSTEM="${LINUX_OS}"  LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" \
    run install_ncdu
  assert_success
  refute_mock_install_package_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_ncdu
  assert_success
  refute_mock_install_package_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}
