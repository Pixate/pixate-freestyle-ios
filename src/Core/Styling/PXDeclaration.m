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
//  PXDeclaration.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXDeclaration.h"
#import "PXStylesheetLexeme.h"
#import "PXStylesheetTokenType.h"
#import "PXValueParser.h"
#import "PXTransformParser.h"
#import "PXValue.h"
#import "PXStylerContext.h"

#import "PXNumberValueParser.h"
#import "PXScriptManager.h"

#import "PXValueParserManager.h"

#define IsNotCachedType(T) ![cache_ isKindOfClass:[PXValue class]] || ((PXValue *)cache_).type != PXValueType_##T

@implementation PXDeclaration
{
    id cache_;
    NSUInteger hash_;
    NSString *source_;
    NSString *filename_;
    BOOL hasExpression_;
}

static PXValueParser *PARSER;
static NSRegularExpression *ESCAPE_SEQUENCES;
static NSDictionary *ESCAPE_SEQUENCE_MAP;

#pragma mark - Static initializers

+ (void)initialize
{
    if (!ESCAPE_SEQUENCES)
    {
        NSError *error = NULL;

        ESCAPE_SEQUENCES = [NSRegularExpression regularExpressionWithPattern:@"\\\\."
                                                                     options:NSRegularExpressionDotMatchesLineSeparators
                                                                       error:&error];
    }
    if (!ESCAPE_SEQUENCE_MAP)
    {
        ESCAPE_SEQUENCE_MAP = @{
            @"\\t" : @"\t",
            @"\\r" : @"\r",
            @"\\n" : @"\n",
            @"\\f" : @"\f"
        };
    }

    if (!PARSER)
    {
        PARSER = [[PXValueParser alloc] init];
    }
}

#pragma mark - Initializers

- (id)init
{
    return [self initWithName:@"<unknown>" value:nil];
}

- (id)initWithName:(NSString *)name
{
    return [self initWithName:name value:nil];
}

- (id)initWithName:(NSString *)name value:(NSString *)value
{
    if (self = [super init])
    {
        _name = name;
        cache_ = nil;

        [self setSource:value filename:nil lexemes:[PXValueParser lexemesForSource:value]];
    }

    return self;
}

#pragma mark - Setters

- (void)setSource:(NSString *)source filename:(NSString *)filename lexemes:(NSArray *)lexemes
{
    _lexemes = lexemes;
    source_ = source;
    filename_ = filename;

    hash_ = _name.hash;

    if (lexemes.count > 0)
    {
        PXStylesheetLexeme *firstLexeme = [lexemes objectAtIndex:0];
        NSUInteger firstOffset = firstLexeme.range.location;

        hasExpression_ = NO;

        [_lexemes enumerateObjectsUsingBlock:^(PXStylesheetLexeme *lexeme, NSUInteger idx, BOOL *stop) {
            NSRange lexemeRange = lexeme.range;
            NSRange normalizedRange = NSMakeRange(lexemeRange.location - firstOffset, lexemeRange.length);

            hash_ = hash_ * 31 + [source substringWithRange:normalizedRange].hash;

            if (lexeme.type == PXSS_EXPRESSION)
            {
                hasExpression_ = YES;
            }
        }];
    }
}

#pragma mark - Methods

- (CGAffineTransform)affineTransformValue
{
    if (IsNotCachedType(CGAffineTransform))
    {
        PXTransformParser *transformParser = [[PXTransformParser alloc] init];
        CGAffineTransform result = [transformParser parse:self.stringValue];

        cache_ = [[PXValue alloc] initWithBytes:&result type:PXValueType_CGAffineTransform];
    }

    return ((PXValue *)cache_).CGAffineTransformValue;
}

- (NSArray *)animationInfoList
{
    // TODO: cache
    return [self.parser parseAnimationInfos:_lexemes];
}

- (NSArray *)transitionInfoList
{
    // TODO: cache
    return [self.parser parseTransitionInfos:_lexemes];
}

- (NSArray *)animationDirectionList
{
    // TODO: cache
    return [self.parser parseAnimationDirectionList:_lexemes];
}

- (NSArray *)animationFillModeList
{
    // TODO: cache
    return [self.parser parseAnimationFillModeList:_lexemes];
}

- (NSArray *)animationPlayStateList
{
    // TODO: cache
    return [self.parser parseAnimationPlayStateList:_lexemes];
}

- (NSArray *)animationTimingFunctionList
{
    // TODO: cache
    return [self.parser parseAnimationTimingFunctionList:_lexemes];
}

- (BOOL)booleanValue
{
    if (IsNotCachedType(Boolean))
    {
        NSString *text = self.firstWord;
        BOOL result = ([@"yes" isEqualToString:text] || [@"true" isEqualToString:text]);

        cache_ = [[PXValue alloc] initWithBytes:&result type:PXValueType_Boolean];
    }

    return ((PXValue *) cache_).BooleanValue;
}

