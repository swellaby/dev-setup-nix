# shellcheck shell=bash

readonly TMP_FILE_DIR=${BATS_TMPDIR}/bats/swellaby-dotfiles
readonly OS_RELEASE_TMP_FILE=${TMP_FILE_DIR}/os-release
# Use is verified, known to be consumed
# shellcheck disable=SC2034
readonly STD_ERR_TMP_FILE=${BATS_TMPDIR}/stderr
# Use is verified, known to be consumed
# shellcheck disable=SC2034
readonly STD_OUT_TMP_FILE=${BATS_TMPDIR}/stdout
readonly ERROR_MESSAGE_PREFIX="[swellaby_dotfiles]: "
readonly MOCKED_INSTALL_SNAP_CALL_ARGS_PREFIX="mock_install_snap: "
readonly MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX="mock_install_package: "
readonly MOCKED_DEFAULT_RETURN_CODE=0

readonly SRC_DIRECTORY_PATH_FROM_ROOT="src"
readonly APPLICATIONS_DIRECTORY_PATH_FROM_ROOT="${SRC_DIRECTORY_PATH_FROM_ROOT}/applications"
declare -xr APPLICATIONS_BROWSERS_DIRECTORY_PATH_FROM_ROOT="${APPLICATIONS_DIRECTORY_PATH_FROM_ROOT}/browsers"
declare -xr APPLICATIONS_COLLABORATION_DIRECTORY_PATH_FROM_ROOT="${APPLICATIONS_DIRECTORY_PATH_FROM_ROOT}/collaboration"
declare -xr APPLICATIONS_DEVELOPMENT_DIRECTORY_PATH_FROM_ROOT="${APPLICATIONS_DIRECTORY_PATH_FROM_ROOT}/development"
declare -xr APPLICATIONS_MISC_DIRECTORY_PATH_FROM_ROOT="${APPLICATIONS_DIRECTORY_PATH_FROM_ROOT}/misc"
declare -xr APPLICATIONS_SECURITY_DIRECTORY_PATH_FROM_ROOT="${APPLICATIONS_DIRECTORY_PATH_FROM_ROOT}/security"

readonly APPLICATIONS_SUITE_PREFIX="applications"
declare -xr APPLICATIONS_BROWSERS_SUITE_PREFIX="${APPLICATIONS_SUITE_PREFIX}::browsers"
declare -xr APPLICATIONS_COLLABORATION_SUITE_PREFIX="${APPLICATIONS_SUITE_PREFIX}::collaboration"
declare -xr APPLICATIONS_DEVELOPMENT_SUITE_PREFIX="${APPLICATIONS_SUITE_PREFIX}::development"
declare -xr APPLICATIONS_MISC_SUITE_PREFIX="${APPLICATIONS_SUITE_PREFIX}::misc"
declare -xr APPLICATIONS_SECURITY_SUITE_PREFIX="${APPLICATIONS_SUITE_PREFIX}::security"

readonly SUBMODULES_DIRECTORY_FROM_ROOT="submodules"
declare -xr BATS_SUPPORT_LOAD_PATH_FROM_ROOT="${SUBMODULES_DIRECTORY_FROM_ROOT}/bats-support/load"
declare -xr BATS_ASSERT_LOAD_PATH_FROM_ROOT="${SUBMODULES_DIRECTORY_FROM_ROOT}/bats-assert/load"

function setup_os_release_file() {
  mkdir -p "${TMP_FILE_DIR}"
  touch "${OS_RELEASE_TMP_FILE}"
}

function teardown_os_release_file() {
  rm -f "${OS_RELEASE_TMP_FILE}" || true
}

function assert_output_contains() {
  local output
  local exp_details
  output=$1
  exp_details=$2

  assert_equal "${output}" "${ERROR_MESSAGE_PREFIX}${exp_details}"
}

function assert_call_args() {
  assert_equal "${output}" "${1}"
}

function mock_grep_distro() {
  _distro=$1

  function grep() {
    echo "${_distro}"
  }

  declare -f grep
}

function mock_install_snap() {
  _install_snap_return_code=${1:-$MOCKED_DEFAULT_RETURN_CODE}

  function install_snap() {
    echo "${MOCKED_INSTALL_SNAP_CALL_ARGS_PREFIX}$*"
    # shellcheck disable=SC2086
    return ${_install_snap_return_code}
  }

  declare -f install_snap
}

function mock_install_package() {
  _install_package_return_code=${1:-$MOCKED_DEFAULT_RETURN_CODE}

  function install_package() {
    echo "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX}$*"
    # shellcheck disable=SC2086
    return ${_install_package_return_code}
  }

  declare -f install_package
}

function assert_mock_install_snap_called_with() {
  local output
  local exp_args
  output="${1}"
  exp_args="${2}"

  assert_equal "${output}" "${MOCKED_INSTALL_SNAP_CALL_ARGS_PREFIX}${exp_args}"
}

function assert_mock_install_package_called_with() {
  local output
  local exp_args
  output="${1}"
  exp_args="${2}"

  assert_equal "${output}" "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX}${exp_args}"
}
