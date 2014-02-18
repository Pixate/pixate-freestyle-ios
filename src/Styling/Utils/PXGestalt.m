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
//  PXGestalt.m
//  Pixate
//
//  Created by Giovanni Donelli on 8/23/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXGestalt.h"

#import "DDLog.h"

NSString* _PX_NomalizeStringInput(NSString* stringValue)
{
    NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"\"\' "];
    
    NSString* result = [stringValue stringByTrimmingCharactersInSet:charSet];
    
    return result;
}


#pragma mark - PXVersion

NSInteger _PXVersionValue(int16_t value) 
{
    if (value<0)
        return 0;
    
    return value;
}

PXVersionType PXVersionFromObject(id value)
{
    NSString* stringValue;
    
    if ([value isKindOfClass:[NSString class]]) {
        stringValue = (NSString*)value;
        stringValue = _PX_NomalizeStringInput(stringValue);
    }
    else if ([value isKindOfClass:[NSNumber class]])
        stringValue = [(NSNumber*)value stringValue];
    else
        DDLogError(@"**** %s invalid version value: %@", __FUNCTION__, value );
    
    return PXVersionFromString(stringValue);
}

PXVersionType PXVersionFromString(NSString* vString)
{
    PXVersionType result = { -1, -1, -1 };
 
    if (!vString) {
        DDLogError(@"**** %s invalid input string", __FUNCTION__);
        return result;
    }
    
    NSArray* versionElements = [vString componentsSeparatedByString:@"."];
    NSInteger elementsCount  = versionElements.count;
    
    if ( elementsCount >= 1 ) {
        NSString* nString = versionElements[0];
        result.primary    = [nString integerValue];
    }
    
    if ( elementsCount >= 2 ) {
        NSString* nString = versionElements[1];
        result.secondary  = [nString integerValue];
    }
    
    if ( elementsCount >= 3 ) {
        NSString* nString = versionElements[2];
        result.tertiary   = [nString integerValue];
    }
    
    if ( elementsCount >= 4 ) {
        DDLogError(@"**** %s malformed version string: `%@`", __PRETTY_FUNCTION__, vString);
    }
    
    return result;
}


NSString* NSStringFromPXVersion(PXVersionType v)
{
    NSMutableString* result = [NSMutableString new];
    
    if (v.primary >= 0)
        [result appendFormat:@"%d", v.primary];
    
    if (v.secondary >= 0)
        [result appendFormat:@".%d", v.secondary];
    
    if (v.tertiary >= 0)
        [result appendFormat:@"%d", v.tertiary];
    
    return result;
}


int16_t PXVersionPrimary(PXVersionType v)
{
    return _PXVersionValue(v.primary);
}

int16_t PXVersionSecondary(PXVersionType v)
{
    return _PXVersionValue(v.secondary);
}

int16_t PXVersionTertiary(PXVersionType v)
{
    return _PXVersionValue(v.tertiary);
}


NSInteger _PXVersionCompare(PXVersionType v1, PXVersionType v2)
{
    if (v1.primary < 0 && v2.primary < 0)
        return  0;
    else if (v1.primary < 0)
        return -1;
    else if (v2.primary < 0) 
        return  1;

    NSInteger d1 = _PXVersionValue(v1.primary)  - _PXVersionValue(v2.primary);
    
    if (d1!=0)
        return d1;

    // if a version number is not set, it matches anything
    if ( v1.secondary<0 || v2.secondary<0 )
        return 0;
    
    NSInteger d2 = _PXVersionValue(v1.secondary) - _PXVersionValue(v2.secondary);
    
    if (d2!=0)
        return d2;

    if ( v1.tertiary<0 || v2.tertiary<0 )
        return 0;

    NSInteger d3 = _PXVersionValue(v1.tertiary) - _PXVersionValue(v2.tertiary);
    
    return d3;    
}

NSComparisonResult PXVersionCompare(PXVersionType v1, PXVersionType v2)
{
    NSInteger result = _PXVersionCompare(v1, v2);
    
    if (result<0)
        return NSOrderedAscending;
    
    if (result>0)
        return NSOrderedDescending;
    
    return NSOrderedSame;
}


PXVersionType PXVersionCurrentSystem()
{
    return PXVersionFromString( [[UIDevice currentDevice] systemVersion] );
}

BOOL PXVersionMatch(PXVersionType base, PXVersionType testVersion)
{
    if (base.primary >= 0) {
        if (base.primary != testVersion.primary)
            return NO;
    }
    
    if (base.secondary >= 0) {
        if (base.secondary != testVersion.secondary)
            return NO;
    }
    
    if (base.tertiary >= 0) {
        if (base.tertiary != testVersion.tertiary)
            return NO;
    }
    
    return YES;
}

#pragma mark - PXScreenRatio


PXScreenRatioType PXScreenRatioFromString(NSString* ratioString)
{    
    PXScreenRatioType result = { 0 };
 
    if (![ratioString isKindOfClass:[NSString class]]) {
        DDLogError(@"%s not nil NSString expected, passed %@", __FUNCTION__, ratioString);
        return result;
    }
    
    NSString* nomalizedString = _PX_NomalizeStringInput(ratioString);
    
    NSArray* ratioComponents = [nomalizedString componentsSeparatedByString:@"/"];
    
    if (ratioComponents.count != 2) {
        DDLogError(@"Malformed ratio (cannot find dividend/divisor) string: %@", ratioString);
        return result;
    }
    
    NSString* dendString  = ratioComponents[0];
    NSString* visorString = ratioComponents[1];
    
    NSCharacterSet* charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    dendString  = [dendString  stringByTrimmingCharactersInSet:charSet];
    visorString = [visorString stringByTrimmingCharactersInSet:charSet];
    
    CGFloat dividend = [dendString  integerValue];
    CGFloat divisor  = [visorString integerValue];
    
    if (dividend == 0)
        DDLogError(@"Malformed ratio (dividend is 0) string: %@", ratioString);

    if (divisor == 0)
        DDLogError(@"Malformed ratio (divisor is 0) string: %@", ratioString);

    return (dividend / divisor);
}


PXScreenRatioType PXScreenRatioFromObject(id object)
{
    if ([object isKindOfClass:[NSString class]]) {
        return PXScreenRatioFromString( (NSString*)object );
    }
    else if ([object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber*)object floatValue];
    }
    else
    {
        DDLogError(@"Unknow screen ratio object");
    }
    
    return 0;
}


NSComparisonResult PXScreenRatioCompare(PXScreenRatioType ratio1, PXScreenRatioType ratio2)
{
    CGFloat comparisonValue = ratio1 - ratio2;
    
    // For:
    // https://developer.mozilla.org/en-US/docs/Web/CSS/ratio
    // ( 185/100 == 91/50 ): movie format
    
    if ( fabs(comparisonValue) < 0.04 )
        return NSOrderedSame;
    else if (comparisonValue < 0)
        return NSOrderedAscending;
    else
        return NSOrderedDescending;
}


PXScreenRatioType PXScreenRatioFromCGSize(CGSize size)
{
    PXScreenRatioType result =  0;
    
    if (size.width > 0 && size.height > 0)
    {
        return size.width / size.height;
    }
    else
    {
        DDLogError(@"Invalid CGSize components");
    }
    
    return result;
}


PXScreenRatioType PXScreenRatioCurrentSystem()
{
    UIScreen* mainScreen     = [UIScreen mainScreen];
    CGRect mainScreenBounds  = [mainScreen bounds];

    return PXScreenRatioFromCGSize(mainScreenBounds.size);
}


