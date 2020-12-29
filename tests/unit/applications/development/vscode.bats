#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/vscode/vscode.sh
source "${DEVELOPMENT_DIRECTORY}/vscode/vscode.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::vscode::"

function setup() {
  mock_tool_installed
  mock_install
}

@test "${TEST_SUITE_PREFIX}install_vscode::uses correct args" {
  run install_vscode
  assert_success
  assert_call_args "--application-name VS Code --snap-name code --snap-prefix --classic --prefer-snap --mac-package-name visual-studio-code --mac-package-prefix --cask"
}

@test "${TEST_SUITE_PREFIX}install_vscode_extension::returns 1 when code not on path" {
  extension="swellaby.common-pack"
  mock_error_prefix="mock_error:"

  mock_tool_installed 7
  function error() {
    echo "${mock_error_prefix} $*"
  }

  run install_vscode_extension "${extension}"

  assert_equal "$status" 1
  assert_tool_installed_call_args "code"
  assert_equal "${lines[1]}" "${mock_error_prefix} Attempted to install VS Code extension '${extension}' but 'code' not on PATH"
}

@test "${TEST_SUITE_PREFIX}install_vscode_extension::installs extension when code on path" {
  extension="swellaby.rust-pack"
  mock_info_prefix="mock_info:"
  mock_code_prefix="mock_code:"

  function info() {
    echo "${mock_info_prefix} $*"
  }
  function code() {
    echo "${mock_code_prefix} $*"
  }

  run install_vscode_extension "${extension}"

  assert_success
  assert_tool_installed_call_args "code"
  assert_equal "${lines[1]}" "${mock_info_prefix} Installing VS Code extension: '${extension}'"
  assert_equal "${lines[2]}" "${mock_code_prefix} --install-extension ${extension} --force"
}

@test "${TEST_SUITE_PREFIX}install_default_vscode_extensions::installs correct default extension" {
  exp_extensions=(
    "swellaby.rust-pack"
    "swellaby.common-pack"
    "swellaby.python-pack"
    "swellaby.node-pack"
  )
  local -i exp_ext_count=${#exp_extensions[@]}
  local -i act_ext_count=0
  mock_install_vscode_extension_prefix="mock_install_vscode_extension:"
  install_count_prefix="act_num_extensions:"
  function install_vscode_extension() {
    ((act_ext_count = act_ext_count + 1))
    echo "${install_count_prefix} ${act_ext_count}"
    echo "${mock_install_vscode_extension_prefix} $*"
  }
  declare -f install_vscode_extension

  run install_default_vscode_extensions

  assert_success
  for extension in "${exp_extensions[@]}"; do
    assert_output --partial "${mock_install_vscode_extension_prefix} ${extension}"
  done
  assert_line "${install_count_prefix} ${exp_ext_count}"
  local -i exp_plus_one=exp_ext_count+1
  refute_line "${install_count_prefix} ${exp_plus_one}"
}
