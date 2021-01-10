#!/usr/bin/env bash

readonly APPLICATION_BROWSER_DIR_FOR_BIN=$(dirname "${BASH_SOURCE[0]}")

source "${APPLICATION_BROWSER_DIR_FOR_BIN}/../../utils.sh"
source "${APPLICATION_BROWSER_DIR_FOR_BIN}/browser.sh"

install_browsers_tools "$@"
