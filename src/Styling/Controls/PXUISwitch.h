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
//  PXUISwitch.h
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *
 *  UISwitch supports the following element name:
 *
 *  - switch
 *
 *  UISwitch adds support for the following children:
 *
 *  - thumb // iOS 6.x only
 *  - on    // iOS 6.x only
 *  - off   // iOS 6.x only
 *
 *  UISwitch supports the following properties:
 *
 *  - PXTransformStyler
 *  - PXLayoutStyler
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - color: <color>
 *  - off-color: <color>    // iOS 6.x only
 *  - -ios-tint-color: <color>
 *  - PXAnimationStyler
 *
 *  UISwitch on supports the following properties:
 *
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *
 *  UISwitch off supports the following properties:
 *
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *
 *  UISwitch thumb supports the following properties:
 *
 *  - color: <color>
 *
 */
@interface PXUISwitch : UISwitch

@end