- (PXBorderInfo *)borderValue
{
    if (cache_ != [NSNull null] && ![cache_ isKindOfClass:[PXBorderInfo class]])
    {
        cache_ = [self.parser parseBorder:_lexemes];
    }

    return (cache_ != [NSNull null]) ? cache_ : nil;
}

- (NSArray *)borderRadiiList
{
    // TODO: cache
    return [self.parser parseBorderRadiusList:_lexemes];
}

- (PXBorderStyle)borderStyleValue
{
    if (IsNotCachedType(PXBorderStyle))
    {
        PXBorderStyle style = [self.parser parseBorderStyle:_lexemes];

        cache_ = [[PXValue alloc] initWithBytes:&style type:PXValueType_PXBorderStyle];
    }

    return ((PXValue *) cache_).PXBorderStyleValue;
}

- (NSArray *)borderStyleList
{
    // TODO: cache
    return [self.parser parseBorderStyleList:_lexemes];
}

- (PXCacheStylesType)cacheStylesTypeValue
{
    if (IsNotCachedType(PXCacheStylesType))
    {
        PXCacheStylesType type = PXCacheStylesTypeNone;
        NSArray *words = self.nameListValue;

        for (NSString *word in words)
        {
            if ([@"none" isEqualToString:word])
            {
                type = PXCacheStylesTypeNone;
            }
            else if ([@"auto" isEqualToString:word])
            {
                type |= PXCacheStylesTypeStyleOnce | PXCacheStylesTypeImages;
            }
            else if ([@"all" isEqualToString:word])
            {
                type |= PXCacheStylesTypeStyleOnce | PXCacheStylesTypeImages | PXCacheStylesTypeSave;
            }
            else if ([@"minimize-styling" isEqualToString:word])
            {
                type |= PXCacheStylesTypeStyleOnce;
            }
            else if ([@"cache-cells" isEqualToString:word])
            {
                type |= PXCacheStylesTypeSave;
            }
            else if ([@"cache-images" isEqualToString:word])
            {
                type |= PXCacheStylesTypeImages;
            }
        }

        cache_ = [[PXValue alloc] initWithBytes:&type type:PXValueType_PXCacheStylesType];
    }

    return ((PXValue *) cache_).PXCacheStylesTypeValue;
}

- (UIColor *)colorValue
{
    /* TODO: Cache
    if (cache_ != [NSNull null] && ![cache_ isKindOfClass:[UIColor class]])
    {
        cache_ = [self.parser parseColor:_lexemes];

        if (cache_ == nil)
        {
            cache_ = [NSNull null];
        }
    }

    return (cache_ != [NSNull null]) ? cache_ : nil;
    */
    
    PXValueParserManager *manager = [PXValueParserManager sharedInstance];
    id<PXValueParserProtocol> colorParser = [manager parserForName:kPXValueParserColor withLexemes:_lexemes];
    UIColor *result = [colorParser parse];
    
    return result;
}

- (NSString *)firstWord
{
    NSString *result = nil;

    if (_lexemes.count > 0)
    {
        PXStylesheetLexeme *lexeme = [_lexemes objectAtIndex:0];

        if ([lexeme.value isKindOfClass:[NSString class]])
        {
            result = lexeme.value;
            result = [result lowercaseString];
        }
    }

    return result;
}

- (CGFloat)floatValue
{
    NSArray *lexemes;

    if (hasExpression_)
    {
        NSMutableArray *buffer = [[NSMutableArray alloc] init];

        [_lexemes enumerateObjectsUsingBlock:^(id<PXLexeme> lexeme, NSUInteger idx, BOOL *stop) {
            if (lexeme.type == PXSS_EXPRESSION)
            {
                NSString *text = (NSString *)lexeme.value;
                NSRange range = NSMakeRange(2, text.length - 4);
                NSString *source = [text substringWithRange:range];
                id<PXExpressionValue> result = [[PXScriptManager sharedInstance] evaluate:source withScopes:nil];
                NSArray *newLexemes = [PXValueParser lexemesForSource:result.stringValue];

                [buffer addObjectsFromArray:newLexemes];
            }
            else
            {
                [buffer addObject:lexeme];
            }
        }];

        lexemes = buffer;
    }
    else
    {
        lexemes = _lexemes;
    }

    PXValueParserManager *manager = [PXValueParserManager sharedInstance];
    id<PXValueParserProtocol> numberParser = [manager parserForName:kPXValueParserNumber withLexemes:lexemes];
    NSNumber *result = [numberParser parse];

    return [result floatValue];
}

- (NSArray *)floatListValue
{
    // TODO: cache
    return [self.parser parseFloatList:_lexemes];
}

