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
//  PXSSTokenType.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A list of iCSS token types
 */
typedef enum _PXStylesheetTokens : NSInteger
{
    PXSS_ERROR = -1,
    PXSS_EOF,

    PXSS_WHITESPACE,

    PXSS_NUMBER,
    PXSS_CLASS,
    PXSS_ID,
    PXSS_IDENTIFIER,

    PXSS_LCURLY,
    PXSS_RCURLY,
    PXSS_LPAREN,
    PXSS_RPAREN,
    PXSS_LBRACKET,
    PXSS_RBRACKET,

    PXSS_SEMICOLON,
    PXSS_GREATER_THAN,
    PXSS_PLUS,
    PXSS_TILDE,
    PXSS_STAR,
    PXSS_EQUAL,
    PXSS_COLON,
    PXSS_COMMA,
    PXSS_PIPE,
    PXSS_SLASH,

    PXSS_DOUBLE_COLON,
    PXSS_STARTS_WITH,
    PXSS_ENDS_WITH,
    PXSS_CONTAINS,
    PXSS_LIST_CONTAINS,
    PXSS_EQUALS_WITH_HYPHEN,

    PXSS_STRING,
    PXSS_LINEAR_GRADIENT,
    PXSS_RADIAL_GRADIENT,
    PXSS_HSL,
    PXSS_HSLA,
    PXSS_HSB,
    PXSS_HSBA,
    PXSS_RGB,
    PXSS_RGBA,
    PXSS_HEX_COLOR,
    PXSS_URL,
    PXSS_NAMESPACE,

    PXSS_NOT_PSEUDO_CLASS,
    PXSS_LINK_PSEUDO_CLASS,
    PXSS_VISITED_PSEUDO_CLASS,
    PXSS_HOVER_PSEUDO_CLASS,
    PXSS_ACTIVE_PSEUDO_CLASS,
    PXSS_FOCUS_PSEUDO_CLASS,
    PXSS_TARGET_PSEUDO_CLASS,
    PXSS_LANG_PSEUDO_CLASS,
    PXSS_ENABLED_PSEUDO_CLASS,
    PXSS_CHECKED_PSEUDO_CLASS,
    PXSS_INDETERMINATE_PSEUDO_CLASS,
    PXSS_ROOT_PSEUDO_CLASS,
    PXSS_NTH_CHILD_PSEUDO_CLASS,
    PXSS_NTH_LAST_CHILD_PSEUDO_CLASS,
    PXSS_NTH_OF_TYPE_PSEUDO_CLASS,
    PXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS,
    PXSS_FIRST_CHILD_PSEUDO_CLASS,
    PXSS_LAST_CHILD_PSEUDO_CLASS,
    PXSS_FIRST_OF_TYPE_PSEUDO_CLASS,
    PXSS_LAST_OF_TYPE_PSEUDO_CLASS,
    PXSS_ONLY_CHILD_PSEUDO_CLASS,
    PXSS_ONLY_OF_TYPE_PSEUDO_CLASS,
    PXSS_EMPTY_PSEUDO_CLASS,
    PXSS_NTH,

    PXSS_FIRST_LINE_PSEUDO_ELEMENT,
    PXSS_FIRST_LETTER_PSEUDO_ELEMENT,
    PXSS_BEFORE_PSEUDO_ELEMENT,
    PXSS_AFTER_PSEUDO_ELEMENT,

    PXSS_KEYFRAMES,
    PXSS_IMPORTANT,
    PXSS_IMPORT,
    PXSS_MEDIA,
    PXSS_FONT_FACE,
    PXSS_AND,

    PXSS_EMS,
    PXSS_EXS,
    PXSS_LENGTH,
    PXSS_ANGLE,
    PXSS_TIME,
    PXSS_FREQUENCY,
    PXSS_DIMENSION,
    PXSS_PERCENTAGE

} PXStylesheetTokens;

/**
 *  A singleton used to indicate the type of a given lexeme
 */
@interface PXStylesheetTokenType : NSObject

/**
 *  Return a display name for the specified token type. This is used for debugging and error reporting.
 *
 *  @param type The value of the enumeration to convert to a string
 */
+ (NSString *)typeNameForInt:(PXStylesheetTokens)type;

@end
