//
//  PXListValueParser.m
//  PixateCore
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXListValueParser.h"
#import "PXValueParserManager.h"
#import "PXStylesheetTokenType.h"

@interface PXListValueParser ()
@property (nonatomic, strong) NSString *elementParserName;
@end

@implementation PXListValueParser

#pragma mark - Initializers

- (id)initWithLexemes:(NSArray *)lexemes elementParser:(NSString *)name
{
    if (self = [super initWithLexemes:lexemes])
    {
        _elementParserName = name;
    }

    return self;
}

- (id)initWithLexer:(PXValueLexer *)lexer elementParser:(NSString *)name
{
    if (self = [super initWithLexer:lexer])
    {
        _elementParserName = name;
    }

    return self;
}

#pragma mark - Overrides

- (BOOL)canParse
{
    PXValueParserManager *manager = [PXValueParserManager sharedInstance];
    id<PXValueParser> elementParser = [manager parserForName:_elementParserName withLexer:self.lexer];

    return [elementParser canParse];
}

- (id)parse
{
    // setup parsers
    PXValueParserManager *manager = [PXValueParserManager sharedInstance];
    id<PXValueParser> elementParser = [manager parserForName:_elementParserName withLexer:self.lexer];

    // init return value
    NSMutableArray *items = [[NSMutableArray alloc] init];

    if ([elementParser canParse])
    {
        [items addObject:[elementParser parse]];

        while ([self isType:PXSS_COMMA])
        {
            // advance over ','
            [self advance];

            if ([elementParser canParse])
            {
                [items addObject:[elementParser parse]];
            }
            else
            {
                NSString *message = [NSString stringWithFormat:@"Expected valid element type for '%@'", _elementParserName];

                [self errorWithMessage:message];
            }
        }
    }
    else
    {
        NSString *message = [NSString stringWithFormat:@"Expected valid element type for '%@'", _elementParserName];

        [self errorWithMessage:message];
    }

    return [NSArray arrayWithArray:items];
}

@end
