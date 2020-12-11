#!/usr/bin/env bats

load "../../../../test_helper_libs/bats-support/load"
load "../../../../test_helper_libs/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"

function setup() {
  # shellcheck source=src/packages/utils.sh
  source "${BATS_TEST_DIRNAME}"/../../../../src/packages/utils.sh
  setup_os_release_file
  mock_install_snap
  mock_install_package
}

function teardown() {
  teardown_os_release_file
}

@test "errors correctly on no args" {
  run install
  assert_equal "${status}" 1
  assert_output_contains "${output}" "No args passed to 'install' but at a minimum a snap or package name must be provided. This is a bug!"
}

@test "errors correctly on invalid arg" {
  fake_arg="--real-fake"
  run install "${fake_arg}"
  assert_equal "${status}" 1
  assert_output_contains "${output}" "Invalid 'install' arg: '${fake_arg}'. This is a bug!"
}

@test "snap preference disabled by default" {
  package_name="nyancat"
  run install --package-name "${package_name}"
  assert_equal "${status}" 0
  assert_mock_install_package_called_with "${output}" "-n ${package_name}"
}

@test "falls back to package manager with snap preference but snap unavailable" {
  package_name="wget"
  SNAP_AVAILABLE=false run install --package-name "${package_name}" --prefer-snap
  assert_equal "${status}" 0
  assert_output_contains "${lines[0]}" "Snap install preferred but Snap not available. This is a bug!"
  assert_mock_install_package_called_with "${lines[1]}" "-n ${package_name}"
}

@test "falls back to package manager with snap preference but snap install failed" {
  mock_install_snap 1
  package_name="docker.io"
  snap_name="firefox"
  SNAP_AVAILABLE=true run install -s "${snap_name}" -n "${package_name}" --prefer-snap
  assert_equal "${status}" 0
  assert_mock_install_snap_called_with "${lines[0]}" "-n ${snap_name}"
  assert_output_contains "${lines[1]}" "Attempted but failed to install Snap: '${snap_name}'"
  assert_output_contains "${lines[2]}" "Falling back to package manager"
  assert_mock_install_package_called_with "${lines[3]}" "-n ${package_name}"
}
