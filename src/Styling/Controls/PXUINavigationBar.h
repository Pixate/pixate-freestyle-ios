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
//  PXUINavigationBar.h
//  Pixate
//
//  Created by Paul Colton on 10/8/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *
 *  UINavigationBar supports the following element name:
 *
 *  - navigation-bar
 *
 *  UINavigationBar supports the following pseudo-class states:
 *
 *  - default (default)
 *  - landscape-iphone
 *
 *  UINavigationBar supports the following properties:
 *
 *  - PXTransformStyler
 *  - PXLayoutStyler
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXBarMetricsAdjustmentStyler
 *  - PXFontStyler
 *  - PXPaintStyler
 *  - PXBarShadowStyler
 *  - color: <paint> // Deprecated in 1.1. Please use 'color' on the 'title' child element
 *  - text-shadow: <shadow> // Deprecated in 1.1. Please use 'text-shadow' on the 'title' child element
 *  - font-family: <string> // Deprecated in 1.1. Please use 'font-family' on the 'title' child element
 *  - font-size: <length> // Deprecated in 1.1. Please use 'font-size' on the 'title' child element
 *  - font-style: normal | italic | oblique // Deprecated in 1.1. Please use 'font-style' on the 'title' child element
 *  - font-weight: normal | bold | black | heavy | extra-bold | ultra-bold | semi-bold | demi-bold | medium | light | extra-thin | ultra-thin | thin | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 // Deprecated in 1.1. Please use 'font-weight' on the 'title' child element
 *  - font-stretch: normal | ultra-condensed | extra-condensed | condensed | semi-condensed | semi-expanded | expanded | extra-expanded | ultra-expanded // Deprecated in 1.1. Please use 'font-stretch' on the 'title' child element
 *  - PXTextContentStyler
 *  - text-transform: lowercase | uppercase | capitalize
 *
 *  UINavigationBar adds support for the following children:
 *
 *  - title
 *  - navigation-item
 *  - back-indicator // iOS 7+
 *  - back-indicator-mask // iOS 7+
 *  - button-appearance
 *  - back-button-appearance
 *
 *  UINavigationBar title supports the following properties:
 *
 *  - PXTextShadowStyler
 *  - PXFontStyler
 *  - PXPaintStyler
 *
 *  UINavigationBar back-indicator supports the following properties:
 *
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *
 *  UINavigationBar back-indicator-mask supports the following properties:
 *
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *
 *  UINavigationBar button-appearance supports the following properties:
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
 *  UINavigationBar back-button-appearance supports the following properties:
 *
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *
 *  NOTE: For opacity, 1.0 is opaque and anything less means non-opaque
 *  NOTE: See UIBarButtonItem properties for back-,left-,right-bar-buttons
 *
 **/
@interface PXUINavigationBar : UINavigationBar

@end
