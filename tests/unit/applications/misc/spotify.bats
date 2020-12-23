#!/usr/bin/env bats

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"
# shellcheck source=src/applications/misc/spotify/spotify.sh
source "${BATS_TEST_DIRNAME}/../../../../${APPLICATIONS_MISC_DIRECTORY_PATH_FROM_ROOT}/spotify/spotify.sh"

load "../../../../${BATS_SUPPORT_LOAD_PATH_FROM_ROOT}"
load "../../../../${BATS_ASSERT_LOAD_PATH_FROM_ROOT}"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_MISC_SUITE_PREFIX}::spotify::install_spotify::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  function install() {
    echo "$*"
  }
  run install_spotify
  assert_equal "$status" 0
  assert_call_args "--application-name Spotify --snap-name spotify --prefer-snap --mac-package-name spotify --mac-package-prefix --cask"
}

