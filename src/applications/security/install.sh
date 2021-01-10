#!/usr/bin/env bash

readonly APPLICATION_SECURITY_DIR_FOR_BIN=$(dirname "${BASH_SOURCE[0]}")

source "${APPLICATION_SECURITY_DIR_FOR_BIN}/../../utils.sh"
source "${APPLICATION_SECURITY_DIR_FOR_BIN}/security.sh"

install_security_tools_bin "$@"
