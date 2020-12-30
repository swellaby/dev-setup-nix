#!/usr/bin/env bats

# shellcheck source=tests/unit/utils/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"

readonly TEST_SUITE_PREFIX="${BASE_TEST_SUITE_PREFIX}add_remote_signing_key::"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_tool_installed
  mock_install_package
  mock_curl
  mock_error
  mock_rpm
  mock_apt_key
}

@test "${TEST_SUITE_PREFIX}errors correctly when called from Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run add_remote_signing_key
  assert_failure
  assert_error_call_args "Package signing keys are not supported on MacOS. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly with invalid arg" {
  local invalid_arg="--foo-bar"
  OPERATING_SYSTEM="${LINUX_OS}" run add_remote_signing_key "${invalid_arg}"
  assert_failure
  assert_error_call_args "Invalid 'add_remote_signing_key' arg: '${invalid_arg}'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly on missing key url" {
  OPERATING_SYSTEM="${LINUX_OS}" run add_remote_signing_key
  assert_failure
  assert_error_call_args "No url for signing key provided to 'add_remote_signing_key'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported distro" {
  local distro="disco"
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="" LINUX_DISTRO="${distro}" \
    run add_remote_signing_key -u "https://foo.com/gpg"
  assert_failure
  assert_error_call_args "Tried to install a package signing key on an supported distro: '${distro}'. This is likely a bug."
}

@test "${TEST_SUITE_PREFIX}runs correctly on a Fedora based distro" {
  local key_url="https://packages.microsoft.com/keys/microsoft.asc"
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}"
  run add_remote_signing_key --key-url "${key_url}"
  assert_success
  assert_rpm_call_args "--import ${key_url}"
}

@test "${TEST_SUITE_PREFIX}errors correctly on a Debian based distro with curl installation failure" {
  mock_tool_installed 1
  mock_install_package 1
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}"
  run add_remote_signing_key -u "abc.com"
  assert_failure
  assert_tool_installed_call_args "curl"
  assert_mock_install_package_call_args "-n curl"
  assert_error_call_args "curl was not found and attempt to install failed."
}

@test "${TEST_SUITE_PREFIX}does not attempt to re-install curl on a Debian based distro when already available" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}"
  run add_remote_signing_key -u "github.com"
  assert_success
  refute_mock_install_package_called
}

@test "${TEST_SUITE_PREFIX}runs correctly on a Debian based distro" {
  local key_url="https://download.docker.com/linux/ubuntu/gpg"
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}"
  run add_remote_signing_key --key-url "${key_url}"
  assert_success
  assert_curl_call_args "-fsSL ${key_url}"
  assert_apt_key_call_args "add -"
}
