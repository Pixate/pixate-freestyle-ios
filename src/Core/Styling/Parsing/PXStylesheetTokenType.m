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
//  PXSSTokenType.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/26/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStylesheetTokenType.h"

@implementation PXStylesheetTokenType

+ (NSString *)typeNameForInt:(PXStylesheetTokens)type
{
    switch (type)
    {
        case PXSS_ERROR:                            return @"ERROR";
        case PXSS_EOF:                              return @"EOF";

        case PXSS_WHITESPACE:                       return @"WHITESPACE";

        case PXSS_NUMBER:                           return @"NUMBER";
        case PXSS_CLASS:                            return @"CLASS";
        case PXSS_ID:                               return @"ID";
        case PXSS_IDENTIFIER:                       return @"IDENTIFIER";

        case PXSS_LCURLY:                           return @"LCURLY";
        case PXSS_RCURLY:                           return @"RCURLY";
        case PXSS_LPAREN:                           return @"LPAREN";
        case PXSS_RPAREN:                           return @"RPAREN";
        case PXSS_LBRACKET:                         return @"LBRACKET";
        case PXSS_RBRACKET:                         return @"RBRACKET";

        case PXSS_SEMICOLON:                        return @"SEMICOLON";
        case PXSS_GREATER_THAN:                     return @"GREATER_THAN";
        case PXSS_PLUS:                             return @"PLUS";
        case PXSS_TILDE:                            return @"TILDE";
        case PXSS_STAR:                             return @"STAR";
        case PXSS_EQUAL:                            return @"EQUAL";
        case PXSS_COLON:                            return @"COLON";
        case PXSS_COMMA:                            return @"COMMA";
        case PXSS_PIPE:                             return @"PIPE";
        case PXSS_SLASH:                            return @"SLASH";

        case PXSS_DOUBLE_COLON:                     return @"DOUBLE_COLON";
        case PXSS_STARTS_WITH:                      return @"STARTS_WITH";
        case PXSS_ENDS_WITH:                        return @"ENDS_WITH";
        case PXSS_CONTAINS:                         return @"CONTAINS";
        case PXSS_LIST_CONTAINS:                    return @"LIST_CONTAINS";
        case PXSS_EQUALS_WITH_HYPHEN:               return @"HYPHEN_LIST_CONTAINS";

        case PXSS_STRING:                           return @"STRING";
        case PXSS_LINEAR_GRADIENT:                  return @"LINEAR_GRADIENT";
        case PXSS_RADIAL_GRADIENT:                  return @"RADIAL_GRADIENT";
        case PXSS_HSL:                              return @"HSL";
        case PXSS_HSLA:                             return @"HSLA";
        case PXSS_HSB:                              return @"HSB";
        case PXSS_HSBA:                             return @"HSBA";
        case PXSS_RGB:                              return @"RGB";
        case PXSS_RGBA:                             return @"RGBA";
        case PXSS_HEX_COLOR:                        return @"HEX_COLOR";
        case PXSS_URL:                              return @"URL";
        case PXSS_NAMESPACE:                        return @"NAMESPACE";

        case PXSS_NOT_PSEUDO_CLASS:                 return @"NOT";
        case PXSS_LINK_PSEUDO_CLASS:                return @"PXSS_LINK_PSEUDO_CLASS";
        case PXSS_VISITED_PSEUDO_CLASS:             return @"PXSS_VISITED_PSEUDO_CLASS";
        case PXSS_HOVER_PSEUDO_CLASS:               return @"PXSS_HOVER_PSEUDO_CLASS";
        case PXSS_ACTIVE_PSEUDO_CLASS:              return @"PXSS_ACTIVE_PSEUDO_CLASS";
        case PXSS_FOCUS_PSEUDO_CLASS:               return @"PXSS_FOCUS_PSEUDO_CLASS";
        case PXSS_TARGET_PSEUDO_CLASS:              return @"PXSS_TARGET_PSEUDO_CLASS";
        case PXSS_LANG_PSEUDO_CLASS:                return @"PXSS_LANG_PSEUDO_CLASS";
        case PXSS_ENABLED_PSEUDO_CLASS:             return @"PXSS_ENABLED_PSEUDO_CLASS";
        case PXSS_CHECKED_PSEUDO_CLASS:             return @"PXSS_CHECKED_PSEUDO_CLASS";
        case PXSS_INDETERMINATE_PSEUDO_CLASS:       return @"PXSS_INDETERMINATE_PSEUDO_CLASS";
        case PXSS_ROOT_PSEUDO_CLASS:                return @"PXSS_ROOT_PSEUDO_CLASS";
        case PXSS_NTH_CHILD_PSEUDO_CLASS:           return @"PXSS_NTH_CHILD_PSEUDO_CLASS";
        case PXSS_NTH_LAST_CHILD_PSEUDO_CLASS:      return @"PXSS_NTH_LAST_CHILD_PSEUDO_CLASS";
        case PXSS_NTH_OF_TYPE_PSEUDO_CLASS:         return @"PXSS_NTH_OF_TYPE_PSEUDO_CLASS";
        case PXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS:    return @"PXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS";
        case PXSS_FIRST_CHILD_PSEUDO_CLASS:         return @"PXSS_FIRST_CHILD_PSEUDO_CLASS";
        case PXSS_LAST_CHILD_PSEUDO_CLASS:          return @"PXSS_LAST_CHILD_PSEUDO_CLASS";
        case PXSS_FIRST_OF_TYPE_PSEUDO_CLASS:       return @"PXSS_FIRST_OF_TYPE_PSEUDO_CLASS";
        case PXSS_LAST_OF_TYPE_PSEUDO_CLASS:        return @"PXSS_LAST_OF_TYPE_PSEUDO_CLASS";
        case PXSS_ONLY_CHILD_PSEUDO_CLASS:          return @"PXSS_ONLY_CHILD_PSEUDO_CLASS";
        case PXSS_ONLY_OF_TYPE_PSEUDO_CLASS:        return @"PXSS_ONLY_OF_TYPE_PSEUDO_CLASS";
        case PXSS_EMPTY_PSEUDO_CLASS:               return @"PXSS_EMPTY_PSEUDO_CLASS";
        case PXSS_NTH:                              return @"PXSS_NTH";

        case PXSS_FIRST_LINE_PSEUDO_ELEMENT:        return @"PXSS_FIRST_LINE_PSEUDO_ELEMENT";
        case PXSS_FIRST_LETTER_PSEUDO_ELEMENT:      return @"PXSS_FIRST_LETTER_PSEUDO_ELEMENT";
        case PXSS_BEFORE_PSEUDO_ELEMENT:            return @"PXSS_BEFORE_PSEUDO_ELEMENT";
        case PXSS_AFTER_PSEUDO_ELEMENT:             return @"PXSS_AFTER_PSEUDO_ELEMENT";

        case PXSS_KEYFRAMES:                        return @"KEYFRAMES";
        case PXSS_IMPORTANT:                        return @"IMPORTANT";
        case PXSS_IMPORT:                           return @"IMPORT";
        case PXSS_MEDIA:                            return @"MEDIA";
        case PXSS_FONT_FACE:                        return @"FONT_FACE";
        case PXSS_AND:                              return @"AND";

        case PXSS_EMS:                              return @"EMS";
        case PXSS_EXS:                              return @"EXS";
        case PXSS_LENGTH:                           return @"LENGTH";
        case PXSS_ANGLE:                            return @"ANGLE";
        case PXSS_TIME:                             return @"TIME";
        case PXSS_FREQUENCY:                        return @"FREQUENCY";
        case PXSS_DIMENSION:                        return @"DIMENSION";
        case PXSS_PERCENTAGE:                       return @"PERCENTAGE";

        default:                        return @"<unknown>";
    }
}

@end
