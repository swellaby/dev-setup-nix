#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/misc/spotify/spotify.sh
source "${MISC_DIRECTORY}/spotify/spotify.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_MISC_SUITE_PREFIX}::spotify::install_spotify::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  function install() {
    echo "$*"
  }
  run install_spotify
  assert_equal "$status" 0
  assert_call_args "--application-name Spotify --snap-name spotify --prefer-snap --mac-package-name spotify --mac-package-prefix --cask"
}

