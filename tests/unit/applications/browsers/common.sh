# shellcheck shell=bash

# shellcheck source=tests/test_helpers.sh
source "${BATS_TEST_DIRNAME}/../../../test_helpers.sh"
# shellcheck source=src/applications/browsers/firefox/firefox.sh
source "${BATS_TEST_DIRNAME}/../../../../${APPLICATIONS_BROWSERS_DIRECTORY_PATH_FROM_ROOT}/firefox/firefox.sh"

load "../../../../${BATS_SUPPORT_LOAD_PATH_FROM_ROOT}"
load "../../../../${BATS_ASSERT_LOAD_PATH_FROM_ROOT}"
