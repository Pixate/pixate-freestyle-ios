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

# This script builds the API documentation from source-level comments.
# This script requires appledoc be installed: https://github.com/tomaz/appledoc

. ${PX_FREESTYLE_SCRIPT:-$(dirname $0)}/common.sh

# -----------------------------------------------------------------------------
# Build pre-requisites
#
if is_outermost_build; then
    . $PX_FREESTYLE_SCRIPT/build_framework.sh -n
fi

APPLEDOC_PATH="$PX_FREESTYLE_BUILD"/appledoc
progress_message "$APPLEDOC_PATH"
if [ ! -f "$APPLEDOC_PATH" ]; then
  progress_message Building appledoc
  pushd "$PX_FREESTYLE_ROOT"/vendor/appledoc/ >/dev/null
  ./install-appledoc.sh -b "$PX_FREESTYLE_BUILD" || die 'Could not build appledoc'
  popd >/dev/null
fi

# -----------------------------------------------------------------------------
# Build docs
#
progress_message Building Documentation.
test -d $PX_FREESTYLE_BUILD \
  || mkdir -p $PX_FREESTYLE_BUILD \
  || die "Could not create directory $PX_FREESTYLE_BUILD"

cd $PX_FREESTYLE_SRC

rm -rf $PX_FREESTYLE_FRAMEWORK_DOCS

hash "$APPLEDOC_PATH" &>/dev/null
if [ "$?" -eq "0" ]; then
    APPLEDOC_DOCSET_NAME="Facebook SDK $PX_FREESTYLE_VERSION_SHORT for iOS"
    $APPLEDOC_PATH --project-name "$APPLEDOC_DOCSET_NAME" \
	--project-company "Facebook" \
	--company-id "com.facebook" \
	--preprocess-headerdoc \
	--docset-bundle-filename "$PX_FREESTYLE_DOCSET_NAME" \
	--docset-feed-name "$APPLEDOC_DOCSET_NAME" \
	--docset-install-path "$PX_FREESTYLE_BUILD" \
	--exit-threshold 2 \
	--no-install-docset \
	--search-undocumented-doc \
	--keep-undocumented-members \
	--keep-undocumented-objects \
	--explicit-crossref \
	$PX_FREESTYLE_FRAMEWORK/Headers \
    || die 'appledoc execution failed'
else
    die "appledoc not installed, unable to build documentation"
fi

# Temporary workaround to an appledoc bug that drops protocol names.
function replace_string() {
    perl -pi -e "s/$1/$2/" $3
}

DOCSDIR="$DOCSET"/docset/Contents/Resources/Documents
replace_string 'id&lt;&gt; delegate' 'id&lt;FBFriendPickerDelegate&gt; delegate' "$DOCSDIR"/Classes/FBFriendPickerViewController.html
replace_string 'id&lt;&gt; delegate' 'id&lt;FBPlacePickerDelegate&gt; delegate' "$DOCSDIR"/Classes/FBPlacePickerViewController.html
replace_string 'id&lt;&gt; selection' 'id&lt;FBGraphPlace&gt; selection' "$DOCSDIR"/Classes/FBPlacePickerViewController.html
replace_string 'id&lt;&gt; graphObject' 'id&lt;FBGraphObject&gt; graphObject' "$DOCSDIR"/Classes/FBRequest.html
replace_string 'id&lt;&gt; application' 'id&lt;FBGraphObject&gt; application' "$DOCSDIR"/Protocols/FBOpenGraphAction.html
replace_string 'id&lt;&gt; from' 'id&lt;FBGraphUser&gt; from' "$DOCSDIR"/Protocols/FBOpenGraphAction.html
replace_string 'id&lt;&gt; place' 'id&lt;FBGraphPlace&gt; place' "$DOCSDIR"/Protocols/FBOpenGraphAction.html
replace_string 'id&lt;&gt; location' 'id&lt;FBGraphLocation&gt; location' "$DOCSDIR"/Protocols/FBGraphUser.html
replace_string 'id&lt;&gt; location' 'id&lt;FBGraphLocation&gt; location' "$DOCSDIR"/Protocols/FBGraphPlace.html

# -----------------------------------------------------------------------------
# Done
#
common_success
