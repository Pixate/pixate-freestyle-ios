//
//  PXValiueParserBase.m
//  PixateCore
//
//  Created by Kevin Lindsey on 12/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXValueParserBase.h"
#import "PXValueLexer.h"
#import "PXStylesheetTokenType.h"

@implementation PXValueParserBase

@synthesize errors;

#pragma mark - Initialization

- (id)initWithLexemes:(NSArray *)lexemes
{
    if (self = [self initWithLexer:[[PXValueLexer alloc] initWithLexemes:lexemes]])
    {
        [self advance];
    }

    return self;
}

- (id)initWithLexer:(PXValueLexer *)lexer
{
    if (self = [super init])
    {
        [self clearErrors];
        _lexer = lexer;
    }

    return self;
}

#pragma mark - PXParser Protocol

- (void)assertType:(int)type
{
    if (self.currentLexeme.type != type)
    {
        [self errorWithMessage:[NSString stringWithFormat:@"Expected a %@ token", [PXStylesheetTokenType typeNameForInt: type]]];
    }
}

- (void)addError:(NSString *)error
{
    [self internalAddError:error];
}

- (void)addError:(NSString *)error filename:(NSString *)filename offset:(NSString *)offset
{
    NSString *ammendedError;

    if (filename.length > 0)
    {
        ammendedError = [NSString stringWithFormat:@"[Pixate.ParseError, file='%@', offset=%@]: %@", filename, offset, error];
    }
    else
    {
        ammendedError = [NSString stringWithFormat:@"[Pixate.ParseError, offset=%@]: %@", offset, error];
    }

    [self internalAddError:ammendedError];

    //    [Pixate.configuration sendParseMessage:ammendedError];
}

- (void)clearErrors
{
    errors = nil;
}

- (void)errorWithMessage:(NSString *)message
{
    [NSException raise:@"Unexpected token type"
                format:@"%@. Found %@ token", message, [PXStylesheetTokenType typeNameForInt: self.currentLexeme.type]];
}

- (void)assertTypeInSet:(NSIndexSet *)set
{
    if (![self isInTypeSet:set])
    {
        NSMutableArray *tokens = [[NSMutableArray alloc] init];

        [set enumerateIndexesUsingBlock:^(NSUInteger type, BOOL *stop) {
            [tokens addObject:[PXStylesheetTokenType typeNameForInt: type]];
        }];

        NSString *message = [tokens componentsJoinedByString:@", "];

        [self errorWithMessage:[NSString stringWithFormat:@"Expected a token of one of these types: %@", message]];
    }
}

- (id<PXLexeme>)assertTypeAndAdvance:(int)type
{
    [self assertType:type];

    return [self advance];
}

- (void)advanceIfIsType:(int)type
{
    if (self.currentLexeme.type == type)
    {
        [self advance];
    }
}

- (void)advanceIfIsType:(int)type withWarning:(NSString *)warning
{
    if (self.currentLexeme.type == type)
    {
        [self advance];
    }
    else
    {
        [self errorWithMessage:warning];
    }
}

- (BOOL)isType:(int)type
{
    return self.currentLexeme.type == type;
}

- (BOOL)isInTypeSet:(NSIndexSet *)types
{
    return ([types containsIndex:self.currentLexeme.type]);
}

- (NSString *)lexemeNameFromType:(int)type
{
    // NOTE: sub-classes should override this
    return [NSString stringWithFormat:@"%d", type];
}

#pragma mark - Getters

- (id<PXLexeme>)currentLexeme
{
    return _lexer.currentLexeme;
}

#pragma mark - Overrides

- (id<PXLexeme>)advance
{
    return [_lexer advance];
}

- (void)internalAddError:(NSString *)error
{
    if (error && error.length > 0)
    {
        if (!errors)
        {
            errors = [NSMutableArray array];
        }

        [errors addObject:error];
    }
}

- (id)parse
{
    // subclasses should override
    return nil;
}

- (BOOL)canParse
{
    // subclasses should override
    return YES;
}

@end
