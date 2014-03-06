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

// Import common stuff
#import "PXMacrosCommon.h"

// Third-party support macros
#import "PXTitaniumMacros.h"

//
// Styling Macros
//

#define PX_RECURSIVE 1
#define PX_NONRECURSIVE 0

#define PXSTYLE_VIEW_UPDATER PXSTYLE_LAYOUTSUBVIEWS(PX_NONRECURSIVE)
#define PXSTYLE_VIEW_UPDATER_RECURSIVE PXSTYLE_LAYOUTSUBVIEWS(PX_RECURSIVE)

#define PXSTYLE_LAYOUTSUBVIEWS(RECURSE) \
- (void)layoutSubviews	\
{	\
    callSuper0(SUPER_PREFIX, _cmd);	\
    \
    PXSTYLE_LAYOUTSUBVIEWS_IMP(self, RECURSE); \
}

#define PXSTYLE_LAYOUTSUBVIEWS_IMP(VIEW, RECURSE) \
    if (VIEW.styleMode == PXStylingNormal) \
    { \
        if((BOOL)RECURSE) \
        { \
            for (id<PXStyleable> child in VIEW.pxStyleChildren) \
            { \
                if ([child conformsToProtocol:@protocol(PXVirtualControl)] && child.styleMode == PXStylingNormal) \
                { \
                    [PXStyleUtils enumerateStyleableDescendants:child usingBlock:^(id<PXStyleable> styleable, BOOL *stop, BOOL *stopDescending) { \
                        if ([styleable conformsToProtocol:@protocol(PXVirtualControl)] && styleable.styleMode == PXStylingNormal) \
                        { \
                            [PXStyleUtils updateStyleForStyleable:styleable]; \
                        } \
                    }]; \
                    [PXStyleUtils updateStyleForStyleable:child]; \
                } \
            } \
        } \
        [PXStyleUtils updateStylesForStyleable:VIEW andDescendants:((BOOL)RECURSE)]; \
    }

#endif // Pixate_PXStylingMacros_h

