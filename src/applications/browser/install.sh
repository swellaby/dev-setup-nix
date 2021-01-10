#!/usr/bin/env bash

readonly APPLICATION_BROWSERS_DIR_FOR_BIN=$(dirname "${BASH_SOURCE[0]}")

source "${APPLICATION_BROWSERS_DIR_FOR_BIN}/../../utils.sh"
source "${APPLICATION_BROWSERS_DIR_FOR_BIN}/browsers.sh"

install_browsers_tools_bin "$@"
