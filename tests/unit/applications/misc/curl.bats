#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/misc/curl/curl.sh
source "${MISC_DIRECTORY}/curl/curl.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_MISC_SUITE_PREFIX}::curl::install_curl::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  mock_install
  run install_curl
  assert_success
  assert_install_call_args "--application-name cURL --debian-family-package-name curl --fedora-family-package-name curl --mac-package-name curl"
}
