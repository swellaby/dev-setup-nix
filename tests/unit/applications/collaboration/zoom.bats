#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/collaboration/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/collaboration/zoom/zoom.sh
source "${COLLABORATION_DIRECTORY}/zoom/zoom.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_COLLABORATION_SUITE_PREFIX}::zoom::install_zoom::"
readonly EXP_INSTALL_CALL_ARGS_SUFFIX="--application-name Zoom --mac-package-name zoom --mac-package-prefix --cask"
readonly EXP_64_BIT_BASE_DOWNLOAD_URL="https://zoom.us/client/latest"
readonly EXP_32_BIT_BASE_DOWNLOAD_URL="https://zoom.us/client/5.4.53391.1108"
readonly EXP_TMP_DIR="${TMPDIR:-/tmp}"
readonly EXP_DEB_FILE_LOCATION="${EXP_TMP_DIR}/zoom.deb"
readonly EXP_FEDORA_SIGNING_KEY_URL="https://zoom.us/linux/download/pubkey"

function setup() {
  # shellcheck source=src/utils.sh
  source "${UTILS_SOURCE_PATH}"
  mock_curl
  mock_tool_installed 0
  mock_install_curl
  mock_install
  mock_error
  mock_add_remote_signing_key
}

function teardown() {
  rm -f "${STD_OUT_TMP_FILE}" || true
}

@test "${TEST_SUITE_PREFIX}installs correctly on Mac" {
  OPERATING_SYSTEM="${MAC_OS}" run install_zoom
  assert_success
  refute_tool_installed_called
  refute_add_remote_signing_key_called
  assert_install_call_args "${EXP_INSTALL_CALL_ARGS_SUFFIX}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on 64 bit Debian-based distros" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" \
    BITNESS="64" run install_zoom
  assert_success
  assert_tool_installed_call_args "curl"
  refute_add_remote_signing_key_called
  refute_install_curl_called
  exp_download_url="${EXP_64_BIT_BASE_DOWNLOAD_URL}/zoom_amd64.deb"
  assert_curl_call_args "-sSL ${exp_download_url} -o ${EXP_DEB_FILE_LOCATION}"
  assert_install_call_args "--debian-family-package-name ${EXP_DEB_FILE_LOCATION} ${EXP_INSTALL_CALL_ARGS_SUFFIX}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on 32 bit Debian-based distros" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" \
    BITNESS="32" run install_zoom
  assert_success
  assert_tool_installed_call_args "curl"
  refute_add_remote_signing_key_called
  refute_install_curl_called
  assert_install_call_args "--debian-family-package-name ${EXP_DEB_FILE_LOCATION} ${EXP_INSTALL_CALL_ARGS_SUFFIX}"
}

@test "${TEST_SUITE_PREFIX}installs curl IFF not already available on Debian-based distros" {
  mock_tool_installed 1
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" \
    BITNESS="32" run install_zoom
  assert_success
  assert_tool_installed_call_args "curl"
  refute_add_remote_signing_key_called
  assert_install_curl_called
  exp_download_url="${EXP_64_BIT_BASE_DOWNLOAD_URL}/zoom_i386.deb"
  assert_curl_call_args "-sSL ${exp_download_url} -o ${EXP_DEB_FILE_LOCATION}"
  assert_install_call_args "--debian-family-package-name ${EXP_DEB_FILE_LOCATION} ${EXP_INSTALL_CALL_ARGS_SUFFIX}"
}

@test "${TEST_SUITE_PREFIX}errors correctly with unsupported bitness on Debian-based distros" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${DEBIAN_DISTRO_FAMILY}" \
    BITNESS="wtf" run install_zoom
  assert_failure
  assert_error_call_args "Unsupported architecture bitness: 'wtf' for Zoom installation"
  refute_tool_installed_called
  refute_add_remote_signing_key_called
  refute_install_called
}

@test "${TEST_SUITE_PREFIX}installs correctly on 64 bit Fedora-based distros" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" \
    BITNESS="64" run install_zoom
  assert_success
  refute_tool_installed_called
  refute_install_curl_called
  exp_download_url="${EXP_64_BIT_BASE_DOWNLOAD_URL}/zoom_x86_64.rpm"
  assert_add_remote_signing_key_call_args "--key-url ${EXP_FEDORA_SIGNING_KEY_URL}"
  assert_install_call_args "--fedora-family-package-name ${exp_download_url} ${EXP_INSTALL_CALL_ARGS_SUFFIX}"
}

@test "${TEST_SUITE_PREFIX}installs correctly on 32 bit Fedora-based distros" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" \
    BITNESS="32" run install_zoom
  assert_success
  refute_tool_installed_called
  refute_install_curl_called
  exp_download_url="${EXP_32_BIT_BASE_DOWNLOAD_URL}/zoom_i686.rpm"
  assert_add_remote_signing_key_call_args "--key-url ${EXP_FEDORA_SIGNING_KEY_URL}"
  assert_install_call_args "--fedora-family-package-name ${exp_download_url} ${EXP_INSTALL_CALL_ARGS_SUFFIX}"
}

@test "${TEST_SUITE_PREFIX}errors correctly with unsupported bitness on Fedora-based distros" {
  OPERATING_SYSTEM="${LINUX_OS}" LINUX_DISTRO_FAMILY="${FEDORA_DISTRO_FAMILY}" \
    BITNESS="hmm" run install_zoom
  assert_failure
  assert_error_call_args "Unsupported architecture bitness: 'hmm' for Zoom installation"
  refute_tool_installed_called
  refute_add_remote_signing_key_called
  refute_install_called
}
