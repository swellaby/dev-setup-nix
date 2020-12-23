#!/usr/bin/env bash

readonly CURRENT_DIR=$(dirname "${BASH_SOURCE[0]}")

source "${CURRENT_DIR}/../../../utils.sh"
source "${CURRENT_DIR}/firefox.sh"

install_firefox
