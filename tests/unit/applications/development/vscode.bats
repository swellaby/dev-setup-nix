#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/vscode/vscode.sh
source "${DEVELOPMENT_DIRECTORY}/vscode/vscode.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::vscode::"

@test "${TEST_SUITE_PREFIX}install_vscode::uses correct args" {
  function install() {
    echo "$*"
  }

  run install_vscode
  assert_equal "$status" 0
  assert_call_args "--application-name VS Code --snap-name code --snap-prefix --classic --prefer-snap --mac-package-name visual-studio-code --mac-package-prefix --cask"
}

