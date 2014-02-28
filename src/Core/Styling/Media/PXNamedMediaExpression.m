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
//  PXNamedMediaExpression.m
//  Pixate
//
//  Created by Kevin Lindsey on 1/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXNamedMediaExpression.h"

#import "PXDimension.h"
#import "PXGestalt.h"
#import <sys/utsname.h>
#import <sys/sysctl.h>


@implementation PXNamedMediaExpression
{
    NSNumber* _matches;
}

#pragma mark - Static Methods

+ (NSDictionary *)nameHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
            @"orientation" : ^BOOL(PXNamedMediaExpression *expression) {
                UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

                switch (orientation) {
                    case UIInterfaceOrientationLandscapeLeft:
                    case UIInterfaceOrientationLandscapeRight:
                        return [expression.value isEqualToString:@"landscape"];

                    case UIInterfaceOrientationPortrait:
                    case UIDeviceOrientationPortraitUpsideDown:
                        return [expression.value isEqualToString:@"portrait"];

                    default:
                        return NO;
                }
            },

            @"device" : ^BOOL(PXNamedMediaExpression *expression) {
                
                static NSString *platform;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    struct utsname u;
                    uname(&u);
                    platform = [[NSString stringWithUTF8String:u.machine] lowercaseString];
                });

                NSString *userValue = expression.value;
                
                // First check if we're in simulater
                if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
                {
                    NSString *simDevice = [[UIDevice currentDevice].model lowercaseString];
                    
                    if([userValue isEqualToString:@"iphone"] || [userValue isEqualToString:@"ipod"])
                    {
                        return [simDevice hasPrefix:@"iphone"];
                    }
                    else if([userValue isEqualToString:@"ipad"] || [userValue isEqualToString:@"ipad-mini"])
                    {
                        return [simDevice hasPrefix:@"ipad"];
                    }
                }
                else // Actual hardware device
                {
                    if([userValue isEqualToString:@"iphone"] || [userValue isEqualToString:@"ipod"])
                    {
                        return [platform hasPrefix:@"iphone"] ||
                               [platform hasPrefix:@"ipod"];
                    }
                    else if([userValue isEqualToString:@"ipad"])
                    {
                        return [platform hasPrefix:@"ipad"];
                    }
                    else if([userValue isEqualToString:@"ipad-mini"])
                    {
                        return ([platform hasPrefix:@"ipad"] &&
                                ([platform hasSuffix:@"2,5"] || // mini wifi
                                 [platform hasSuffix:@"2,6"] || // mini Cellular ATT
                                 [platform hasSuffix:@"2,7"]    // mini Cellular Verizon
                                ));
                    }
                    else if([userValue isEqualToString:@"appletv"])
                    {
                        return [platform hasPrefix:@"appletv"];
                    }
                }

                return NO;
            },

            @"device-width" : ^BOOL(PXNamedMediaExpression *expression) {
                return [[UIScreen mainScreen] bounds].size.width == expression.floatValue;
            },
            @"min-device-width" : ^BOOL(PXNamedMediaExpression *expression) {
                return [[UIScreen mainScreen] bounds].size.width >= expression.floatValue;
            },
            @"max-device-width" : ^BOOL(PXNamedMediaExpression *expression) {
                return [[UIScreen mainScreen] bounds].size.width <= expression.floatValue;
            },
            @"device-height" : ^BOOL(PXNamedMediaExpression *expression) {
                return [[UIScreen mainScreen] bounds].size.height == expression.floatValue;
            },
            @"min-device-height" : ^BOOL(PXNamedMediaExpression *expression) {
                return [[UIScreen mainScreen] bounds].size.height >= expression.floatValue;
            },
            @"max-device-height" : ^BOOL(PXNamedMediaExpression *expression) {
                return [[UIScreen mainScreen] bounds].size.height <= expression.floatValue;
            },
            @"scale" : ^BOOL(PXNamedMediaExpression *expression) {
                return [[UIScreen mainScreen] scale] == expression.floatValue;
            },
            @"min-scale" : ^BOOL(PXNamedMediaExpression *expression) {
                return [[UIScreen mainScreen] scale] >= expression.floatValue;
            },
            @"max-scale" : ^BOOL(PXNamedMediaExpression *expression) {
                return [[UIScreen mainScreen] scale] <= expression.floatValue;
            },
            
            @"device-os-version" : ^BOOL(PXNamedMediaExpression *expression) {
                PXVersionType sysVersion  = PXVersionCurrentSystem();
                PXVersionType userVersion = PXVersionFromObject(expression.value);
                
                return PXVersionMatch(userVersion, sysVersion);
            },
            @"min-device-os-version" : ^BOOL(PXNamedMediaExpression *expression) {
                PXVersionType sysVersion = PXVersionCurrentSystem();
                PXVersionType minVersion = PXVersionFromObject(expression.value);
                
                return ( PXVersionCompare(sysVersion, minVersion) >= NSOrderedSame );
            },
            @"max-device-os-version" : ^BOOL(PXNamedMediaExpression *expression) {
                PXVersionType sysVersion = PXVersionCurrentSystem();
                PXVersionType maxVersion = PXVersionFromObject(expression.value);

                return ( PXVersionCompare(sysVersion, maxVersion) <= NSOrderedSame );
            },
            
            @"device-aspect-ratio" : ^BOOL(PXNamedMediaExpression *expression) {
                PXScreenRatioType sysRatio  = PXScreenRatioCurrentSystem();
                PXScreenRatioType userRatio = PXScreenRatioFromObject(expression.value);
                
                return (PXScreenRatioCompare(sysRatio, userRatio) == NSOrderedSame);
            },
            @"min-device-aspect-ratio" : ^BOOL(PXNamedMediaExpression *expression) {
                PXScreenRatioType sysRatio  = PXScreenRatioCurrentSystem();
                PXScreenRatioType userRatio = PXScreenRatioFromObject(expression.value);
                // 4/3 (sys) > 1/1 (usr)
                return (PXScreenRatioCompare(sysRatio, userRatio) >= NSOrderedSame);
            },
            @"max-device-aspect-ratio" : ^BOOL(PXNamedMediaExpression *expression) {
                PXScreenRatioType sysRatio  = PXScreenRatioCurrentSystem();
                PXScreenRatioType userRatio = PXScreenRatioFromObject(expression.value);
                
                return (PXScreenRatioCompare(sysRatio, userRatio ) <= NSOrderedSame);
            },

        };
    });

    return handlers;
}

