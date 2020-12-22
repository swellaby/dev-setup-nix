# shellcheck shell=bash

load "../../../submodules/bats-support/load"
load "../../../submodules/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../test_helpers.sh"

readonly BASE_TEST_SUITE_PREFIX="utils::"
declare -xr UTILS_SOURCE_PATH="${BATS_TEST_DIRNAME}/../../../src/utils.sh"
