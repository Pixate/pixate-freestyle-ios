/*
 * Copyright 2012-present Pixate, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  PXStylingMacros.h
//  Pixate
//
//  Created by Paul Colton on 10/7/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#ifndef Pixate_PXStylingMacros_h
#define Pixate_PXStylingMacros_h

#import "PXMacrosCommon.h"
#import "UIView+PXStyling.h"

// Third-party support macros
#import "PXTitaniumMacros.h"

//
// Styling Macros
//

#define PX_RECURSIVE 1
#define PX_NONRECURSIVE 0

#define PX_LAYOUT_SUBVIEWS_OVERRIDE             PX_LAYOUT_SUBVIEWS_IMP(PX_NONRECURSIVE)
#define PX_LAYOUT_SUBVIEWS_OVERRIDE_RECURSIVE   PX_LAYOUT_SUBVIEWS_IMP(PX_RECURSIVE)

#define PX_LAYOUT_SUBVIEWS_IMP(RECURSE) \
- (void)layoutSubviews	\
{	\
    callSuper0(SUPER_PREFIX, _cmd);	\
    \
    if(RECURSE) { \
        [self updateStyles]; \
    } else { \
        [self updateStylesNonRecursively]; \
    } \
}

#endif // Pixate_PXStylingMacros_h

