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
//  PXSSLexer.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStylesheetLexer.h"
#import "PXStylesheetTokenType.h"
#import "PXPatternMatcher.h"
#import "PXCharacterMatcher.h"
#import "PXNumberMatcher.h"
#import "PXWordMatcher.h"
#import "NSMutableArray+StackAdditions.h"
#import "PXURLMatcher.h"

@interface LexerState : NSObject
@property (nonatomic, strong, readonly) NSString *source;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) NSUInteger blockDepth;
@property (nonatomic, strong, readonly) NSMutableArray *lexemeStack;
@end

@implementation LexerState
- (id)initWithSource:(NSString *)source offset:(NSUInteger)offset blockDepth:(NSUInteger)blockDepth lexemeStack:(NSMutableArray *)lexemeStack
{
    if (self = [super init])
    {
        _source = source;
        _offset = offset;
        _blockDepth = blockDepth;
        _lexemeStack = lexemeStack;
    }

    return self;
}

-(void)dealloc
{
    _source = nil;
    _lexemeStack = nil;
}
@end

@implementation PXStylesheetLexer
{
    NSArray *tokens_;
    NSUInteger offset_;
    NSUInteger blockDepth_;
    NSMutableArray *lexemeStack_;
    NSMutableArray *stateStack_;
}

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        // create tokens
        NSMutableArray *tokenList = [NSMutableArray array];

        // whitespace
        [tokenList addObject: [[PXPatternMatcher alloc] initWithType:PXSS_WHITESPACE
                                                     withPatternString:@"^[ \\t\\r\\n]+"]];
        [tokenList addObject: [[PXPatternMatcher alloc] initWithType:PXSS_WHITESPACE
                                                    withPatternString:@"^/\\*(?:.|[\n\r])*?\\*/"]];

        // pseudo-classes
        NSDictionary *pseudoClassMap = @{
            @":not(": @(PXSS_NOT_PSEUDO_CLASS),
            @":link": @(PXSS_LINK_PSEUDO_CLASS),
            @":visited": @(PXSS_VISITED_PSEUDO_CLASS),
            @":hover": @(PXSS_HOVER_PSEUDO_CLASS),
            @":active": @(PXSS_ACTIVE_PSEUDO_CLASS),
            @":focus": @(PXSS_FOCUS_PSEUDO_CLASS),
            @":target": @(PXSS_TARGET_PSEUDO_CLASS),
            @":lang(": @(PXSS_LANG_PSEUDO_CLASS),
            @":enabled": @(PXSS_ENABLED_PSEUDO_CLASS),
            @":checked": @(PXSS_CHECKED_PSEUDO_CLASS),
            @":indeterminate": @(PXSS_INDETERMINATE_PSEUDO_CLASS),
            @":root": @(PXSS_ROOT_PSEUDO_CLASS),
            @":nth-child(": @(PXSS_NTH_CHILD_PSEUDO_CLASS),
            @":nth-last-child(": @(PXSS_NTH_LAST_CHILD_PSEUDO_CLASS),
            @":nth-of-type(": @(PXSS_NTH_OF_TYPE_PSEUDO_CLASS),
            @":nth-last-of-type(": @(PXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS),
            @":first-child": @(PXSS_FIRST_CHILD_PSEUDO_CLASS),
            @":last-child": @(PXSS_LAST_CHILD_PSEUDO_CLASS),
            @":first-of-type": @(PXSS_FIRST_OF_TYPE_PSEUDO_CLASS),
            @":last-of-type": @(PXSS_LAST_OF_TYPE_PSEUDO_CLASS),
            @":only-child": @(PXSS_ONLY_CHILD_PSEUDO_CLASS),
            @":only-of-type": @(PXSS_ONLY_OF_TYPE_PSEUDO_CLASS),
            @":empty": @(PXSS_EMPTY_PSEUDO_CLASS),
            @":first-line": @(PXSS_FIRST_LINE_PSEUDO_ELEMENT),
            @":first-letter": @(PXSS_FIRST_LETTER_PSEUDO_ELEMENT),
            @":before": @(PXSS_BEFORE_PSEUDO_ELEMENT),
            @":after": @(PXSS_AFTER_PSEUDO_ELEMENT),
        };
        [tokenList addObject:[[PXWordMatcher alloc] initWithDictionary:pseudoClassMap usingSymbols:YES]];

        // functions
        NSDictionary *functionMap = @{
            @"linear-gradient(": @(PXSS_LINEAR_GRADIENT),
            @"radial-gradient(": @(PXSS_RADIAL_GRADIENT),
            @"hsb(": @(PXSS_HSB),
            @"hsba(": @(PXSS_HSBA),
            @"hsl(": @(PXSS_HSL),
            @"hsla(": @(PXSS_HSLA),
            @"rgb(": @(PXSS_RGB),
            @"rgba(": @(PXSS_RGBA)
        };
        [tokenList addObject:[[PXWordMatcher alloc] initWithDictionary:functionMap usingSymbols:YES]];

        // urls
        [tokenList addObject:[[PXURLMatcher alloc] initWithType:PXSS_URL]];

        // nth
        [tokenList addObject:[[PXPatternMatcher alloc] initWithType:PXSS_NTH withPatternString:@"^[-+]?\\d*[nN]\\b"]];

        // dimensions
        NSDictionary *unitMap = @{
            @"em": @(PXSS_EMS),
            @"ex": @(PXSS_EXS),
            @"px": @(PXSS_LENGTH),
            @"dpx": @(PXSS_LENGTH),
            @"cm": @(PXSS_LENGTH),
            @"mm": @(PXSS_LENGTH),
            @"in": @(PXSS_LENGTH),
            @"pt": @(PXSS_LENGTH),
            @"pc": @(PXSS_LENGTH),
            @"deg": @(PXSS_ANGLE),
            @"rad": @(PXSS_ANGLE),
            @"grad": @(PXSS_ANGLE),
            @"ms": @(PXSS_TIME),
            @"s": @(PXSS_TIME),
            @"Hz": @(PXSS_FREQUENCY),
            @"kHz": @(PXSS_FREQUENCY),
            @"%": @(PXSS_PERCENTAGE),
            @"[-a-zA-Z_][-a-zA-Z0-9_]*": @(PXSS_DIMENSION)
        };
        [tokenList addObject:[[PXNumberMatcher alloc] initWithType:PXSS_NUMBER withDictionary:unitMap withUnknownType:PXSS_DIMENSION]];

        // hex colors
        [tokenList addObject:[[PXPatternMatcher alloc] initWithType:PXSS_HEX_COLOR withPatternString:@"^#(?:[a-fA-F0-9]{8}|[a-fA-F0-9]{6}|[a-fA-F0-9]{4}|[a-fA-F0-9]{3})\\b"]];

        // various identifiers
        NSDictionary *keywordMap = @{
            @"@keyframes" : @(PXSS_KEYFRAMES),
            @"@namespace" : @(PXSS_NAMESPACE),
            @"@import" : @(PXSS_IMPORT),
            @"@media" : @(PXSS_MEDIA),
            @"@font-face": @(PXSS_FONT_FACE),
            @"and" : @(PXSS_AND),
        };
        [tokenList addObject:[[PXWordMatcher alloc] initWithDictionary:keywordMap]];
        [tokenList addObject:[[PXPatternMatcher alloc] initWithType:PXSS_CLASS withPatternString:@"^\\.(?:[-a-zA-Z_]|\\\\[^\\r\\n\\f0-9a-f])(?:[-a-zA-Z0-9_]|\\\\[^\\r\\n\\f0-9a-f])*"]];
        [tokenList addObject:[[PXPatternMatcher alloc] initWithType:PXSS_ID withPatternString:@"^#(?:[-a-zA-Z_]|\\\\[^\\r\\n\\f0-9a-f])(?:[-a-zA-Z0-9_]|\\\\[^\\r\\n\\f0-9a-f])*"]];
        [tokenList addObject:[[PXPatternMatcher alloc] initWithType:PXSS_IDENTIFIER withPatternString:@"^(?:[-a-zA-Z_]|\\\\[^\\r\\n\\f0-9a-f])(?:[-a-zA-Z0-9_]|\\\\[^\\r\\n\\f0-9a-f])*"]];
        [tokenList addObject:[[PXPatternMatcher alloc] initWithType:PXSS_IMPORTANT withPatternString:@"^!\\s*important\\b"]];

        // strings
        [tokenList addObject:[[PXPatternMatcher alloc] initWithType:PXSS_STRING withPatternString:@"^\"(?:[^\"\\\\\\r\\n\\f]|\\\\[^\\r\\n\\f])*\""]];
        [tokenList addObject:[[PXPatternMatcher alloc] initWithType:PXSS_STRING withPatternString:@"^'(?:[^'\\\\\\r\\n\\f]|\\\\[^\\r\\n\\f])*'"]];

        // multi-character operators
        NSDictionary *operatorMap = @{
            @"::": @(PXSS_DOUBLE_COLON),
            @"^=": @(PXSS_STARTS_WITH),
            @"$=": @(PXSS_ENDS_WITH),
            @"*=": @(PXSS_CONTAINS),
            @"~=": @(PXSS_LIST_CONTAINS),
            @"|=": @(PXSS_EQUALS_WITH_HYPHEN),
        };
        [tokenList addObject:[[PXWordMatcher alloc] initWithDictionary:operatorMap usingSymbols:YES]];

        // single-character operators
        NSString *operators = @"{}()[];>+~*=:,|/";
        NSArray *operatorTypes = @[
            @(PXSS_LCURLY),
            @(PXSS_RCURLY),
            @(PXSS_LPAREN),
            @(PXSS_RPAREN),
            @(PXSS_LBRACKET),
            @(PXSS_RBRACKET),
            @(PXSS_SEMICOLON),
            @(PXSS_GREATER_THAN),
            @(PXSS_PLUS),
            @(PXSS_TILDE),
            @(PXSS_STAR),
            @(PXSS_EQUAL),
            @(PXSS_COLON),
            @(PXSS_COMMA),
            @(PXSS_PIPE),
            @(PXSS_SLASH)
        ];
        [tokenList addObject:[[PXCharacterMatcher alloc] initWithCharactersInString:operators withTypes:operatorTypes]];

        tokens_ = [NSArray arrayWithArray:tokenList];
    }

    return self;
}

