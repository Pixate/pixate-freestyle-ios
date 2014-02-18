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
//  UIBarItem+PXStyling.h
//  Pixate
//
//  Created by Paul Colton on 10/7/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PXStyleable.h"

@interface UIBarItem (PXStyling) <PXStyleable>

@property (nonatomic) PXStylingMode styleMode UI_APPEARANCE_SELECTOR;

// Container for the pxStyleElementName used by base classes
@property (nonatomic, readwrite, copy) NSString *styleElementName;

@end
