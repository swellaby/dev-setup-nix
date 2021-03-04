#!/usr/bin/env bash

readonly APPLICATION_NOTE_DIR_FOR_BIN=$(dirname "${BASH_SOURCE[0]}")

source "${APPLICATION_NOTE_DIR_FOR_BIN}/../../utils.sh"
source "${APPLICATION_NOTE_DIR_FOR_BIN}/note.sh"

install_note_tools "$@"
