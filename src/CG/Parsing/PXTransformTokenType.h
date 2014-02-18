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
//  PXTransformTokenType.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  An enumeration of the PXTransform token types
 */
typedef enum
{
    PXTransformToken_ERROR = -1,
    PXTransformToken_EOF,

    PXTransformToken_WHITESPACE,

    PXTransformToken_EMS,
    PXTransformToken_EXS,
    PXTransformToken_LENGTH,
    PXTransformToken_ANGLE,
    PXTransformToken_TIME,
    PXTransformToken_FREQUENCY,
    PXTransformToken_PERCENTAGE,
    PXTransformToken_DIMENSION,
    PXTransformToken_NUMBER,

    PXTransformToken_LPAREN,
    PXTransformToken_RPAREN,
    PXTransformToken_COMMA,

    PXTransformToken_TRANSLATE,
    PXTransformToken_TRANSLATEX,
    PXTransformToken_TRANSLATEY,
    PXTransformToken_SCALE,
    PXTransformToken_SCALEX,
    PXTransformToken_SCALEY,
    PXTransformToken_SKEW,
    PXTransformToken_SKEWX,
    PXTransformToken_SKEWY,
    PXTransformToken_ROTATE,
    PXTransformToken_MATRIX
} PXTransformTokens;

/**
 *  A singleton class used to represent a PXTransform token type
 */
@interface PXTransformTokenType : NSObject

/**
 *  Convert the specified token type to a string suitable for testing, debugging, and error messages
 *
 *  @param type The value of the enumeration to convert to a string
 */
+ (NSString *)typeNameForInt:(PXTransformTokens)type;

@end
