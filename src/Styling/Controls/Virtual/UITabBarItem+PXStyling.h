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
//  UITabBarItem+PXStyling.h
//  Pixate
//
//  Created by Kevin Lindsey on 10/31/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PXVirtualControl.h"

/**
 *
 *  UITabBarItem supports the following element name:
 *
 *  - tab-bar-item
 *
 *  UITabBarItem supports the following pseudo-class states:
 *
 *  - normal (default)
 *  - selected
 *  - unselected
 *
 *  UITabBarItem supports the following properties:
 *
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXAttributedTextStyler
 *
 */
@interface UITabBarItem (PXStyling) <PXVirtualControl>

// make styleParent writeable here
@property (nonatomic, readwrite, weak) id pxStyleParent;

@end
