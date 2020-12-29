#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/security/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/security/authy/authy.sh
source "${SECURITY_DIRECTORY}/authy/authy.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_SECURITY_SUITE_PREFIX}::authy::install_authy::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  mock_install
  run install_authy
  assert_success
  assert_call_args "--application-name Authy (Twilio) --snap-name authy --snap-prefix --beta --prefer-snap --mac-package-name authy --mac-package-prefix --cask"
}
