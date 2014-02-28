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
//  UIBarButtonItem+PXStyling.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PXVirtualControl.h"

/**
 *
 *  UIBarButtonItem supports the following element name:
 *
 *  - bar-button-item
 *
 *  UIBarButtonItem supports the following  children:
 *
 *  - icon
 *
 *  UIBarButtonItem icon supports the following properties:
 *
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - -ios-rendering-mode: original | template | automatic // iOS7 or later
 *
 *  UIBarButtonItem supports the following properties:
 *
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXAttributedTextStyler
 *  - -ios-tint-color: <paint>
 *
 *  UIBarButtonItem supports the following pseudo-class states:
 *
 *  - normal
 *  - highlighted
 *  - disabled
 *
 */
@interface UIBarButtonItem (PXStyling) <PXVirtualControl>

// make styleParent writeable here
@property (nonatomic, readwrite, weak) id pxStyleParent;
    
// make pxStyleElementName writeable here
@property (nonatomic, readwrite, copy) NSString *pxStyleElementName;

@end
