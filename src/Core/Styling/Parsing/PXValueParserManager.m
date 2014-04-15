//
//  PXValueParserManager.m
//  PixateCore
//
//  Created by Kevin Lindsey on 12/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXValueParserManager.h"

#import <objc/runtime.h>

#import "PXNameValueParser.h"
#import "PXNumberValueParser.h"
#import "PXSecondsValueParser.h"
#import "PXListValueParser.h"

#import "PXAnimationInfoValueParser.h"
#import "PXAnimationTimingFunctionValueParser.h"
#import "PXAnimationDirectionValueParser.h"
#import "PXAnimationFillModeValueParser.h"
#import "PXAnimationPlayStateValueParser.h"
#import "PXTransitionInfoValueParser.h"

#import "PXColorValueParser.h"

// Value Parser Names
NSString * const kPXValueParserName = @"PXValueParserName";
NSString * const kPXValueParserNumber = @"PXValueParserNumber";
NSString * const kPXValueParserSeconds = @"PXValueParserSeconds";

NSString * const kPXValueParserColor = @"PXValueParserColor";

NSString * const kPXValueParserAnimationInfo = @"PXValueParserAnimationInfo";
NSString * const kPXValueParserAnimationTimingFunction = @"PXValueParserAnimationTimingFunction";
NSString * const kPXValueParserAnimationDirection = @"PXValueParserAnimationDirection";
NSString * const kPXValueParserAnimationFillMode = @"PXValueParserAnimationFillMode";
NSString * const kPXValueParserAnimationPlayState = @"PXValueParserAnimationPlayState";
NSString * const kPXValueParserTransitionInfo = @"PXValueParserTransitionInfo";

static NSMutableDictionary *PARSERS_BY_NAME;

@implementation PXValueParserManager

+ (PXValueParserManager *)sharedInstance
{
    static PXValueParserManager *manager;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        manager = [[PXValueParserManager alloc] init];
        PARSERS_BY_NAME = [[NSMutableDictionary alloc] init];
        [manager setupDefaultParsers];
    });

    return manager;
}

+ (id)parseLexemes:(NSArray *)lexemes withParser:(NSString *)name
{
    PXValueParserManager *manager = [self sharedInstance];
    id<PXValueParserProtocol> parser = [manager parserForName:name withLexemes:lexemes];

    return [parser parse];
}

+ (id)parseListWithLexemes:(NSArray *)lexemes elementParser:(NSString *)name
{
    PXListValueParser *parser = [[PXListValueParser alloc] initWithLexemes:lexemes elementParser:name];

    return [parser parse];
}

#pragma mark - Methods

- (void)setupDefaultParsers
{
    // Setup core value parsers
    [self addValueParser:[PXNameValueParser class] forName:kPXValueParserName];
    [self addValueParser:[PXNumberValueParser class] forName:kPXValueParserNumber];
    [self addValueParser:[PXSecondsValueParser class] forName:kPXValueParserSeconds];
    [self addValueParser:[PXColorValueParser class] forName:kPXValueParserColor];

    // Setup animation value parsers
    [self addValueParsersFromDictionary: @{
                                          kPXValueParserAnimationInfo:            [PXAnimationInfoValueParser class],
                                          kPXValueParserAnimationTimingFunction:  [PXAnimationTimingFunctionValueParser class],
                                          kPXValueParserAnimationDirection:       [PXAnimationDirectionValueParser class],
                                          kPXValueParserAnimationFillMode:        [PXAnimationFillModeValueParser class],
                                          kPXValueParserAnimationPlayState:       [PXAnimationPlayStateValueParser class],
                                          kPXValueParserTransitionInfo:           [PXTransitionInfoValueParser class]
                                          }];

}

- (void)addValueParser:(Class<PXValueParserProtocol>)parser forName:(NSString*)name
{
    if (name.length > 0 && parser)
    {
        [PARSERS_BY_NAME setObject:parser forKey:name];
    }
}

- (void)addValueParsersFromDictionary:(NSDictionary *)parsersByName
{
    for (id key in [parsersByName allKeys])
    {
        if ([key isKindOfClass:[NSString class]])
        {
            NSString *name = (NSString *)key;
            id value = [parsersByName objectForKey:key];

            if (class_isMetaClass(object_getClass(value)))
            {
                Class parserClass = (Class) value;

                if ([parserClass conformsToProtocol:@protocol(PXValueParserProtocol)])
                {
                    [self addValueParser:parserClass forName:name];
                }
                else
                {
                    NSLog(@"Value parser dictionary value does not comform to the PXValueParser protocol: %@", parserClass);
                }
            }
            else
            {
                NSLog(@"Value parser dictionary value is not a class: %@(%@)", value, [value class]);
            }
        }
        else
        {
            NSLog(@"Value parser dictionary key is not a string: %@(%@)", key, [key class]);
        }
    }
}

- (id<PXValueParserProtocol>)parserForName:(NSString *)name withLexemes:(NSArray *)lexemes
{
    Class parserClass = [PARSERS_BY_NAME objectForKey:name];

    return [[parserClass alloc] initWithLexemes:lexemes];
}

- (id<PXValueParserProtocol>)parserForName:(NSString *)name withLexer:(PXValueLexer *)lexer
{
    Class parserClass = [PARSERS_BY_NAME objectForKey:name];

    return [[parserClass alloc] initWithLexer:lexer];
}

@end