- (id)initWithString:(NSString *)text
{
    if (self = [self init])
    {
        self.source = text;
    }

    return self;
}

#pragma mark - Setter

- (void)setSource:(NSString *)aSource
{
    _source = aSource;
    offset_ = 0;
    blockDepth_ = 0;
    lexemeStack_ = nil;
}

#pragma mark - Methods

- (void)pushLexeme:(PXLexeme *)lexeme
{
    if (lexeme)
    {
        if (lexemeStack_ == nil)
        {
            lexemeStack_ = [[NSMutableArray alloc] init];
        }

        [lexemeStack_ push:lexeme];

        // reverse block depth settings
        if (lexeme.type == PXSS_LCURLY)
        {
            [self decreaseNesting];
        }
        else if (lexeme.type == PXSS_RCURLY)
        {
            [self increaseNesting];
        }
    }
}

- (void)pushSource:(NSString *)source
{
    if (stateStack_ == nil)
    {
        stateStack_ = [[NSMutableArray alloc] init];
    }

    LexerState *state = [[LexerState alloc] initWithSource:_source offset:offset_ blockDepth:blockDepth_ lexemeStack:lexemeStack_];

    [stateStack_ push:state];

    self.source = source;
}

- (void)popSource
{
    if (stateStack_.count > 0)
    {
        LexerState *state = [stateStack_ pop];

        _source = state.source;
        offset_ = state.offset;
        blockDepth_ = state.blockDepth;
        lexemeStack_ = state.lexemeStack;

        // fire delegate
        if (_delegate)
        {
            if ([_delegate respondsToSelector:@selector(lexerDidPopSource)])
            {
                [_delegate lexerDidPopSource];
            }
        }
    }
}