- (UIEdgeInsets)insetsValue
{
    if (IsNotCachedType(UIEdgeInsets))
    {
        UIEdgeInsets insets = [self.parser parseInsets:_lexemes];

        cache_ = [[PXValue alloc] initWithBytes:&insets type:PXValueType_UIEdgeInsets];
    }

    return ((PXValue *)cache_).UIEdgeInsetsValue;
}

- (PXDimension *)lengthValue
{
    if (![cache_ isKindOfClass:[PXDimension class]])
    {
        if (_lexemes.count > 0)
        {
            PXStylesheetLexeme *lexeme = [_lexemes objectAtIndex:0];

            if (lexeme.type == PXSS_LENGTH)
            {
                cache_ = lexeme.value;
            }
            else if (lexeme.type == PXSS_NUMBER)
            {
                NSNumber *number = lexeme.value;

                cache_ = [[PXDimension alloc] initWithNumber:[number floatValue] withDimension:@"px"];
            }
            // error
        }
    }

    return cache_;
}

// TODO: The return type if diff, but the enum order is the same...
- (NSLineBreakMode)lineBreakModeValue
{
    static NSDictionary *MAP;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MAP = @{
            @"clip": @(NSLineBreakByClipping),
            @"ellipsis-head": @(NSLineBreakByTruncatingHead),
            @"ellipsis-middle": @(NSLineBreakByTruncatingMiddle),
            @"ellipsis": @(NSLineBreakByTruncatingMiddle),
            @"ellipsis-tail": @(NSLineBreakByTruncatingTail),
            @"word-wrap": @(NSLineBreakByWordWrapping),
            @"character-wrap": @(NSLineBreakByCharWrapping),
        };
    });

    if (IsNotCachedType(NSLineBreakMode))
    {
        NSLineBreakMode mode = NSLineBreakByTruncatingMiddle;
        NSString *text = self.firstWord;
        NSNumber *value = [MAP valueForKey:text];

        if (value)
        {
            mode = (NSLineBreakMode) [value intValue];
        }

        cache_ = [[PXValue alloc] initWithBytes:&mode type:PXValueType_NSLineBreakMode];
    }

    return ((PXValue *) cache_).NSLineBreakModeValue;
}

- (NSArray *)nameListValue
{
    // TODO: cache
    return [self.parser parseNameList:_lexemes];
}

- (PXOffsets *)offsetsValue
{
    if (cache_ != [NSNull null] && ![cache_ isKindOfClass:[PXOffsets class]])
    {
        cache_ = [self.parser parseOffsets:_lexemes];

        if (cache_ == nil)
        {
            cache_ = [NSNull null];
        }
    }

    return (cache_ != [NSNull null]) ? cache_ : nil;
}

- (NSArray *)paintList
{
    // TODO: cache
    return [self.parser parsePaints:_lexemes];
}

- (id<PXPaint>)paintValue
{
    if (cache_ != [NSNull null] && ![cache_ conformsToProtocol:@protocol(PXPaint)])
    {
        cache_ = [self.parser parsePaint:_lexemes];

        if (cache_ == nil)
        {
            cache_ = [NSNull null];
        }
    }

    return (cache_ != [NSNull null]) ? cache_ : nil;
}

- (PXParseErrorDestination)parseErrorDestinationValue
{
    if (IsNotCachedType(PXParseErrorDestination))
    {
        PXParseErrorDestination destination = PXParseErrorDestinationNone;
        NSString *text = self.firstWord;

        if ([@"console" isEqualToString:text])
        {
            destination = PXParseErrorDestinationConsole;
        }
#ifdef PX_LOGGING
        else if ([@"logger" isEqualToString:text])
        {
            destination = PXParseErrorDestination_Logger;
        }
#endif

        cache_ = [[PXValue alloc] initWithBytes:&destination type:PXValueType_PXParseErrorDestination];
    }

    return ((PXValue *) cache_).PXParseErrorDestinationValue;
}

- (CGFloat)secondsValue
{
    // TODO: cache
    return [self.parser parseSeconds:_lexemes];
}

- (NSArray *)secondsListValue
{
    // TODO: cache
    return [self.parser parseSecondsList:_lexemes];
}

- (CGSize)sizeValue
{
    if (IsNotCachedType(CGSize))
    {
        CGSize result = [self.parser parseSize:_lexemes];

        cache_ = [[PXValue alloc] initWithBytes:&result type:PXValueType_CGSize];
    }

    return ((PXValue *)cache_).CGSizeValue;
}

- (id<PXShadowPaint>)shadowValue
{
    if (cache_ != [NSNull null] && ![cache_ conformsToProtocol:@protocol(PXShadowPaint)])
    {
        cache_ = [self.parser parseShadow:_lexemes];

        if (cache_ == nil)
        {
            cache_ = [NSNull null];
        }
    }

    return (cache_ != [NSNull null]) ? cache_ : nil;
}

