# shellcheck shell=bash

readonly TMP_FILE_DIR=${BATS_TMPDIR}/bats/swellaby-dotfiles
readonly OS_RELEASE_TMP_FILE=${TMP_FILE_DIR}/os-release
readonly ERROR_MESSAGE_PREFIX="[swellaby_dotfiles]: "
readonly MOCKED_INSTALL_SNAP_CALL_ARGS_PREFIX="mock_install_snap: "
readonly MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX="mock_install_package: "
readonly MOCKED_DEFAULT_RETURN_CODE=0

readonly SRC_DIRECTORY_PATH_FROM_ROOT="src"
readonly PACKAGES_DIRECTORY_PATH_FROM_ROOT="${SRC_DIRECTORY_PATH_FROM_ROOT}/packages"
readonly PACKAGES_DEVELOPMENT_DIRECTORY_PATH_FROM_ROOT="${PACKAGES_DIRECTORY_PATH_FROM_ROOT}/development"

readonly PACKAGES_SUITE_PREFIX="packages"
readonly PACKAGES_DEVELOPMENT_SUITE_PREFIX="${PACKAGES_SUITE_PREFIX}::development"

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
