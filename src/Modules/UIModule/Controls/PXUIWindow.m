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
//  PXUIWindow.m
//  Pixate
//
//  Created by Paul Colton on 8/27/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXUIWindow.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXViewUtils.h"
#import "PXPaintStyler.h"

#import "PXStylingMacros.h"

@implementation PXUIWindow

+ (void)initialize
{
    if (self != PXUIWindow.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"window"];
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        stylers = @[
                    PXPaintStyler.sharedInstanceForTintColor,
                    ];
    });
    
	return stylers;
}

- (NSDictionary *)viewStylersByProperty
{
    static NSDictionary *map = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        map = [PXStyleUtils viewStylerPropertyMapForStyleable:self];
    });

    return map;
}

// Styling
PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
