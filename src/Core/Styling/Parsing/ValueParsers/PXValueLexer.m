//
//  PXValueLexer.m
//  PixateCore
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXValueLexer.h"

@interface PXValueLexer ()
@property (nonatomic, strong) NSArray *lexemes;
@property (nonatomic) NSUInteger index;
@end

@implementation PXValueLexer

#pragma mark - Initializers

- (id)initWithLexemes:(NSArray *)lexemes
{
    if (self = [super init])
    {
        _lexemes = lexemes;
        _index = 0;
    }

    return self;
}

- (id)init
{
    return [self initWithLexemes:@[]];
}

#pragma mark - Methods

- (id<PXLexeme>)advance
{
    return _currentLexeme = (_index < _lexemes.count) ? [_lexemes objectAtIndex:_index++] : nil;
}

@end
