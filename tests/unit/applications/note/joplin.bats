#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/note/joplin/joplin.sh
source "${NOTE_DIRECTORY}/joplin/joplin.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_NOTE_SUITE_PREFIX}::joplin::install_joplin::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  mock_install
  run install_joplin
  assert_success
  assert_install_call_args "--application-name Joplin --snap-name joplin-desktop --prefer-snap --mac-package-prefix --cask --mac-package-name joplin"
}
