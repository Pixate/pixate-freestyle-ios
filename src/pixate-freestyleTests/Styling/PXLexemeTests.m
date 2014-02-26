//
//  PXLexemeTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PXLexeme.h"

@interface PXLexemeTests : XCTestCase

@end

@implementation PXLexemeTests

- (void)testInitialFlags
{
    PXLexeme *lexeme = [PXLexeme lexemeWithType:0 withRange:NSMakeRange(NSNotFound, 0) withValue:@""];

    XCTAssertFalse([lexeme flagIsSet:PXLexemeFlagFollowsWhitespace], @"flag should not be set");
}

- (void)testSetFlags
{
    PXLexeme *lexeme = [PXLexeme lexemeWithType:0 withRange:NSMakeRange(NSNotFound, 0) withValue:@""];

    [lexeme setFlag:PXLexemeFlagFollowsWhitespace];

    XCTAssertTrue([lexeme flagIsSet:PXLexemeFlagFollowsWhitespace], @"flag should be set");
}

- (void)testClearFlags
{
    PXLexeme *lexeme = [PXLexeme lexemeWithType:0 withRange:NSMakeRange(NSNotFound, 0) withValue:@""];

    [lexeme setFlag:PXLexemeFlagFollowsWhitespace];
    [lexeme clearFlag:PXLexemeFlagFollowsWhitespace];

    XCTAssertFalse([lexeme flagIsSet:PXLexemeFlagFollowsWhitespace], @"flag should not be set");
}

@end
