//
//  PXDeclarationTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/8/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXDeclaration.h"
#import "PXStylesheetLexeme.h"
#import "PXStylesheetTokenType.h"
#import <XCTest/XCTest.h>

@interface PXDeclarationTests : XCTestCase

@end

@implementation PXDeclarationTests

#pragma mark - Tests

- (void)testStringWithTab
{
    NSString *string = @"\"one\\ttwo\"";
    NSString *expected = @"one\ttwo";
    PXDeclaration *declaration = [[PXDeclaration alloc] initWithName:@"test" value:string];
    NSString *result = declaration.stringValue;

    XCTAssertEqualObjects(result, expected, @"Escaped string does not match");
}

- (void)testStringWithReturn
{
    NSString *string = @"\"one\\rtwo\"";
    NSString *expected = @"one\rtwo";
    PXDeclaration *declaration = [[PXDeclaration alloc] initWithName:@"test" value:string];
    NSString *result = declaration.stringValue;

    XCTAssertEqualObjects(result, expected, @"Escaped string does not match");
}

- (void)testStringWithNewline
{
    NSString *string = @"\"one\\ntwo\"";
    NSString *expected = @"one\ntwo";
    PXDeclaration *declaration = [[PXDeclaration alloc] initWithName:@"test" value:string];
    NSString *result = declaration.stringValue;

    XCTAssertEqualObjects(result, expected, @"Escaped string does not match");
}

- (void)testStringWithFormFeed
{
    NSString *string = @"\"one\\ftwo\"";
    NSString *expected = @"one\ftwo";
    PXDeclaration *declaration = [[PXDeclaration alloc] initWithName:@"test" value:string];
    NSString *result = declaration.stringValue;

    XCTAssertEqualObjects(result, expected, @"Escaped string does not match");
}

- (void)testStringWithEscapedCharacter
{
    NSString *string = @"\"one\\.two\"";
    NSString *expected = @"one.two";
    PXDeclaration *declaration = [[PXDeclaration alloc] initWithName:@"test" value:string];
    NSString *result = declaration.stringValue;

    XCTAssertEqualObjects(result, expected, @"Escaped string does not match");
}

@end
