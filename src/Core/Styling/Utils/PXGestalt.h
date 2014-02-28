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
//  PXGestalt.h
//  Pixate
//
//  Created by Giovanni Donelli on 8/23/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// ---
// Version

typedef struct {
    int16_t primary;
    int16_t secondary;
    int16_t tertiary;
}
PXVersionType;

PXVersionType PXVersionFromObject(id value);
PXVersionType PXVersionFromString(NSString* vString);
NSString* NSStringFromPXVersion(PXVersionType v);

int16_t PXVersionPrimary(PXVersionType v);
int16_t PXVersionSecondary(PXVersionType v);
int16_t PXVersionTertiary(PXVersionType v);

// v1 >  v2 : return > 0
// v1 <  v2 : return < 0
// v1 == v2 : return 0

NSComparisonResult PXVersionCompare(PXVersionType v1, PXVersionType v2);

// if base is:
//
//    1. 4 (base) means matches all 4 (testVersion)
//    1. 4.1 (base) means matches 4.1 and any 4.1.x but no other 4.x (testVersion)

BOOL PXVersionMatch(PXVersionType base, PXVersionType testVersion);

PXVersionType PXVersionCurrentSystem();

// ---
// Aspect ratio: (dividend / divisor) = quotient

typedef CGFloat PXScreenRatioType;

PXScreenRatioType PXScreenRatioFromString(NSString* ratioString);
PXScreenRatioType PXScreenRatioFromObject(id object);
NSComparisonResult PXScreenRatioCompare(PXScreenRatioType ratio1, PXScreenRatioType ratio2);

PXScreenRatioType PXScreenRatioCurrentSystem();
