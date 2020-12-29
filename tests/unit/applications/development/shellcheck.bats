#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/development/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/development/shellcheck/shellcheck.sh
source "${DEVELOPMENT_DIRECTORY}/shellcheck/shellcheck.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_DEVELOPMENT_SUITE_PREFIX}::shellcheck::install_shellcheck::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  function install() {
    echo "$*"
  }

  run install_shellcheck
  assert_success
  assert_call_args "--application-name ShellCheck --debian-family-package-name shellcheck --fedora-family-package-name ShellCheck --mac-package-name shellcheck"
}
