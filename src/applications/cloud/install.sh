#!/usr/bin/env bash

readonly APPLICATION_CLOUD_DIR_FOR_BIN=$(dirname "${BASH_SOURCE[0]}")

source "${APPLICATION_CLOUD_DIR_FOR_BIN}/../../utils.sh"
source "${APPLICATION_CLOUD_DIR_FOR_BIN}/cloud.sh"

install_cloud_tools_bin "$@"
