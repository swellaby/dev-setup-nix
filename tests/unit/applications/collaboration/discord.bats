#!/usr/bin/env bats

# shellcheck source=tests/unit/applications/misc/common.sh
source "${BATS_TEST_DIRNAME}/common.sh"
# shellcheck source=src/applications/collaboration/discord/discord.sh
source "${COLLABORATION_DIRECTORY}/discord/discord.sh"

readonly TEST_SUITE_PREFIX="${APPLICATIONS_COLLABORATION_SUITE_PREFIX}::discord::install_discord::"

@test "${TEST_SUITE_PREFIX}uses correct args" {
  function install() {
    echo "$*"
  }
  run install_discord
  assert_equal "$status" 0
  assert_call_args "--application-name Discord --snap-name discord --prefer-snap --mac-package-name discord --mac-package-prefix --cask"
}

