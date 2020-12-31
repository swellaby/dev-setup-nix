# shellcheck shell=bash
# Disabling of ShellCheck rule SC2034 done safely inline below, usage verified

readonly TMP_FILE_DIR=${BATS_TMPDIR}/bats/swellaby-dotfiles
readonly OS_RELEASE_TMP_FILE=${TMP_FILE_DIR}/os-release
# shellcheck disable=SC2034
readonly STD_ERR_TMP_FILE=${BATS_TMPDIR}/stderr
# shellcheck disable=SC2034
readonly STD_OUT_TMP_FILE=${BATS_TMPDIR}/stdout
# shellcheck disable=SC2034
readonly LOG_MESSAGE_PREFIX="[swellaby_dotfiles]:"
readonly MOCKED_INSTALL_SNAP_CALL_ARGS_PREFIX="mock_install_snap: "
readonly MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX="mock_install_package:"
readonly MOCKED_TOOL_INSTALLED_CALL_ARGS_PREFIX="mock_tool_installed:"
readonly MOCKED_INSTALL_CALL_ARGS_PREFIX="mock_install:"
readonly MOCK_CURL_CALL_ARGS_PREFIX="mock_curl:"
readonly MOCKED_INSTALL_CURL_CALL_ARGS_PREFIX="mock_install_curl:"
readonly MOCKED_SOURCE_CALL_ARGS_PREFIX="mock_source:"
readonly MOCKED_ERROR_CALL_ARGS_PREFIX="mock_error:"
readonly MOCKED_INFO_CALL_ARGS_PREFIX="mock_info:"
readonly MOCKED_RPM_CALL_ARGS_PREFIX="mock_rpm:"
readonly MOCKED_APT_KEY_CALL_ARGS_PREFIX="mock_apt-key:"
readonly MOCKED_DNF_CALL_ARGS_PREFIX="mock_dnf:"
readonly MOCKED_ADD_APT_REPOSITORY_CALL_ARGS_PREFIX="mock_add-apt-repository:"
readonly MOCKED_REMOVE_PACKAGE_CALL_ARGS_PREFIX="mock_remove_package:"
declare -ir MOCKED_DEFAULT_RETURN_CODE=0

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

function mock_tool_installed() {
  _mocked_tool_installed_return_code=${1:-$MOCKED_DEFAULT_RETURN_CODE}

  function tool_installed() {
    echo "${MOCKED_TOOL_INSTALLED_CALL_ARGS_PREFIX} $*"
    # shellcheck disable=SC2086
    return ${_mocked_tool_installed_return_code}
  }

  declare -f tool_installed
}

function assert_tool_installed_call_args() {
  assert_line "${MOCKED_TOOL_INSTALLED_CALL_ARGS_PREFIX} ${1}"
}

function mock_install() {
  function install() {
    echo "${MOCKED_INSTALL_CALL_ARGS_PREFIX} $*"
  }
  declare -f install
}

function assert_install_call_args() {
  assert_line "${MOCKED_INSTALL_CALL_ARGS_PREFIX} ${1}"
}

function mock_curl() {
  function curl() {
    echo "${MOCK_CURL_CALL_ARGS_PREFIX} $*" >&"${STD_OUT_TMP_FILE}"
  }
  declare -f curl
}

function assert_curl_call_args() {
  act=$(cat "${STD_OUT_TMP_FILE}")
  assert_equal "${act}" "${MOCK_CURL_CALL_ARGS_PREFIX} ${1}"
}

function mock_install_curl() {
  function install_curl() {
    echo "${MOCKED_INSTALL_CURL_CALL_ARGS_PREFIX}"
  }
  declare -f install_curl
}

function assert_install_curl_called() {
  assert_line "${MOCKED_INSTALL_CURL_CALL_ARGS_PREFIX}"
}

function mock_grep_distro() {
  _distro=$1

  function grep() {
    echo "${_distro}"
  }

  declare -f grep
}

