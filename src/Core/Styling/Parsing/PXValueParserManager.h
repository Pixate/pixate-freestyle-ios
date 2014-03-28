//
//  PXValueParserManager.h
//  PixateCore
//
//  Created by Kevin Lindsey on 12/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXValueParser.h"
#import "PXLexeme.h"
#import "PXValueLexer.h"

// Value Parser Names
extern NSString * const kPXValueParserName;
extern NSString * const kPXValueParserNumber;
extern NSString * const kPXValueParserSeconds;

@interface PXValueParserManager : NSObject

+ (PXValueParserManager *)sharedInstance;
+ (id)parseLexemes:(NSArray *)lexemes withParser:(NSString *)name;
+ (id)parseListWithLexemes:(NSArray *)lexemes elementParser:(NSString *)name;

- (void)addValueParser:(Class<PXValueParser>)parser forName:(NSString*)name;
- (void)addValueParsersFromDictionary:(NSDictionary *)parsersByName;

- (id<PXValueParser>)parserForName:(NSString *)name withLexemes:(NSArray *)lexemes;
- (id<PXValueParser>)parserForName:(NSString *)name withLexer:(PXValueLexer *)lexer;

@end
