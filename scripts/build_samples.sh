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

# This script builds all of the samples in the samples subdirectory.

. ${PX_FREESTYLE_SCRIPT:-$(dirname $0)}/common.sh

# valid arguments are: no-value, "Debug" and "Release" (default)
BUILDCONFIGURATION=${1:-Release}

test -x "$XCODEBUILD" || die 'Could not find xcodebuild in $PATH'

# -----------------------------------------------------------------------------
progress_message Building samples.

# -----------------------------------------------------------------------------
# Call out to build .framework
#
if is_outermost_build; then
  . $PX_FREESTYLE_SCRIPT/build_framework.sh -n -c Release
fi

# -----------------------------------------------------------------------------
# Determine which samples to build.
#

# Certain subdirs of samples are not samples to be built, exclude them from the find query
PX_FREESTYLE_SAMPLES_EXCLUDED=(AllSamples.xcworkspace)
for excluded in "${PX_FREESTYLE_SAMPLES_EXCLUDED[@]}"; do
  if [ -n "$PX_FREESTYLE_FIND_ARGS" ]; then
    PX_FREESTYLE_FIND_ARGS="$PX_FREESTYLE_FIND_ARGS -o"
  fi
  PX_FREESTYLE_FIND_ARGS="$PX_FREESTYLE_FIND_ARGS -name $excluded"
done


PX_FREESTYLE_FIND_SAMPLES_CMD="find $PX_FREESTYLE_SAMPLES -type d -depth 1 ! ( $PX_FREESTYLE_FIND_ARGS )"

# -----------------------------------------------------------------------------
# Build each sample
#
function xcode_build_sample() {
  cd $PX_FREESTYLE_SAMPLES/$1
  progress_message "Compiling '${1}' for platform '${2}(${3})' using configuration '${4}'."
  $XCODEBUILD \
    -alltargets \
    -configuration "${4}" \
    -sdk $2 \
    ARCHS=$3 \
    SYMROOT=$PX_FREESTYLE_BUILD \
    clean build \
    || die "XCode build failed for sample '${1}' for platform '${2}(${3})' using configuration '${4}'."
}

for sampledir in `$PX_FREESTYLE_FIND_SAMPLES_CMD`; do
  xcode_build_sample `basename $sampledir` "iphonesimulator7.1" "i386" "$BUILDCONFIGURATION"
done

# -----------------------------------------------------------------------------
# Done
#
common_success