#pragma mark - Initializers

- (id)initWithName:(NSString *)name value:(id)value
{
    if (self = [super init])
    {
        _name = name;
        _value = value;        
    }

    return self;
}

#pragma mark - Methods

- (void)clearCache
{
    _matches = nil;
}

- (BOOL)matches
{
    if (!_matches) {
        // NOTE: the parser guarantees that _name is lower case
        NSDictionary *handlers = [PXNamedMediaExpression nameHandlers];
        PXNamedMediaExpressionHandler handler = [handlers objectForKey:_name];
        _matches = [NSNumber numberWithBool:(handler) ? handler(self) : NO];
    }
    return _matches.boolValue;
}

- (CGFloat)floatValue
{
    if ([_value isKindOfClass:[NSNumber class]])
    {
        return [(NSNumber *)_value floatValue];
    }
    else if ([_value isKindOfClass:[NSString class]])
    {
        return [(NSString *)_value floatValue];
    }
    else if ([_value isKindOfClass:[PXDimension class]])
    {
        PXDimension *dimension = _value;

        if (dimension.isLength)
        {
            return dimension.points.number;
        }
        else
        {
            return 0.0f;
        }
    }
    else
    {
        return 0.0f;
    }
}

#pragma mark - Overrides

- (NSString *)description
{
    if (_value)
    {
        return [NSString stringWithFormat:@"(%@:%@)", _name, _value];
    }
    else
    {
        return [NSString stringWithFormat:@"(%@)", _name];
    }
}

@end
