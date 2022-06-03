#!/bin/bash

#set -o errexit

#if [ "$RUN_CLI" = "" ]; then
#  exit 0
#fi

if [ "$GHUNIT_UI_CLI" = "" ] && [ "$GHUNIT_AUTORUN" = "" ]; then
    exit 0
fi

if [ ! -e "$BUILD_DIR/test-coverage/" ]; then
    mkdir -p "$BUILD_DIR/test-coverage/"
fi

eval "lcov --test-name AppMakr --output-file \"$BUILD_DIR\"/test-coverage/AppMakr-iOS-Coverage_tmp.info --capture --directory \"$CONFIGURATION_TEMP_DIR\"/appbuildrTests.build/Objects-normal/i386/"


eval "lcov --remove \"$BUILD_DIR\"/test-coverage/AppMakr-iOS-Coverage_tmp.info \"*/Classes/*/*\" --output-file \"$BUILD_DIR\"/test-coverage/AppMakr-iOS-Coverage_tmp.info"

eval "lcov --extract \"$BUILD_DIR\"/test-coverage/AppMakr-iOS-Coverage_tmp.info \"*/Classes/*\" --output-file \"$BUILD_DIR\"/test-coverage/AppMakr-iOS-Coverage.info"

eval "rm -rf \"$BUILD_DIR\"/test-coverage/AppMakr-iOS-Coverage_tmp.info"

eval "genhtml --title \"AppMakr iOS\"  --output-directory \"$BUILD_DIR\"/test-coverage \"$BUILD_DIR\"/test-coverage/AppMakr-iOS-Coverage.info --legend"

exit $RETVAL
