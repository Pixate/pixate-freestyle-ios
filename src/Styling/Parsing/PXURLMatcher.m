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
//  PXURLMatcher.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/19/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXURLMatcher.h"

@implementation PXURLMatcher

- (id)initWithType:(int)type
{
    if (self = [super initWithType:type withPatternString:@"^url\\(\\s*(?:\"([^\"\\r\\n]*)\"|(data:[^,\\r\\n\\)]+,[a-zA-Z0-9+/ \\t\\r\\n]+\\={0,2})|([!#$%&*-~]*))\\s*\\)"])
    {
        // do any needed local init here
    }

    return self;
}

- (PXStylesheetLexeme *)createLexemeWithString:(NSString *)aString withRange:(NSRange)aRange
{
    PXStylesheetLexeme *result = nil;
    NSTextCheckingResult *match = [self->pattern firstMatchInString:aString options:0 range:aRange];

    if (match)
    {
        for (NSUInteger i = 1; i < match.numberOfRanges; i++)
        {
            NSRange stringRange = [match rangeAtIndex:i];

            if (stringRange.location != NSNotFound)
            {
                result = [PXStylesheetLexeme lexemeWithType:self.type withRange:match.range withValue:[aString substringWithRange:stringRange]];
                break;
            }
        }
    }

    return result;
}

@end
