# shellcheck shell=bash

# load "../../../test_helper_libs/bats-support/load"
# load "../../../test_helper_libs/bats-assert/load"

readonly TMP_FILE_DIR=${BATS_TMPDIR}/bats/swellaby-dotfiles
readonly OS_RELEASE_TMP_FILE=${TMP_FILE_DIR}/os-release
readonly ERROR_MESSAGE_PREFIX="[swellaby_dotfiles]: "

function setup_os_release_file() {
  mkdir -p ${TMP_FILE_DIR}
  touch ${OS_RELEASE_TMP_FILE}
}

function teardown_os_release_file() {
  rm -f ${OS_RELEASE_TMP_FILE} || true
}

function assert_error_output() {
  local output
  local exp_details
  output=$1
  exp_details=$2

  assert_equal "${output}" "${ERROR_MESSAGE_PREFIX}${exp_details}"
}
