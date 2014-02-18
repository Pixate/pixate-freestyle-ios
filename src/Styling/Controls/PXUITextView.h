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
//  PXUITextView.h
//  Pixate
//
//  Created by Kevin Lindsey on 10/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *
 *  UITextView supports the following element name:
 *
 *  - text-view
 *
 *  UITextView supports the following children:
 *
 *  - attributed-text
 *
 *  UITextView supports the following properties
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
 *  - content-offset: <size>
 *  - content-size: <size>
 *  - content-inset: <insets>
 *  - PXAnimationStyler
 *
 *  UITextView attributed-text supports the following properties:
 *
 *  - PXAttributedTextStyler
 *
 */

@interface PXUITextView : UITextView

@end
