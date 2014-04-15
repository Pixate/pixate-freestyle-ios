//
//  PXValueParser.h
//  PixateCore
//
//  Created by Kevin Lindsey on 12/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXParser.h"
#import "PXLexeme.h"
#import "PXValueLexer.h"

@protocol PXValueParserProtocol <PXParser>

@property (nonatomic, strong, readonly) id<PXLexeme>  currentLexeme;

- (id)initWithLexemes:(NSArray *)lexemes;
- (id)initWithLexer:(PXValueLexer *)lexer;
- (id)parse;

/**
 *  The parser determines by looking at the current lexeme if it might be able to parse
 */
- (BOOL)canParse;

@end
