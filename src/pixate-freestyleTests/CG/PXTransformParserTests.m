//
//  PXTransformParserTests.m
//  PXShapeKit
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXTransformParser.h"
#import <XCTest/XCTest.h>
#import "PXMath.h"

@interface PXTransformParserTests : XCTestCase

@end

@implementation PXTransformParserTests
{
    PXTransformParser *parser;
}

- (void)setUp
{
    [super setUp];

    parser = [[PXTransformParser alloc] init];
}

- (void)tearDown
{
    parser = nil;

    [super tearDown];
}

- (void)assertTransform:(CGAffineTransform)transform withSource:(NSString *)source
{
    CGAffineTransform result = [parser parse:source];

    XCTAssertTrue(CGAffineTransformEqualToTransform(result, transform), @"transforms do not match");
}

- (void)testTranslate
{
    [self assertTransform:CGAffineTransformMakeTranslation(10.0f, 20.0f) withSource:@"translate(10, 20)"];
}

- (void)testTranslate2
{
    [self assertTransform:CGAffineTransformMakeTranslation(10.0f, 0.0f) withSource:@"translate(10)"];
}

- (void)testTranslate3
{
    CGFloat tx = 1.0f * 72.0f;
    CGFloat ty = 0.5f * 72.0f;

    [self assertTransform:CGAffineTransformMakeTranslation(tx, ty) withSource:@"translate(1in,0.5in)"];
}

- (void)testTranslateX
{
    [self assertTransform:CGAffineTransformMakeTranslation(10.0f, 0.0f) withSource:@"translateX(10)"];
}

- (void)testTranslateX2
{
    CGFloat tx = 1.0f * 72.0f;

    [self assertTransform:CGAffineTransformMakeTranslation(tx, 0.0f) withSource:@"translateX(1in)"];
}

- (void)testTranslateY
{
    [self assertTransform:CGAffineTransformMakeTranslation(0.0f, 20.0f) withSource:@"translateY(20)"];
}

- (void)testTranslateY2
{
    CGFloat ty = 0.5f * 72.0f;

    [self assertTransform:CGAffineTransformMakeTranslation(0.0f, ty) withSource:@"translateY(0.5in)"];
}

- (void)testScale
{
    [self assertTransform:CGAffineTransformMakeScale(10.0f, 20.0f) withSource:@"scale(10, 20)"];
}

- (void)testScale2
{
    [self assertTransform:CGAffineTransformMakeScale(10.0f, 10.0f) withSource:@"scale(10)"];
}

- (void)testScaleX
{
    [self assertTransform:CGAffineTransformMakeScale(10.0f, 1.0f) withSource:@"scaleX(10)"];
}

- (void)testScaleY
{
    [self assertTransform:CGAffineTransformMakeScale(1.0f, 20.0f) withSource:@"scaleY(20)"];
}

- (void)testRotate
{
    CGFloat angle = DEGREES_TO_RADIANS(45);

    [self assertTransform:CGAffineTransformMakeRotation(angle) withSource:@"rotate(45)"];
}

- (void)testRotate2
{
    CGFloat angle = DEGREES_TO_RADIANS(45.0f);
    CGFloat x = 10.0f;
    CGFloat y = 20.0f;

    CGAffineTransform result = CGAffineTransformMakeTranslation(x, y);
    result = CGAffineTransformRotate(result, angle);
    result = CGAffineTransformTranslate(result, -x, -y);

    [self assertTransform:result withSource:@"rotate(45,10,20)"];
}

- (void)testRotate3
{
    CGFloat angle = DEGREES_TO_RADIANS(45);

    [self assertTransform:CGAffineTransformMakeRotation(angle) withSource:@"rotate(45deg)"];
}

- (void)testRotate4
{
    CGFloat angle = 1.0f;

    [self assertTransform:CGAffineTransformMakeRotation(angle) withSource:@"rotate(1rad)"];
}

- (void)testSkew
{
    CGFloat sx = TAN(DEGREES_TO_RADIANS(10.0f));
    CGFloat sy = TAN(DEGREES_TO_RADIANS(20.0f));

    [self assertTransform:CGAffineTransformMake(1.0f, sy, sx, 1.0f, 0.0f, 0.0f) withSource:@"skew(10, 20)"];
}

- (void)testSkew2
{
    CGFloat sx = TAN(1.0f);
    CGFloat sy = TAN(2.0f);

    [self assertTransform:CGAffineTransformMake(1.0f, sy, sx, 1.0f, 0.0f, 0.0f) withSource:@"skew(1rad, 2rad)"];
}

- (void)testSkewX
{
    CGFloat sx = TAN(DEGREES_TO_RADIANS(10.0f));
    CGFloat sy = 0.0f;

    [self assertTransform:CGAffineTransformMake(1.0f, sy, sx, 1.0f, 0.0f, 0.0f) withSource:@"skewX(10)"];
}

- (void)testSkewX2
{
    CGFloat sx = TAN(1.0f);
    CGFloat sy = 0.0f;

    [self assertTransform:CGAffineTransformMake(1.0f, sy, sx, 1.0f, 0.0f, 0.0f) withSource:@"skewX(1rad)"];
}

- (void)testSkewY
{
    CGFloat sx = 0.0f;
    CGFloat sy = TAN(DEGREES_TO_RADIANS(20.0f));

    [self assertTransform:CGAffineTransformMake(1.0f, sy, sx, 1.0f, 0.0f, 0.0f) withSource:@"skewY(20)"];
}

- (void)testSkewY2
{
    CGFloat sx = 0.0f;
    CGFloat sy = TAN(2.0f);

    [self assertTransform:CGAffineTransformMake(1.0f, sy, sx, 1.0f, 0.0f, 0.0f) withSource:@"skewY(2rad)"];
}

@end
