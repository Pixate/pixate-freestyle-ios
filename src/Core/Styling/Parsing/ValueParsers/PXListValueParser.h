//
//  PXListValueParser.h
//  PixateCore
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXValueParserBase.h"

@interface PXListValueParser : PXValueParserBase

- (id)initWithLexemes:(NSArray *)lexemes elementParser:(NSString *)name;
- (id)initWithLexer:(PXValueLexer *)lexer elementParser:(NSString *)name;

@end
