//
//  PXValueParserManager.m
//  PixateCore
//
//  Created by Kevin Lindsey on 12/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXValueParserManager.h"

#import "PXNameValueParser.h"
#import "PXNumberValueParser.h"
#import "PXSecondsValueParser.h"
#import "PXListValueParser.h"
#import <objc/runtime.h>

// Value Parser Names
NSString * const kPXValueParserName = @"PXValueParserName";
NSString * const kPXValueParserNumber = @"PXValueParserNumber";
NSString * const kPXValueParserSeconds = @"PXValueParserSeconds";

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
    // Setup value parsers provided by the core
    [self addValueParser:[PXNameValueParser class] forName:kPXValueParserName];
    [self addValueParser:[PXNumberValueParser class] forName:kPXValueParserNumber];
    [self addValueParser:[PXSecondsValueParser class] forName:kPXValueParserSeconds];
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
