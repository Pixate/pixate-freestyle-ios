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

# This script builds the FacebookSDK.framework that is distributed at
# https://github.com/facebook/facebook-ios-sdk/downloads/FacebookSDK.framework.tgz

. ${PX_FREESTYLE_SCRIPT:-$(dirname $0)}/common.sh

# process options, valid arguments -c [Debug|Release] -n 
BUILDCONFIGURATION=Debug
NOEXTRAS=1
while getopts ":ntc:" OPTNAME
do
  case "$OPTNAME" in
    "c")
      BUILDCONFIGURATION=$OPTARG
      ;;
    "n")
      NOEXTRAS=1
      ;;
    "t")
      NOEXTRAS=0
      ;;
    "?")
      echo "$0 -c [Debug|Release] -n"
      echo "       -c sets configuration (default=Debug)"
      echo "       -n no test run (default)"
      echo "       -t test run"
      die
      ;;
    ":")
      echo "Missing argument value for option $OPTARG"
      die
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options"
      die
      ;;
  esac
done

test -x "$XCODEBUILD" || die 'Could not find xcodebuild in $PATH'
test -x "$LIPO" || die 'Could not find lipo in $PATH'

PX_FREESTYLE_UNIVERSAL_BINARY=$PX_FREESTYLE_BUILD/${BUILDCONFIGURATION}-universal/$PX_FREESTYLE_BINARY_NAME

# -----------------------------------------------------------------------------

progress_message Building Framework.

# -----------------------------------------------------------------------------
# Compile binaries 
#
test -d $PX_FREESTYLE_BUILD \
  || mkdir -p $PX_FREESTYLE_BUILD \
  || die "Could not create directory $PX_FREESTYLE_BUILD"

cd $PX_FREESTYLE_SRC
function xcode_build_target() {
  echo "Compiling for platform: ${1}."
  $XCODEBUILD \
    RUN_CLANG_STATIC_ANALYZER=NO \
    -target "pixate-freestyle" \
    -sdk $1 \
    -configuration "${2}" \
    ARCHS="${3}" \
    VALID_ARCHS="${3}" \
    IPHONEOS_DEPLOYMENT_TARGET="${4}" \
    TARGET_BUILD_DIR=$PX_FREESTYLE_BUILD/${BUILDCONFIGURATION}$5 \
    BUILT_PRODUCTS_DIR=$PX_FREESTYLE_BUILD/${BUILDCONFIGURATION}$5 \
    SYMROOT=$PX_FREESTYLE_BUILD \
    clean build \
    || die "XCode build failed for platform: ${1}."
}

xcode_build_target "iphonesimulator7.0" "${BUILDCONFIGURATION}" "i386" "5.0" "i386"
xcode_build_target "iphonesimulator7.0" "${BUILDCONFIGURATION}" "x86_64" "7.0" "x86_64"
xcode_build_target "iphoneos7.0" "${BUILDCONFIGURATION}" "armv7 armv7s" "5.0" "Arm"
xcode_build_target "iphoneos7.0" "${BUILDCONFIGURATION}" "arm64" "7.0" "Arm64"

# -----------------------------------------------------------------------------
# Merge lib files for different platforms into universal binary
#
progress_message "Building $PX_FREESTYLE_BINARY_NAME library using lipo."

mkdir -p $(dirname $PX_FREESTYLE_UNIVERSAL_BINARY)

$LIPO \
  -create \
    $PX_FREESTYLE_BUILD/${BUILDCONFIGURATION}Arm/libpixate-freestyle.a \
    $PX_FREESTYLE_BUILD/${BUILDCONFIGURATION}Arm64/libpixate-freestyle.a \
    $PX_FREESTYLE_BUILD/${BUILDCONFIGURATION}i386/libpixate-freestyle.a \
    $PX_FREESTYLE_BUILD/${BUILDCONFIGURATION}x86_64/libpixate-freestyle.a \
  -output $PX_FREESTYLE_UNIVERSAL_BINARY \
  || die "lipo failed - could not create universal static library"

# -----------------------------------------------------------------------------
# Build .framework out of binaries
#
progress_message "Building $PX_FREESTYLE_FRAMEWORK_NAME."

\rm -rf $PX_FREESTYLE_FRAMEWORK
mkdir $PX_FREESTYLE_FRAMEWORK \
  || die "Could not create directory $PX_FREESTYLE_FRAMEWORK"
mkdir $PX_FREESTYLE_FRAMEWORK/Versions
mkdir $PX_FREESTYLE_FRAMEWORK/Versions/A
mkdir $PX_FREESTYLE_FRAMEWORK/Versions/A/Headers
mkdir $PX_FREESTYLE_FRAMEWORK/Versions/A/Resources

\cp \
  $PX_FREESTYLE_SRC/Framework/Resources/* \
  $PX_FREESTYLE_FRAMEWORK/Versions/A/Resources \
  || die "Error building framework while copying Resources"
\cp \
  $PX_FREESTYLE_BUILD/${BUILDCONFIGURATION}Arm/pixate-freestyle/*.h \
  $PX_FREESTYLE_FRAMEWORK/Versions/A/Headers \
  || die "Error building framework while copying SDK headers"
\cp \
  $PX_FREESTYLE_UNIVERSAL_BINARY \
  $PX_FREESTYLE_FRAMEWORK/Versions/A/PixateFreestyle \
  || die "Error building framework while copying PixateFreestyle"

# Current directory matters to ln.
cd $PX_FREESTYLE_FRAMEWORK
ln -s ./Versions/A/Headers ./Headers
ln -s ./Versions/A/Resources ./Resources
ln -s ./Versions/A/PixateFreestyle ./PixateFreestyle
cd $PX_FREESTYLE_FRAMEWORK/Versions
ln -s ./A ./Current

# -----------------------------------------------------------------------------
# Run unit tests 
#

if [ ${NOEXTRAS:-0} -eq  1 ];then
  progress_message "Skipping unit tests."
else
  progress_message "Running unit tests."
  cd $PX_FREESTYLE_SRC
  $PX_FREESTYLE_SCRIPT/run_tests.sh -c $BUILDCONFIGURATION pixate-freestyle-tests
fi

# -----------------------------------------------------------------------------
# Done
#

progress_message "Framework version info:" `perl -ne 'print "$1 " if (m/PIXATE_FREESTYLE_VERSION (.+)$/);' $PX_FREESTYLE_SRC/Version.h` 
common_success
