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
//  PXTransformTokenType.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXTransformTokenType.h"

@implementation PXTransformTokenType

+ (NSString *)typeNameForInt:(PXTransformTokens)type
{
    switch (type)
    {
        case PXTransformToken_ERROR:        return @"ERROR";
        case PXTransformToken_EOF:          return @"EOF";

        case PXTransformToken_WHITESPACE:   return @"WHITESPACE";

        case PXTransformToken_EMS:          return @"EMS";
        case PXTransformToken_EXS:          return @"EXS";
        case PXTransformToken_LENGTH:       return @"LENGTH";
        case PXTransformToken_ANGLE:        return @"ANGLE";
        case PXTransformToken_TIME:         return @"TIME";
        case PXTransformToken_FREQUENCY:    return @"FREQUENCY";
        case PXTransformToken_PERCENTAGE:   return @"PERCENTAGE";
        case PXTransformToken_DIMENSION:    return @"DIMENSION";
        case PXTransformToken_NUMBER:       return @"NUMBER";

        case PXTransformToken_LPAREN:       return @"LPAREN";
        case PXTransformToken_RPAREN:       return @"RPAREN";
        case PXTransformToken_COMMA:        return @"COMMA";

        case PXTransformToken_TRANSLATE:    return @"TRANSLATE";
        case PXTransformToken_TRANSLATEX:   return @"TRANSLATEX";
        case PXTransformToken_TRANSLATEY:   return @"TRANSLATEY";
        case PXTransformToken_SCALE:        return @"SCALE";
        case PXTransformToken_SCALEX:       return @"SCALEX";
        case PXTransformToken_SCALEY:       return @"SCALEY";
        case PXTransformToken_SKEW:         return @"SKEW";
        case PXTransformToken_SKEWX:        return @"SKEWX";
        case PXTransformToken_SKEWY:        return @"SKEWY";
        case PXTransformToken_ROTATE:       return @"ROTATE";
        case PXTransformToken_MATRIX:       return @"MATRIX";

        default:                        return @"<unknown>";
    }
}

@end
