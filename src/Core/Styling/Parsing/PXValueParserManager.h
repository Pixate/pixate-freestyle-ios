//
//  PXValueParserManager.h
//  PixateCore
//
//  Created by Kevin Lindsey on 12/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXValueParserProtocol.h"
#import "PXLexeme.h"
#import "PXValueLexer.h"

// Value Parser Names
extern NSString * const kPXValueParserName;
extern NSString * const kPXValueParserNumber;
extern NSString * const kPXValueParserSeconds;

extern NSString * const kPXValueParserColor;


extern NSString * const kPXValueParserAnimationInfo;
extern NSString * const kPXValueParserAnimationTimingFunction;
extern NSString * const kPXValueParserAnimationDirection;
extern NSString * const kPXValueParserAnimationFillMode;
extern NSString * const kPXValueParserAnimationPlayState;
extern NSString * const kPXValueParserTransitionInfo;

@interface PXValueParserManager : NSObject

+ (PXValueParserManager *)sharedInstance;
+ (id)parseLexemes:(NSArray *)lexemes withParser:(NSString *)name;
+ (id)parseListWithLexemes:(NSArray *)lexemes elementParser:(NSString *)name;

- (void)addValueParser:(Class<PXValueParserProtocol>)parser forName:(NSString*)name;
- (void)addValueParsersFromDictionary:(NSDictionary *)parsersByName;

- (id<PXValueParserProtocol>)parserForName:(NSString *)name withLexemes:(NSArray *)lexemes;
- (id<PXValueParserProtocol>)parserForName:(NSString *)name withLexer:(PXValueLexer *)lexer;

@end
