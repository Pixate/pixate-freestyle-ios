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
//  PXUILabel.h
//  Pixate
//
//  Created by Paul Colton on 9/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/* Don't think anyone else needs these:
extern NSString *const kDefaultCacheLabelShadowColor;
extern NSString *const kDefaultCacheLabelShadowOffset;
extern NSString *const kDefaultCacheLabelFont;
extern NSString *const kDefaultCacheLabelHighlightTextColor;
extern NSString *const kDefaultCacheLabelTextColor;
extern NSString *const kDefaultCacheLabelText;
*/

/**
 *
 *  UILabel supports the following element name:
 *
 *  - label
 *
 *  UILabel supports the following pseudo-class states:
 *
 *  - normal
 *  - highlighted
 *
 *  UILabel supports the following children:
 *
 *  - attributed-text
 *
 *  UILabel supports the following properties:
 *
 *  - PXTransformStyler
 *  - PXLayoutStyler
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXTextShadowStyler
 *  - PXFontStyler
 *  - PXPaintStyler
 *  - PXTextContentStyler
 *  - text-align: left | center | right
 *  - text-transform: lowercase | uppercase | capitalize
 *  - text-overflow: clip | ellipsis | ellipsis-head | ellipsis-middle | ellipsis-tail | character-wrap | word-wrap
 *
 *  UILabel attributed-text supports the following properties:
 *
 *  - PXAttributedTextStyler 
 *
 */
@interface PXUILabel : UILabel

@end
