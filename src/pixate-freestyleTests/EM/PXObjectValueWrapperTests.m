//
//  PXObjectValueWrapperTests.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/18/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PXPropertyTestClass.h"
#import "PXObjectValueWrapper.h"
#import "PixateFreestyle.h"
#import "PXRGBColorValue.h"
#import "PXHSBColorValue.h"

@interface PXObjectValueWrapperTests : XCTestCase

@end

@implementation PXObjectValueWrapperTests

+ (void)initialize
{
    [PixateFreestyle initializePixateFreestyle];
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Automatic Setup Tests

- (void)testColorGetterAutoWrapped
{
    PXPropertyTestClass *object = [[PXPropertyTestClass alloc] init];
    PXObjectValueWrapper *wrapper = [[PXObjectValueWrapper alloc] initWithObject:object];
    [wrapper addExports];

    id<PXExpressionValue> result = [wrapper valueForPropertyName:@"color"];

    XCTAssertTrue([@"rgba(255,0,0,1)" isEqualToString:result.description], @"Colors do not match");
}

- (void)testColorSetterAutoWrapped
{
    PXPropertyTestClass *object = [[PXPropertyTestClass alloc] init];
    PXObjectValueWrapper *wrapper = [[PXObjectValueWrapper alloc] initWithObject:object];
    [wrapper addExports];

    PXHSBColorValue *color = [[PXHSBColorValue alloc] initWithHue:180.0 saturation:0.5 brightness:0.75];
    [wrapper setValue:color forPropertyName:@"color"];
    id<PXExpressionValue> result = [wrapper valueForPropertyName:@"color"];

    XCTAssertTrue([@"rgba(95,191,191,1)" isEqualToString:result.description], @"Colors do not match");
}

- (void)testColorValueGetterAutoWrapped
{
    PXPropertyTestClass *object = [[PXPropertyTestClass alloc] init];
    PXObjectValueWrapper *wrapper = [[PXObjectValueWrapper alloc] initWithObject:object];
    [wrapper addExports];

    id<PXExpressionValue> result = [wrapper valueForPropertyName:@"pxColor"];

    XCTAssertTrue([@"hsba(180,0.5,0.75,1)" isEqualToString:result.description], @"Colors do not match");
}

- (void)testColorValueSetterAutoWrapped
{
    PXPropertyTestClass *object = [[PXPropertyTestClass alloc] init];
    PXObjectValueWrapper *wrapper = [[PXObjectValueWrapper alloc] initWithObject:object];
    [wrapper addExports];

    PXHSBColorValue *color = [[PXHSBColorValue alloc] initWithHue:90.0 saturation:0.25 brightness:0.5];
    [wrapper setValue:color forPropertyName:@"pxColor"];
    id<PXExpressionValue> result = [wrapper valueForPropertyName:@"pxColor"];

    XCTAssertTrue([@"hsba(90,0.25,0.5,1)" isEqualToString:result.description], @"Colors do not match");
}

@end
