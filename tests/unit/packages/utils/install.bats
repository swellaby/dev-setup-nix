#!/usr/bin/env bats

load "../../../../test_helper_libs/bats-support/load"
load "../../../../test_helper_libs/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"

readonly TEST_SUITE_PREFIX="packages::utils::install::"

function setup() {
  # shellcheck source=src/packages/utils.sh
  source "${BATS_TEST_DIRNAME}"/../../../../src/packages/utils.sh
  setup_os_release_file
  mock_install_snap
  # shellcheck disable=SC2119
  mock_install_package
}

function teardown() {
  teardown_os_release_file
}

@test "${TEST_SUITE_PREFIX}errors correctly on no args" {
  run install
  assert_equal "${status}" 1
  assert_output_contains "${output}" "No args passed to 'install' but at a minimum a snap or package name must be provided. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}errors correctly on invalid arg" {
  fake_arg="--real-fake"
  run install "${fake_arg}"
  assert_equal "${status}" 1
  assert_output_contains "${output}" "Invalid 'install' arg: '${fake_arg}'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}snap preference disabled by default" {
  package_name="nyancat"
  LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" run install --debian-family-package-name "${package_name}"
  assert_equal "${status}" 0
  assert_mock_install_package_called_with "${output}" "-n ${package_name}"
}

@test "${TEST_SUITE_PREFIX}snap installed correctly with prefix long arg name" {
  snap_name="code"
  snap_prefix="--classic"
  SNAP_AVAILABLE=true run install --prefer-snap --snap-name "${snap_name}" --snap-prefix "${snap_prefix}"
  assert_equal "${status}" 0
  assert_mock_install_snap_called_with "${lines[0]}" "-n ${snap_name} -p ${snap_prefix}"
}

@test "${TEST_SUITE_PREFIX}snap installed correctly with prefix short arg name" {
  snap_name="slack"
  snap_prefix="--classic"
  SNAP_AVAILABLE=true run install -pfs -s "${snap_name}" -sp "${snap_prefix}"
  assert_equal "${status}" 0
  assert_mock_install_snap_called_with "${lines[0]}" "-n ${snap_name} -p ${snap_prefix}"
}

@test "${TEST_SUITE_PREFIX}falls back to package manager with snap preference but snap unavailable" {
  package_name="wget"
  LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" SNAP_AVAILABLE=false run install --debian-family-package-name "${package_name}" --prefer-snap
  assert_equal "${status}" 0
  assert_output_contains "${lines[0]}" "Snap install preferred but Snap not available. This is a bug!"
  assert_mock_install_package_called_with "${lines[1]}" "-n ${package_name}"
}

@test "${TEST_SUITE_PREFIX}falls back to package manager with snap preference but snap install failed" {
  mock_install_snap 1
  package_name="docker.io"
  snap_name="firefox"
  LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" SNAP_AVAILABLE=true run install --prefer-snap -s "${snap_name}" -dfpn "${package_name}"
  assert_equal "${status}" 0
  assert_mock_install_snap_called_with "${lines[0]}" "-n ${snap_name}"
  assert_output_contains "${lines[1]}" "Attempted but failed to install Snap: '${snap_name}'"
  assert_output_contains "${lines[2]}" "Falling back to package manager"
  assert_mock_install_package_called_with "${lines[3]}" "-n ${package_name}"
}

@test "${TEST_SUITE_PREFIX}utilizes package prefix for fedora family" {
  package_name="foo"
  package_prefix="don't you. forget about me."
  LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" run install --fedora-family-package-name "${package_name}" -p "${package_prefix}"
  assert_equal "${status}" 0
  assert_mock_install_package_called_with "${lines[0]}" "-n ${package_name} -p ${package_prefix}"
}

@test "${TEST_SUITE_PREFIX}errors correctly on fedora family when corresponding package name not provided" {
  package_name="oh debian"
  exp_distro="${FEDORA_DISTRO}"
  LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" LINUX_DISTRO="${exp_distro}" run install -dfpn "${package_name}"
  assert_equal "${status}" 0
  assert_output_contains "${output}" "On ${exp_distro} but package name was not provided for platform. This is likely a bug."
}

@test "${TEST_SUITE_PREFIX}utilizes package prefix for debian family" {
  package_name="bar"
  package_prefix="wait, what was i supposed to do again?"
  LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" run install -dfpn "${package_name}" --package-prefix "${package_prefix}"
  assert_equal "${status}" 0
  assert_mock_install_package_called_with "${lines[0]}" "-n ${package_name} -p ${package_prefix}"
}

@test "${TEST_SUITE_PREFIX}errors correctly on debian family when corresponding package name not provided" {
  package_name="oh fedora"
  exp_distro="${UBUNTU_DISTRO}"
  LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" LINUX_DISTRO="${exp_distro}" run install -ffpn "${package_name}"
  assert_equal "${status}" 0
  assert_output_contains "${output}" "On ${exp_distro} but package name was not provided for platform. This is likely a bug."
}

@test "${TEST_SUITE_PREFIX}correctly installs package on mac with no prefix" {
  package_name="shfmt"
  OPERATING_SYSTEM=${MAC_OS} run install -m "${package_name}"
  assert_equal "${status}" 0
  assert_mock_install_package_called_with "${lines[0]}" "-n ${package_name}"
}

@test "${TEST_SUITE_PREFIX}correctly installs package on mac with prefix" {
  package_name="visual-studio-code"
  prefix="--cask"
  OPERATING_SYSTEM=${MAC_OS} run install --mac-package-name "${package_name}" -mp "${prefix}"
  assert_equal "${status}" 0
  assert_mock_install_package_called_with "${lines[0]}" "-n ${package_name} -p ${prefix}"
}

@test "${TEST_SUITE_PREFIX}errors correctly on mac when corresponding package name not provided" {
  package_name="oh linux"
  OPERATING_SYSTEM="${MAC_OS}" run install -dfpn "${package_name}"
  assert_equal "${status}" 0
  assert_output_contains "${output}" "On Mac OS but package name was not provided for Mac OS platform. This is likely a bug."
}
