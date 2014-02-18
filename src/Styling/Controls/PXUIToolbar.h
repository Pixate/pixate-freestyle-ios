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
//  PXUIToolbar.h
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *
 *  UIToolbar supports the following element name:
 *
 *  - toolbar
 *
 *  UIToolbar adds support for the following children:
 *
 *  - [bar-button-item](#uibarbuttonitem)
 *  - button-appearance
 *
 *  UIToolbar supports the following properties:
 *
 *  - PXLayoutStyler
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXBarShadowStyler
 *  - PXAnimationStyler
 *  - color: <paint>
 *  - -ios-tint-color: <paint>
 *
 *  UIToolbar button-appearance supports the following properties:
 *
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXFontStyler
 *  - PXPaintStyler
 *  - ios-tint-color: <color>
 *
 *  NOTE: For opacity, 1.0 is opaque and anything less means non-opaque
 *  NOTE: Setting an image or background pattern currently applies to all buttons inside all Toolbars.
 *
 */
@interface PXUIToolbar : UIToolbar

@end
