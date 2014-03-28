//
//  PXValiueParserBase.h
//  PixateCore
//
//  Created by Kevin Lindsey on 12/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXValueParser.h"

@interface PXValueParserBase : NSObject <PXValueParser>

@property (nonatomic, strong, readonly) PXValueLexer *lexer;

@end
