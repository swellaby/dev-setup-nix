# shellcheck shell=bash

local_dir_name=$(dirname "${BASH_SOURCE[0]}")
source "${local_dir_name}/../powershell/powershell.sh"

function install_powershell_script_analyzer() {
  if ! tool_installed "pwsh"; then
    install_powershell
  fi

  print_tool_installation_message "PowerShell Script Analyzer"
  pwsh -c "\$ProgressPreference = \"SilentlyContinue\"; Install-Module -Name PSScriptAnalyzer -Confirm:\$False -Force"
}
