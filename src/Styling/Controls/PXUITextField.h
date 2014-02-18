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
//  PXUITextField.h
//  Pixate
//
//  Created by Kevin Lindsey on 10/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *
 *  UITextField supports the following element name:
 *
 *  - text-field
 *
 *  UITextField supports the following children:
 *
 *  - placeholder
 *  - attributed-text
 *
 *  UITextField supports the following properties
 *
 *  - PXTransformStyler
 *  - PXLayoutStyler
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXFontStyler
 *  - PXColorStyler
 *  - PXTextContentStyler
 *  - text-align: left | center | right
 *  - -ios-border-style: none | line | bezel | rounded-rect
 *  - padding: <padding>
 *  - padding-top: <length>
 *  - padding-right: <length>
 *  - padding-bottom: <length>
 *  - padding-left: <length>
 *
 *  UITextField placeholder supports the following properties
 *
 *  - PXTextShadowStyler
 *  - PXFontStyler
 *  - PXColorStyler
 *  - PXTextContentStyler
 *
 *  UITextField attributed-text supports the following properties:
 *
 *  - PXAttributedTextStyler
 *
 */
@interface PXUITextField : UITextField

@end
