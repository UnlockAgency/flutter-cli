NAME="_PROJECT_NAME_"
FASTLANE_EXTRA_ARGUMENTS="project_name:Runner\ scheme:Runner\ configuration:Release\ target:Runner"
EXTRA_ARGUMENTS=--flutter true
RELEASE_PRODUCTION_ENVIRONMENT="release"

## --------------------------------

TMP_DIR:=$(shell mktemp -d)
MAKEFILE2:=$(shell git archive --remote=git@gitlab.e-sites.nl:team-i/ios/CI.git HEAD: Makefile | tar -x -C $(TMP_DIR))
include $(TMP_DIR)/Makefile
