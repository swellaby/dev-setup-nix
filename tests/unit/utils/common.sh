# shellcheck shell=bash

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../test_helpers.sh"

load "../../../${BATS_SUPPORT_LOAD_PATH_FROM_ROOT}"
load "../../../${BATS_ASSERT_LOAD_PATH_FROM_ROOT}"

declare -xr BASE_TEST_SUITE_PREFIX="utils::"
# Use is verified, known to be consumed
# shellcheck disable=SC2034
readonly UTILS_SOURCE_PATH="${BATS_TEST_DIRNAME}/../../../src/utils.sh"