- (void)increaseNesting
{
    blockDepth_++;
}

- (void)decreaseNesting
{
    blockDepth_--;
}

- (PXLexeme *)nextLexeme
{
    PXLexeme *result = nil;

    if (lexemeStack_.count > 0)
    {
        result = [lexemeStack_ pop];
    }
    else if (_source)
    {
        NSUInteger length = [_source length];
        BOOL followsWhitespace = NO;

        // loop until we find a valid lexeme or the end of the string
        while (offset_ < length)
        {
            NSRange range = NSMakeRange(offset_, length - offset_);
            PXLexeme *candidate = nil;

            for (id<PXLexemeCreator> creator in tokens_)
            {
                PXLexeme *lexeme = [creator createLexemeWithString:_source withRange:range];

                if (lexeme)
                {
                    NSRange lexemeRange = lexeme.range;

                    offset_ = lexemeRange.location + lexemeRange.length;
                    candidate = lexeme;

                    if (followsWhitespace)
                    {
                        [lexeme setFlag:PXLexemeFlagFollowsWhitespace];
                    }
                    break;
                }
            }

            // skip whitespace
            if (!candidate || candidate.type != PXSS_WHITESPACE)
            {
                result = candidate;
                break;
            }
            else
            {
                followsWhitespace = YES;
            }
        }

        // possibly create an error token
        if (!result && offset_ < length)
        {
            NSRange range = NSMakeRange(offset_, 1);
            result = [PXLexeme lexemeWithType:PXSS_ERROR withRange:range withValue:[_source substringWithRange:range]];

            if (followsWhitespace)
            {
                [result setFlag:PXLexemeFlagFollowsWhitespace];
            }

            offset_++;
        }
    }

    if (result)
    {
        BOOL followsWhitespace = [result flagIsSet:PXLexemeFlagFollowsWhitespace];

        if (blockDepth_ == 0 && result.type == PXSS_HEX_COLOR)
        {
            // fix-up colors to be ids outside of declaration blocks
            result = [PXLexeme lexemeWithType:PXSS_ID withRange:result.range withValue:result.value];

            if (followsWhitespace)
            {
                [result setFlag:PXLexemeFlagFollowsWhitespace];
            }
        }

        switch (result.type)
        {
            case PXSS_LCURLY:
                [self increaseNesting];
                break;

            case PXSS_RCURLY:
                [self decreaseNesting];
                break;

            case PXSS_ID:
            case PXSS_CLASS:
            case PXSS_IDENTIFIER:
            {
                NSString *stringValue = result.value;

                if ([stringValue rangeOfString:@"\\"].location != NSNotFound)
                {
                    // simply drop slash, for now
                    stringValue = [stringValue stringByReplacingOccurrencesOfString:@"\\" withString:@""];

                    result = [PXLexeme lexemeWithType:result.type withRange:result.range withValue:stringValue];

                    if (followsWhitespace)
                    {
                        [result setFlag:PXLexemeFlagFollowsWhitespace];
                    }
                }

                break;
            }
        }
    }
    else if (stateStack_.count > 0)
    {
        [self popSource];

        result = [self nextLexeme];
    }

    return result;
}

#pragma mark - Overrides

- (void)dealloc
{
    tokens_ = nil;
    lexemeStack_ = nil;
    stateStack_ = nil;
    _source = nil;
    _delegate = nil;
}

@end
