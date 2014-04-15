//
//  PXValiueParserBase.h
//  PixateCore
//
//  Created by Kevin Lindsey on 12/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXValueParserProtocol.h"

@interface PXValueParserBase : NSObject <PXValueParserProtocol>

@property (nonatomic, strong, readonly) PXValueLexer *lexer;

@end
