#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/note/standard-notes/standard_notes.sh
source "${NOTE_DIRECTORY}/standard-notes/standard_notes.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_NOTE_SUITE_PREFIX}::standard_notes::install_standard_notes::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  mock_install
  run install_standard_notes
  assert_success
  assert_install_call_args "--application-name Standard Notes --snap-name standard-notes --prefer-snap --mac-package-prefix --cask --mac-package-name standard-notes"
}