function mock_install_package() {
  _install_package_return_code=${1:-$MOCKED_DEFAULT_RETURN_CODE}

  function install_package() {
    echo "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} $*"
    # shellcheck disable=SC2086
    return ${_install_package_return_code}
  }

  declare -f install_package
}

function assert_mock_install_package_call_args() {
  assert_line "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} ${1}"
}

function refute_mock_install_package_called() {
  refute_line --partial "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX}"
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

function assert_mock_install_snap_called_with() {
  local output
  local exp_args
  output="${1}"
  exp_args="${2}"

  assert_equal "${output}" "${MOCKED_INSTALL_SNAP_CALL_ARGS_PREFIX}${exp_args}"
}

function mock_source() {
  function source() {
    echo "${MOCKED_SOURCE_CALL_ARGS_PREFIX} $*"
  }
  declare -f source
}

function assert_source_call_args() {
  assert_line "${MOCKED_SOURCE_CALL_ARGS_PREFIX} ${1}"
}

function refute_source_call_args() {
  refute_line "${MOCKED_SOURCE_CALL_ARGS_PREFIX} ${1}"
}

function refute_source_called() {
  refute_line --partial "${MOCKED_SOURCE_CALL_ARGS_PREFIX}"
}

function mock_error() {
  function error() {
    echo "${MOCKED_ERROR_CALL_ARGS_PREFIX} $*"
  }
  declare -f error
}

function assert_error_call_args() {
  assert_line "${MOCKED_ERROR_CALL_ARGS_PREFIX} ${1}"
}

function mock_info() {
  function info() {
    echo "${MOCKED_INFO_CALL_ARGS_PREFIX} $*"
  }
  declare -f info
}

function assert_info_call_args() {
  assert_line "${MOCKED_INFO_CALL_ARGS_PREFIX} ${1}"
}

function mock_rpm() {
  function rpm() {
    echo "${MOCKED_RPM_CALL_ARGS_PREFIX} $*"
  }
  declare -f rpm
}

function assert_rpm_call_args() {
  assert_line "${MOCKED_RPM_CALL_ARGS_PREFIX} ${1}"
}

function mock_apt_key() {
  function apt-key() {
    echo "${MOCKED_APT_KEY_CALL_ARGS_PREFIX} $*"
  }
  declare -f apt-key
}

function assert_apt_key_call_args() {
  assert_line "${MOCKED_APT_KEY_CALL_ARGS_PREFIX} ${1}"
}

function mock_dnf() {
  function dnf() {
    echo "${MOCKED_DNF_CALL_ARGS_PREFIX} $*"
  }
  declare -f dnf
}

function assert_dnf_call_args() {
  assert_line "${MOCKED_DNF_CALL_ARGS_PREFIX} ${1}"
}

function mock_add_apt_repository() {
  function add-apt-repository() {
    echo "${MOCKED_ADD_APT_REPOSITORY_CALL_ARGS_PREFIX} $*"
  }
  declare -f add-apt-repository
}

function assert_add_apt_repository_call_args() {
  assert_line "${MOCKED_ADD_APT_REPOSITORY_CALL_ARGS_PREFIX} ${1}"
}

function mock_remove_package() {
  function remove_package() {
    echo "${MOCKED_REMOVE_PACKAGE_CALL_ARGS_PREFIX} $*"
  }
  declare -f remove_package
}

function assert_remove_package_call_args() {
  assert_line "${MOCKED_REMOVE_PACKAGE_CALL_ARGS_PREFIX} ${1}"
}

function refute_remove_package_called() {
  refute_line "${MOCKED_REMOVE_PACKAGE_CALL_ARGS_PREFIX}"
}

function assert_correct_call_count() {
  local inc_call_count_prefix="${1}"
  local -i exp_call_count=${2}

  assert_line "${inc_call_count_prefix} ${exp_call_count}"
  local -i exp_plus_one=exp_call_count+1
  refute_line "${inc_call_count_prefix} ${exp_plus_one}"
}
