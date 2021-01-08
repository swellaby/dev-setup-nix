#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/security/lynis/lynis.sh
source "${SECURITY_DIRECTORY}/lynis/lynis.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_SECURITY_SUITE_PREFIX}::lynis::install_lynis::"
readonly EXP_INSTALL_CALL_ARGS="--application-name Lynis --debian-family-package-name lynis --fedora-family-package-name lynis --mac-package-name lynis"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_install
  mock_install_package 0
  mock_remove_package
  mock_add_package_repository
  mock_add_remote_signing_key
  mock_update_package_lists
  mock_error
}

function assert_installs_correctly_on_fedora_based_distros() {
  local distro="${1}"
  local installs_dependencies="${2}"
  shift 2
  local -a exp_package_list=("$@")
  local exp_repo="https://packages.cisofy.com/community/lynis/rpm/"
  local exp_key="https://packages.cisofy.com/keys/cisofy-software-rpms-public.key"

  local -i act_package_count=0
  install_count_prefix="act_num_packages:"
  function install_package() {
    ((act_package_count = act_package_count + 1))
    echo "${install_count_prefix} ${act_package_count}"
    echo "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} $*"
  }

  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" \
    LINUX_DISTRO="${distro}"  run install_lynis

  assert_success
  assert_add_package_repository_call_args "--package-repository ${exp_repo}"
  assert_add_remote_signing_key_call_args "--key-url ${exp_key}"
  assert_update_package_lists_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"

  if [ "${installs_dependencies}" == true ]; then
    local -i exp_package_count=${#exp_package_list[@]}
    for package in "${exp_package_list[@]}"; do
      assert_mock_install_package_call_args "-n ${package}"
    done

    assert_correct_call_count "${install_count_prefix}" "${exp_package_count}"
  else
    refute_mock_install_package_called
  fi
}

@test "${TEST_SUITE_PREFIX}installs correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_lynis
  assert_success
  refute_add_remote_signing_key_called
  refute_mock_install_package_called
  refute_update_package_lists_called
  refute_add_package_repository_called
  refute_remove_package_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Fedora" {
  assert_installs_correctly_on_fedora_based_distros "${FEDORA_DISTRO}" false
}

@test "${TEST_SUITE_PREFIX}installs correctly on RHEL" {
  local -ar exp_dependencies=(
    "ca-certificates"
    "curl"
    "nss"
    "openssl"
  )
  assert_installs_correctly_on_fedora_based_distros "${RHEL_DISTRO}" true "${exp_dependencies[@]}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on CentOS" {
  local -ar exp_dependencies=(
    "ca-certificates"
    "curl"
    "nss"
    "openssl"
  )

  assert_installs_correctly_on_fedora_based_distros "${CENTOS_DISTRO}" true "${exp_dependencies[@]}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on Debian based distros" {
  local -ar debian_dependencies=(
    "apt-transport-https"
  )

  local -i act_package_count=0
  install_count_prefix="act_num_packages:"
  function install_package() {
    ((act_package_count = act_package_count + 1))
    echo "${install_count_prefix} ${act_package_count}"
    echo "${MOCKED_INSTALL_PACKAGE_CALL_ARGS_PREFIX} $*"
  }

  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" \
    run install_lynis

  local exp_repo="deb https://packages.cisofy.com/community/lynis/deb/ stable main"
  local exp_key="https://packages.cisofy.com/keys/cisofy-software-public.key"

  assert_success
  assert_add_package_repository_call_args "--package-repository ${exp_repo}"
  assert_add_remote_signing_key_call_args "--key-url ${exp_key}"
  assert_update_package_lists_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS}"

  local -i exp_package_count=${#debian_dependencies[@]}
  for package in "${debian_dependencies[@]}"; do
    assert_mock_install_package_call_args "-n ${package}"
  done

  assert_correct_call_count "${install_count_prefix}" "${exp_package_count}"
}

@test "${TEST_SUITE_PREFIX}errors correctly on unsupported Linux Distro" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO="unsupported" run install_lynis
  assert_failure
  refute_add_remote_signing_key_called
  refute_mock_install_package_called
  refute_update_package_lists_called
  refute_add_package_repository_called
  refute_remove_package_called
  refute_install_called
  assert_error_call_args "Lynis installation not yet supported Linux Distro: 'unsupported'"
}
