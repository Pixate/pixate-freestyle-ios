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
# https://github.com/facebook/facebook-ios-sdk/downloads/FacebookSDK.framework.zip

. ${PX_FREESTYLE_SCRIPT:-$(dirname $0)}/common.sh
test -x "$PACKAGEBUILD" || die 'Could not find pkgbuild utility! Reinstall XCode?'
test -x "$PRODUCTBUILD" || die 'Could not find productbuild utility! Reinstall XCode?'
test -x "$PRODUCTSIGN" || die 'Could not find productsign utility! Reinstall XCode?'

PX_FREESTYLE_PGK_VERSION=$(sed -n 's/.*PIXATE_FREESTYLE_VERSION \"\(.*\)\"/\1/p' ${PX_FREESTYLE_SRC}/Version.h)
# In case the hotfix value is zero, we drop the .0
PX_FREESTYLE_NORMALIZED_PGK_VERSION=$(echo ${PX_FREESTYLE_PGK_VERSION} | sed  's/^\([0-9]*\.[0-9]*\)\.0/\1/')

COMPONENT_PX_FREESTYLE_PKG=$PX_FREESTYLE_BUILD/PixateFreestyle.pkg
PX_FREESTYLE_UNSIGNED_PKG=$PX_FREESTYLE_BUILD/PixateFreestyle-${PX_FREESTYLE_NORMALIZED_PGK_VERSION}-unsigned.pkg
PX_FREESTYLE_PKG=$PX_FREESTYLE_BUILD/PixateFreestyle-${PX_FREESTYLE_NORMALIZED_PGK_VERSION}.pkg

PX_FREESTYLE_BUILD_PACKAGE=$PX_FREESTYLE_BUILD/package
PX_FREESTYLE_BUILD_PACKAGE_FRAMEWORK_SUBDIR=Documents/PixateFreestyle
PX_FREESTYLE_BUILD_PACKAGE_FRAMEWORK=$PX_FREESTYLE_BUILD_PACKAGE/$PX_FREESTYLE_BUILD_PACKAGE_FRAMEWORK_SUBDIR
PX_FREESTYLE_BUILD_PACKAGE_SAMPLES=$PX_FREESTYLE_BUILD_PACKAGE/Documents/PixateFreestyle/Samples
PX_FREESTYLE_BUILD_PACKAGE_THEMES=$PX_FREESTYLE_BUILD_PACKAGE/Documents/PixateFreestyle/Themes
PX_FREESTYLE_BUILD_PACKAGE_DOCS=$PX_FREESTYLE_BUILD_PACKAGE/Library/Developer/Shared/Documentation/DocSets/$PX_FREESTYLE_DOCSET_NAME


CODE_SIGN_IDENTITY='Developer ID Installer: Pixate, Inc. (ANZCG56DAH)'

# -----------------------------------------------------------------------------
# Call out to build prerequisites.
#
if is_outermost_build; then
    # Building samples also builds the framework
    . $PX_FREESTYLE_SCRIPT/build_samples.sh -c Release
fi
echo Building Distribution.

# -----------------------------------------------------------------------------
# Build package directory structure
#
progress_message "Building package directory structure."
\rm -rf $PX_FREESTYLE_BUILD_PACKAGE
mkdir $PX_FREESTYLE_BUILD_PACKAGE \
  || die "Could not create directory $PX_FREESTYLE_BUILD_PACKAGE"
mkdir -p $PX_FREESTYLE_BUILD_PACKAGE_FRAMEWORK
mkdir -p $PX_FREESTYLE_BUILD_PACKAGE_SAMPLES
mkdir -p $PX_FREESTYLE_BUILD_PACKAGE_THEMES
#mkdir -p $PX_FREESTYLE_BUILD_PACKAGE_DOCS

\cp -R $PX_FREESTYLE_FRAMEWORK $PX_FREESTYLE_BUILD_PACKAGE_FRAMEWORK \
  || die "Could not copy $PX_FREESTYLE_FRAMEWORK"
\cp -R $PX_FREESTYLE_SAMPLES/ $PX_FREESTYLE_BUILD_PACKAGE_SAMPLES \
  || die "Could not copy $PX_FREESTYLE_BUILD_PACKAGE_SAMPLES"
\cp -R $PX_FREESTYLE_THEMES/ $PX_FREESTYLE_BUILD_PACKAGE_THEMES \
  || die "Could not copy $PX_FREESTYLE_BUILD_PACKAGE_THEMES"
#\cp -R $PX_FREESTYLE_FRAMEWORK_DOCS/Contents $PX_FREESTYLE_BUILD_PACKAGE_DOCS \
#  || die "Could not copy $$PX_FREESTYLE_FRAMEWORK_DOCS/Contents"
\cp $PX_FREESTYLE_ROOT/README.txt $PX_FREESTYLE_BUILD_PACKAGE/Documents/PixateFreestyle \
  || die "Could not copy README"
\cp $PX_FREESTYLE_ROOT/LICENSE $PX_FREESTYLE_BUILD_PACKAGE/Documents/PixateFreestyle \
  || die "Could not copy LICENSE"

# -----------------------------------------------------------------------------
# Fixup projects to point to the SDK framework
#
for fname in $(find $PX_FREESTYLE_BUILD_PACKAGE_SAMPLES -name "project.pbxproj" -print); do \
  sed "s|../../build|../..|g" \
    ${fname} > ${fname}.tmpfile  && mv ${fname}.tmpfile ${fname}; \
done

# -----------------------------------------------------------------------------
# Build .pkg from package directory
#
progress_message "Building .pkg from package directory."
# First use pkgbuild to create component package
\rm -rf $COMPONENT_PX_FREESTYLE_PKG
$PACKAGEBUILD --root "$PX_FREESTYLE_BUILD/package" \
 		 --identifier "com.pixate.pixate-freestyle.pkg" \
 		 --version $PX_FREESTYLE_NORMALIZED_PGK_VERSION   \
 		 $COMPONENT_PX_FREESTYLE_PKG || die "Failed to pkgbuild component package"

# Build product archive (note --resources should point to the folder containing the README)
\rm -rf $PX_FREESTYLE_UNSIGNED_PKG
$PRODUCTBUILD --distribution "$PX_FREESTYLE_SCRIPT/productbuild_distribution.xml" \
 			 --package-path $PX_FREESTYLE_BUILD \
			 --resources "$PX_FREESTYLE_BUILD/package/Documents/PixateFreestyle/" \
			 $PX_FREESTYLE_UNSIGNED_PKG || die "Failed to productbuild the product archive"

progress_message "Signing package."
\rm -rf $PX_FREESTYLE_PKG
$PRODUCTSIGN -s "$CODE_SIGN_IDENTITY" $PX_FREESTYLE_UNSIGNED_PKG $PX_FREESTYLE_PKG \
 || FAILED_TO_SIGN=1

if [ "$FAILED_TO_SIGN" == "1" ] ; then
  progress_message "Failed to sign the package. See https://our.intern.facebook.com/intern/wiki/index.php/Platform/Mobile/ContributingToMobileSDKs#Building_the_iOS_Distribution_with_PackageMaker"
fi

# -----------------------------------------------------------------------------
# Done
#
progress_message "Successfully built SDK distribution:"
if [ "$FAILED_TO_SIGN" != "1" ] ; then
  progress_message "  Signed : $PX_FREESTYLE_PKG"
fi
progress_message "  Unsigned : $PX_FREESTYLE_UNSIGNED_PKG"
common_success
