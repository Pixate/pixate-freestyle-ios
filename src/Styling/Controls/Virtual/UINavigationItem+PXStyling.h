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
//  UINavigationItem+PXStyling.h
//  Pixate
//
//  Created by Paul Colton on 10/15/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PXStyleable.h"
#import "PXVirtualControl.h"

/**
 *
 *  UINavigationItem supports the following element name:
 *
 *  - navigation-item
 *
 *  UINavigationItem supports the following properties:
 *
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXOpacityStyler
 *  - PXTextContentStyler
 *  - text-transform: lowercase | uppercase | capitalize
 *
 *  UINavigationItem adds support for the following children:
 *
 *  - back-bar-button // see bar-button-item
 *  - left-bar-button // see bar-button-item
 *  - right-bar-button // see bar-button-item
 *
 */

@interface UINavigationItem (PXStyling) <PXVirtualControl>

// make styleParent writeable here
@property (nonatomic, readwrite, weak) id pxStyleParent;

// make pxStyleElementName writeable here
@property (nonatomic, readwrite, copy) NSString *pxStyleElementName;

@end
