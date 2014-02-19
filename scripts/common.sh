#!/bin/sh
#
# Copyright 2014-present Pixate, Inc.
# 
# This version based on the original verson by:
#
# Copyright 2010-present Facebook.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This script sets up a consistent environment for the other scripts in this directory.

# Set up paths for a specific clone of the SDK source
if [ -z "$PX_FREESTYLE_SCRIPT" ]; then
  # ---------------------------------------------------------------------------
  # Set up paths
  #

  # The directory containing this script
  # We need to go there and use pwd so these are all absolute paths
  pushd $(dirname $BASH_SOURCE[0]) >/dev/null
  PX_FREESTYLE_SCRIPT=$(pwd)
  popd >/dev/null

  # The root directory where the Pixate Freestyle for iOS is cloned
  PX_FREESTYLE_ROOT=$(dirname $PX_FREESTYLE_SCRIPT)

  # Path to source files for Pixate Freestyle
  PX_FREESTYLE_SRC=$PX_FREESTYLE_ROOT/src

  # Path to sample files for Pixate Freestyle
  PX_FREESTYLE_SAMPLES=$PX_FREESTYLE_ROOT/samples

    # Path to theme files for Pixate Freestyle
  PX_FREESTYLE_THEMES=$PX_FREESTYLE_ROOT/themes


  # The directory where the target is built
  PX_FREESTYLE_BUILD=$PX_FREESTYLE_ROOT/build
  PX_FREESTYLE_BUILD_LOG=$PX_FREESTYLE_BUILD/build.log

  # The name of the Pixate Freestyle for iOS
  PX_FREESTYLE_BINARY_NAME=PixateFreestyle

  # The name of the Pixate Freestyle for iOS framework
  PX_FREESTYLE_FRAMEWORK_NAME=${PX_FREESTYLE_BINARY_NAME}.framework

  # The path to the built Pixate Freestyle for iOS .framework
  PX_FREESTYLE_FRAMEWORK=$PX_FREESTYLE_BUILD/$PX_FREESTYLE_FRAMEWORK_NAME

  # Extract the lib version from Version.h
  PX_FREESTYLE_VERSION_RAW=$(sed -n 's/.*PIXATE_VERSION \"\(.*\)\"/\1/p' ${PX_FREESTYLE_SRC}/Version.h)
  PX_FREESTYLE_VERSION_MAJOR=$(echo $PX_FREESTYLE_VERSION_RAW | awk -F'.' '{print $1}')
  PX_FREESTYLE_VERSION_MINOR=$(echo $PX_FREESTYLE_VERSION_RAW | awk -F'.' '{print $2}')
  PX_FREESTYLE_VERSION_REVISION=$(echo $PX_FREESTYLE_VERSION_RAW | awk -F'.' '{print $3}')
  PX_FREESTYLE_VERSION_MAJOR=${PX_FREESTYLE_VERSION_MAJOR:-0}
  PX_FREESTYLE_VERSION_MINOR=${PX_FREESTYLE_VERSION_MINOR:-0}
  PX_FREESTYLE_VERSION_REVISION=${PX_FREESTYLE_VERSION_REVISION:-0}
  PX_FREESTYLE_VERSION=$PX_FREESTYLE_VERSION_MAJOR.$PX_FREESTYLE_VERSION_MINOR.$PX_FREESTYLE_VERSION_REVISION
  PX_FREESTYLE_VERSION_SHORT=$(echo $PX_FREESTYLE_VERSION | sed 's/\.0$//')

  # The name of the docset (only rev the docset name on each major version)
  PX_FREESTYLE_DOCSET_NAME=com.pixate.pixate-freestyle-${PX_FREESTYLE_VERSION_MAJOR}_0-for-iOS.docset

  # The path to the framework docs
  PX_FREESTYLE_FRAMEWORK_DOCS=$PX_FREESTYLE_BUILD/$PX_FREESTYLE_DOCSET_NAME
fi

# Set up one-time variables
if [ -z $PX_FREESTYLE_ENV ]; then
  PX_FREESTYLE_ENV=env1
  PX_FREESTYLE_BUILD_DEPTH=0

  # Explains where the log is if this is the outermost build or if
  # we hit a fatal error.
  function show_summary() {
    test -r $PX_FREESTYLE_BUILD_LOG && echo "Build log is at $PX_FREESTYLE_BUILD_LOG"
  }

  # Determines whether this is out the outermost build.
  function is_outermost_build() {
      test 1 -eq $PX_FREESTYLE_BUILD_DEPTH
  }

  # Calls show_summary if this is the outermost build.
  # Do not call outside common.sh.
  function pop_common() {
    PX_FREESTYLE_BUILD_DEPTH=$(($PX_FREESTYLE_BUILD_DEPTH - 1))
    test 0 -eq $PX_FREESTYLE_BUILD_DEPTH && show_summary
  }

  # Deletes any previous build log if this is the outermost build.
  # Do not call outside common.sh.
  function push_common() {
    test 0 -eq $PX_FREESTYLE_BUILD_DEPTH && \rm -f $PX_FREESTYLE_BUILD_LOG
    PX_FREESTYLE_BUILD_DEPTH=$(($PX_FREESTYLE_BUILD_DEPTH + 1))
  }

  # Echoes a progress message to stderr
  function progress_message() {
      echo "$@" >&2
  }

  # Any script that includes common.sh must call this once if it finishes
  # successfully.
  function common_success() { 
      pop_common
      return 0
  }

  # Call this when there is an error.  This does not return.
  function die() {
    echo ""
    echo "FATAL: $*" >&2
    show_summary
    exit 1
  }

  test -n "$XCODEBUILD"   || XCODEBUILD=$(which xcodebuild)
  test -n "$LIPO"         || LIPO=$(which lipo)
  test -n "$PACKAGEBUILD" || PACKAGEBUILD=$(which pkgbuild)
  test -n "$PRODUCTBUILD" || PRODUCTBUILD=$(which productbuild)
  test -n "$PRODUCTSIGN"  || PRODUCTSIGN=$(which productsign)

  # < XCode 4.3.1
  if [ ! -x "$XCODEBUILD" ]; then
    # XCode from app store
    XCODEBUILD=/Applications/XCode.app/Contents/Developer/usr/bin/xcodebuild
  fi

fi

# Increment depth every time we . this file.  At the end of any script
# that .'s this file, there should be a call to common_finish to decrement.
push_common
