#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/powershell-script-analyzer/powershell_script_analyzer.sh
source "${DEVELOPMENT_DIRECTORY}/powershell-script-analyzer/powershell_script_analyzer.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::powershell-script-analyzer::powershell_script_analyzer::"
readonly INSTALL_POWERSHELL_MOCK_PREFIX="mock_install_powershell:"
readonly EXP_PRINT_TOOL_INSTALLATION_MESSAGE="PowerShell Script Analyzer"
readonly EXP_PWSH_CALL_ARGS="-c \$ProgressPreference = \"SilentlyContinue\"; Install-Module -Name PSScriptAnalyzer -Confirm:\$False -Force"

function setup() {
  mock_info
  mock_print_tool_installation_message
  mock_pwsh
  mock_tool_installed 0
  function install_powershell() {
    echo "${INSTALL_POWERSHELL_MOCK_PREFIX}"
  }
  declare -f install_powershell
}

@test "${TEST_SUITE_PREFIX}installs correctly when PowerShell already available" {
  run install_powershell_script_analyzer
  assert_tool_installed_call_args "pwsh"
  refute_line --partial "${INSTALL_POWERSHELL_MOCK_PREFIX}"
  assert_print_tool_installation_message_call_args "${EXP_PRINT_TOOL_INSTALLATION_MESSAGE}"
  assert_pwsh_call_args "${EXP_PWSH_CALL_ARGS}"
}

@test "${TEST_SUITE_PREFIX}installs correctly when PowerShell not already available" {
  mock_tool_installed 1
  run install_powershell_script_analyzer
  assert_tool_installed_call_args "pwsh"
  assert_line --partial "${INSTALL_POWERSHELL_MOCK_PREFIX}"
  assert_print_tool_installation_message_call_args "${EXP_PRINT_TOOL_INSTALLATION_MESSAGE}"
  assert_pwsh_call_args "${EXP_PWSH_CALL_ARGS}"
}
