#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/rust/rust.sh
source "${DEVELOPMENT_DIRECTORY}/rust/rust.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::rust::install_rust::"
readonly SH_CALL_ARGS_PREFIX="mock_sh:"

function setup() {
  mock_install_curl
  mock_tool_installed
  mock_curl
  mock_source

  function sh() {
    echo "${SH_CALL_ARGS_PREFIX} $*"
  }
  declare -f sh
}

function teardown() {
  rm -f "${STD_OUT_TMP_FILE}" || true
}

function assert_sh_call_args() {
  assert_line "${SH_CALL_ARGS_PREFIX} ${1}"
}

@test "${TEST_SUITE_PREFIX}installs curl if not available" {
  mock_tool_installed 1
  run install_rust
  assert_success
  assert_tool_installed_call_args "curl"
  assert_install_curl_called
}

@test "${TEST_SUITE_PREFIX}does not attempt to install curl if available" {
  run install_rust
  assert_success
  assert_tool_installed_call_args "curl"
  refute_line "${INSTALL_CURL_CALL_ARGS_PREFIX}"
}

@test "${TEST_SUITE_PREFIX}uses correct curl options" {
  run install_rust
  assert_success
  assert_curl_call_args "--proto =https --tlsv1.2 -sSf https://sh.rustup.rs"
}

@test "${TEST_SUITE_PREFIX}uses correct sh pipe options with no components" {
  run install_rust
  assert_success
  assert_sh_call_args "-s -- -y "
}

@test "${TEST_SUITE_PREFIX}install_rust::uses correct sh pipe options with just rustfmt component (shorthand)" {
  run install_rust -r
  assert_success
  assert_sh_call_args "-s -- -y -c rustfmt"
}

@test "${TEST_SUITE_PREFIX}uses correct sh pipe options with just rustfmt component (longhand)" {
  run install_rust --install-rustfmt
  assert_success
  assert_sh_call_args "-s -- -y -c rustfmt"
}

@test "${TEST_SUITE_PREFIX}uses correct sh pipe options with just clippy component (shorthand)" {
  run install_rust -c
  assert_success
  assert_sh_call_args "-s -- -y -c clippy"
}

@test "${TEST_SUITE_PREFIX}uses correct sh pipe options with just clippy component (longhand)" {
  run install_rust --install-clippy
  assert_success
  assert_sh_call_args "-s -- -y -c clippy"
}

@test "${TEST_SUITE_PREFIX}uses correct sh pipe options with both clippy and rustfmt components" {
  run install_rust -c -r
  assert_success
  assert_sh_call_args "-s -- -y -c clippy rustfmt"
}

@test "${TEST_SUITE_PREFIX}correctly errors on invalid parameter" {
  local mock_error_prefix="mock_error:"
  function error() {
    echo "${mock_error_prefix} $*"
  }
  run install_rust --not-a-real-thing
  assert_failure
  assert_line "${mock_error_prefix} Invalid 'install_rust' arg: '--not-a-real-thing'. This is a bug!"
}

@test "${TEST_SUITE_PREFIX}sources cargo directories after successful install" {
  run install_rust
  assert_source_call_args "$HOME/.cargo/env"
}
