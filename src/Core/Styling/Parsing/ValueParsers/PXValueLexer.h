//
//  PXValueLexer.h
//  PixateCore
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXLexeme.h"

@interface PXValueLexer : NSObject

@property (nonatomic, strong, readonly) id<PXLexeme> currentLexeme;

- (id)initWithLexemes:(NSArray *)lexemes;

- (id<PXLexeme>)advance;

@end
