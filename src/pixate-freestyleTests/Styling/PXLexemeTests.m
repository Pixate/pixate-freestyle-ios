//
//  PXLexemeTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PXStylesheetLexeme.h"

@interface PXLexemeTests : XCTestCase

@end

@implementation PXLexemeTests

- (void)testInitialFlags
{
    PXStylesheetLexeme *lexeme = [PXStylesheetLexeme lexemeWithType:0 withRange:NSMakeRange(NSNotFound, 0) withValue:@""];

    XCTAssertFalse([lexeme flagIsSet:PXLexemeFlagFollowsWhitespace], @"flag should not be set");
}

- (void)testSetFlags
{
    PXStylesheetLexeme *lexeme = [PXStylesheetLexeme lexemeWithType:0 withRange:NSMakeRange(NSNotFound, 0) withValue:@""];

    [lexeme setFlag:PXLexemeFlagFollowsWhitespace];

    XCTAssertTrue([lexeme flagIsSet:PXLexemeFlagFollowsWhitespace], @"flag should be set");
}

- (void)testClearFlags
{
    PXStylesheetLexeme *lexeme = [PXStylesheetLexeme lexemeWithType:0 withRange:NSMakeRange(NSNotFound, 0) withValue:@""];

    [lexeme setFlag:PXLexemeFlagFollowsWhitespace];
    [lexeme clearFlag:PXLexemeFlagFollowsWhitespace];

    XCTAssertFalse([lexeme flagIsSet:PXLexemeFlagFollowsWhitespace], @"flag should not be set");
}

@end
