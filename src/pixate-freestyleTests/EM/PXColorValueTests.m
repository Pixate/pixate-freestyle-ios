//
//  PXColorValueTests.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/18/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PXExpressionUnit.h"
#import "PXExpressionParser.h"
#import "PXFreestyleBuiltinScope.h"

@interface PXColorValueTests : XCTestCase

@end

@implementation PXColorValueTests

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

- (PXExpressionUnit *)compileString:(NSString *)source
{
    PXExpressionParser *parser = [[PXExpressionParser alloc] init];

    return [parser compileString:source];
}

- (id<PXExpressionValue>)valueFromExecutingString:(NSString *)source
{
    // compile
    PXExpressionUnit *unit = [self compileString:source];

    // execute
    id<PXExpressionScope> global = [[PXFreestyleBuiltInScope alloc] init];
    PXExpressionEnvironment *env = [[PXExpressionEnvironment alloc] initWithGlobalScope:global];
    [env executeUnit:unit];

    // return result
    return [env popValue];
}

- (void)assertDoubleValue:(id<PXExpressionValue>)value expected:(double)expected
{
    XCTAssertNotNil(value, "Expected a non-nil result");
    XCTAssertTrue(value.valueType == PX_VALUE_TYPE_DOUBLE, @"Expected value to be a double");
    XCTAssertTrue(value.doubleValue == expected, @"Expected double value to be '%f' but was '%f'", expected, value.doubleValue);
}

- (void)testRGBColorValue
{
    id<PXExpressionValue> color = [self valueFromExecutingString:@"rgb(10, 20, 30)"];
    id<PXExpressionValue> red = [self valueFromExecutingString:@"rgb(10, 20, 30).red"];
    id<PXExpressionValue> green = [self valueFromExecutingString:@"rgb(10, 20, 30).green"];
    id<PXExpressionValue> blue = [self valueFromExecutingString:@"rgb(10, 20, 30).blue"];
    id<PXExpressionValue> alpha = [self valueFromExecutingString:@"rgb(10, 20, 30).alpha"];

    XCTAssertTrue([@"rgba(10,20,30,1)" isEqualToString:color.description]);
    [self assertDoubleValue:red expected:10.0];
    [self assertDoubleValue:green expected:20.0];
    [self assertDoubleValue:blue expected:30.0];
    [self assertDoubleValue:alpha expected:1.0];
}

- (void)testRGBAColorValue
{
    id<PXExpressionValue> color = [self valueFromExecutingString:@"rgba(10, 20, 30, 0.5)"];
    id<PXExpressionValue> red = [self valueFromExecutingString:@"rgba(10, 20, 30, 0.5).red"];
    id<PXExpressionValue> green = [self valueFromExecutingString:@"rgba(10, 20, 30, 0.5).green"];
    id<PXExpressionValue> blue = [self valueFromExecutingString:@"rgba(10, 20, 30, 0.5).blue"];
    id<PXExpressionValue> alpha = [self valueFromExecutingString:@"rgba(10, 20, 30, 0.5).alpha"];

    XCTAssertTrue([@"rgba(10,20,30,0.5)" isEqualToString:color.description]);
    [self assertDoubleValue:red expected:10.0];
    [self assertDoubleValue:green expected:20.0];
    [self assertDoubleValue:blue expected:30.0];
    [self assertDoubleValue:alpha expected:0.5];
}

- (void)testHSBColorValue
{
    id<PXExpressionValue> color = [self valueFromExecutingString:@"hsb(180, 0.5, 0.25)"];
    id<PXExpressionValue> hue = [self valueFromExecutingString:@"hsb(180, 0.5, 0.25).hue"];
    id<PXExpressionValue> saturation = [self valueFromExecutingString:@"hsb(180, 0.5, 0.25).saturation"];
    id<PXExpressionValue> brightness = [self valueFromExecutingString:@"hsb(180, 0.5, 0.25).brightness"];
    id<PXExpressionValue> alpha = [self valueFromExecutingString:@"hsb(180, 0.5, 0.25).alpha"];

    XCTAssertTrue([@"hsba(180,0.5,0.25,1)" isEqualToString:color.description]);
    [self assertDoubleValue:hue expected:180.0];
    [self assertDoubleValue:saturation expected:0.5];
    [self assertDoubleValue:brightness expected:0.25];
    [self assertDoubleValue:alpha expected:1.0];
}

- (void)testHSBAColorValue
{
    id<PXExpressionValue> color = [self valueFromExecutingString:@"hsba(180, 0.5, 0.25, 0.5)"];
    id<PXExpressionValue> hue = [self valueFromExecutingString:@"hsba(180, 0.5, 0.25, 0.5).hue"];
    id<PXExpressionValue> saturation = [self valueFromExecutingString:@"hsba(180, 0.5, 0.25, 0.5).saturation"];
    id<PXExpressionValue> brightness = [self valueFromExecutingString:@"hsba(180, 0.5, 0.25, 0.5).brightness"];
    id<PXExpressionValue> alpha = [self valueFromExecutingString:@"hsba(180, 0.5, 0.25, 0.5).alpha"];

    XCTAssertTrue([@"hsba(180,0.5,0.25,0.5)" isEqualToString:color.description]);
    [self assertDoubleValue:hue expected:180.0];
    [self assertDoubleValue:saturation expected:0.5];
    [self assertDoubleValue:brightness expected:0.25];
    [self assertDoubleValue:alpha expected:0.5];
}

- (void)testHSLColorValue
{
    id<PXExpressionValue> color = [self valueFromExecutingString:@"hsl(180, 0.5, 0.25)"];
    id<PXExpressionValue> hue = [self valueFromExecutingString:@"hsl(180, 0.5, 0.25).hue"];
    id<PXExpressionValue> saturation = [self valueFromExecutingString:@"hsl(180, 0.5, 0.25).saturation"];
    id<PXExpressionValue> lightness = [self valueFromExecutingString:@"hsl(180, 0.5, 0.25).lightness"];
    id<PXExpressionValue> alpha = [self valueFromExecutingString:@"hsl(180, 0.5, 0.25).alpha"];

    XCTAssertTrue([@"hsla(180,0.5,0.25,1)" isEqualToString:color.description]);
    [self assertDoubleValue:hue expected:180.0];
    [self assertDoubleValue:saturation expected:0.5];
    [self assertDoubleValue:lightness expected:0.25];
    [self assertDoubleValue:alpha expected:1.0];
}

- (void)testHSLAColorValue
{
    id<PXExpressionValue> color = [self valueFromExecutingString:@"hsla(180, 0.5, 0.25, 0.5)"];
    id<PXExpressionValue> hue = [self valueFromExecutingString:@"hsla(180, 0.5, 0.25, 0.5).hue"];
    id<PXExpressionValue> saturation = [self valueFromExecutingString:@"hsla(180, 0.5, 0.25, 0.5).saturation"];
    id<PXExpressionValue> lightness = [self valueFromExecutingString:@"hsla(180, 0.5, 0.25, 0.5).lightness"];
    id<PXExpressionValue> alpha = [self valueFromExecutingString:@"hsla(180, 0.5, 0.25, 0.5).alpha"];

    XCTAssertTrue([@"hsla(180,0.5,0.25,0.5)" isEqualToString:color.description]);
    [self assertDoubleValue:hue expected:180.0];
    [self assertDoubleValue:saturation expected:0.5];
    [self assertDoubleValue:lightness expected:0.25];
    [self assertDoubleValue:alpha expected:0.5];
}

@end