- (NSString *)stringValue
{
    if (![cache_ isKindOfClass:[NSString class]])
    {
        NSMutableArray *parts = [NSMutableArray arrayWithCapacity:_lexemes.count];

        for (PXStylesheetLexeme *lexeme in _lexemes)
        {
            if (lexeme.type == PXSS_STRING)
            {
                // grab raw value
                NSString *value = lexeme.value;

                // trim quotes
                NSString *content = [value substringWithRange:NSMakeRange(1, value.length - 2)];

                // replace escape sequences
                NSArray *matches = [ESCAPE_SEQUENCES matchesInString:content options:0 range:NSMakeRange(0, content.length)];

                for (NSTextCheckingResult *match in matches)
                {
                    NSRange matchRange = match.range;
                    NSString *replacementText = [ESCAPE_SEQUENCE_MAP objectForKey:[content substringWithRange:matchRange]];

                    if (!replacementText)
                    {
                        replacementText = [content substringWithRange:NSMakeRange(matchRange.location + 1, matchRange.length - 1)];
                    }

                    content = [content stringByReplacingCharactersInRange:matchRange withString:replacementText];
                }

                // append result
                [parts addObject:content];
            }
            else
            {
                [parts addObject:lexeme.value];
            }
        }

        // TODO: create another method to allow join string to be defined?
        cache_ = [parts componentsJoinedByString:@" "];
    }

    return cache_;
}

- (NSTextAlignment)textAlignmentValue
{
    static NSDictionary *MAP;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MAP = @{
            @"left": @(NSTextAlignmentLeft),
            @"center": @(NSTextAlignmentCenter),
            @"right": @(NSTextAlignmentRight),
        };
    });

    if (IsNotCachedType(NSTextAlignment))
    {
        NSTextAlignment alignment = NSTextAlignmentCenter;
        NSString *text = self.firstWord;
        NSNumber *value = [MAP objectForKey:text];

        if (value)
        {
            alignment = (NSTextAlignment) [value intValue];
        }

        cache_ = [[PXValue alloc] initWithBytes:&alignment type:PXValueType_NSTextAlignment];
    }

    return ((PXValue *) cache_).NSTextAlignmentValue;
}

- (UITextBorderStyle)textBorderStyleValue
{
    static NSDictionary *MAP;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MAP = @{
            @"line": @(UITextBorderStyleLine),
            @"bezel": @(UITextBorderStyleBezel),
            @"rounded-rect": @(UITextBorderStyleRoundedRect),
        };
    });

    if (IsNotCachedType(UITextBorderStyle))
    {
        UITextBorderStyle style = UITextBorderStyleNone;
        NSString *text = self.firstWord;
        NSNumber *value = [MAP objectForKey:text];

        if (value)
        {
            style = (UITextBorderStyle) [value intValue];
        }

        cache_ = [[PXValue alloc] initWithBytes:&style type:PXValueType_UITextBorderStyle];
    }

    return ((PXValue *) cache_).UITextBorderStyleValue;
}

- (NSString *)transformString:(NSString *)value
{
    NSString *text = self.firstWord;
    return [PXStylerContext transformString:value usingAttribute:text];
}

- (PXDimension *)letterSpacingValue
{
    PXDimension *result = nil;
    if (_lexemes.count > 0)
    {
        PXStylesheetLexeme *lexeme = [_lexemes objectAtIndex:0];
        
        if (lexeme.type == PXSS_LENGTH || lexeme.type == PXSS_EMS || lexeme.type == PXSS_PERCENTAGE)
        {
            result = lexeme.value;
        }
        else if (lexeme.type == PXSS_NUMBER)
        {
            NSNumber *number = lexeme.value;
            result = [[PXDimension alloc] initWithNumber:[number floatValue] withDimension:@"px"];
        }
        // error
    }
    return result;
}

- (NSURL *)URLValue
{
    // NOTE: When we generate URLs during the parse, we sometimes look for other files based on the specified file. It's
    // possible for a file to exist one time and not another, resulting in different URLs. We don't cache to catch these
    // cases.
    return [self.parser parseURL:_lexemes];
}

#pragma mark - Helpers

- (PXValueParser *)parser
{
    // TODO: pull from parser pool?
    PARSER.filename = filename_;

    return PARSER;
}

#pragma mark - Overrides

- (void)dealloc
{
    cache_ = nil;
    source_ = nil;
    _name = nil;
    _lexemes = nil;
}

- (NSString *)description
{
    if (self.important)
    {
        return [NSString stringWithFormat:@"%@: %@ !important;", self.name, self.stringValue];
    }
    else
    {
        return [NSString stringWithFormat:@"%@: %@;", self.name, self.stringValue];
    }
}

- (NSUInteger)hash
{
    return hash_;
}

@end
