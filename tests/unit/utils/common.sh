# shellcheck shell=bash

load "../../../submodules/bats-support/load"
load "../../../submodules/bats-assert/load"

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../test_helpers.sh"

declare -xr BASE_TEST_SUITE_PREFIX="utils::"
# shellcheck disable=
readonly UTILS_SOURCE_PATH="${BATS_TEST_DIRNAME}/../../../src/utils.sh"

