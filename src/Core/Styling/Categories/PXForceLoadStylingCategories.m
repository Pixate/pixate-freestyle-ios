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
//  PXForceLoadStylingCategories.m
//  Pixate
//
//  Created by Paul Colton on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXForceLoadStylingCategories.h"
#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "NSObject+PXStyling.h"
#import "NSObject+PXSubclass.h"
#import "NSObject+PXClass.h"
#import "NSArray+Reverse.h"
#import "NSMutableDictionary+PXObject.h"
#import "NSDictionary+PXCSSEncoding.h"
#import "NSDictionary+PXObject.h"

extern void PXForceLoadNSArrayReverse();
extern void PXForceLoadNSDictionaryPXCSSEncoding();
extern void PXForceLoadNSDictionaryPXObject();
extern void PXForceLoadNSMutableDictionaryPXObject();
extern void PXForceLoadNSObjectPXSubclass();
extern void PXForceLoadNSObjectPXSwizzle();
extern void PXForceLoadUIViewPXStyling();

@implementation PXForceLoadStylingCategories

+(void)forceLoad
{
    PXForceLoadNSArrayReverse();
    PXForceLoadNSDictionaryPXCSSEncoding();
    PXForceLoadNSDictionaryPXObject();
    PXForceLoadNSMutableDictionaryPXObject();
    PXForceLoadNSObjectPXSubclass();
    PXForceLoadNSObjectPXSwizzle();
    PXForceLoadUIViewPXStyling();
}

@end
