//
//  PXAnimationStylerTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/12/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PXAnimationStyler.h"

@interface PXAnimationStylerTests : XCTestCase
@end

@implementation PXAnimationStylerTests

- (void)testAnimationPropertyName
{
    PXAnimationStyler *styler = [[PXAnimationStyler alloc] init];
    PXStylerContext *context = [[PXStylerContext alloc] init];
    PXDeclaration *declaration = [[PXDeclaration alloc] initWithName:@"animation" value:@"myAnimation"];

    [styler processDeclaration:declaration withContext:context];

    NSArray *infos = context.animationInfos;
    XCTAssertTrue(infos.count == 1, @"Expected one animation, but found %lu", (unsigned long)infos.count);

    PXAnimationInfo *info = [infos objectAtIndex:0];
    XCTAssertTrue([@"myAnimation" isEqualToString:info.animationName], @"Expected 'myAnimation' as animation name, but found '%@'", info.animationName);
}

- (void)testAnimationPropertyAll
{
    PXAnimationStyler *styler = [[PXAnimationStyler alloc] init];
    PXStylerContext *context = [[PXStylerContext alloc] init];
    PXDeclaration *declaration = [[PXDeclaration alloc] initWithName:@"animation" value:@"myAnimation 1s linear 0s 10 normal none running"];

    [styler processDeclaration:declaration withContext:context];

    NSArray *infos = context.animationInfos;
    XCTAssertTrue(infos.count == 1, @"Expected one animation, but found %lu", (unsigned long)infos.count);

    PXAnimationInfo *info = [infos objectAtIndex:0];
    XCTAssertTrue([@"myAnimation" isEqualToString:info.animationName], @"Expected 'myAnimation' as animation name, but found '%@'", info.animationName);
    XCTAssertTrue(info.animationDuration == 1.0f, @"Expected a 1s delay, but found %f", info.animationDuration);
    XCTAssertTrue(info.animationTimingFunction == PXAnimationTimingFunctionLinear, @"Expected timing function %d, but found %d", PXAnimationTimingFunctionLinear, info.animationTimingFunction);
    XCTAssertTrue(info.animationIterationCount == 10, @"Expected 10 iterations, but found %lu", (unsigned long)info.animationIterationCount);
    XCTAssertTrue(info.animationDirection == PXAnimationDirectionNormal, @"Expected direction %d, but found %d", PXAnimationDirectionNormal, info.animationDirection);
    XCTAssertTrue(info.animationFillMode == PXAnimationFillModeNone, @"Expected fill mode %d, but found %d", PXAnimationFillModeNone, info.animationFillMode);
    XCTAssertTrue(info.animationPlayState == PXAnimationPlayStateRunning, @"Expected play state %d, but found %d", PXAnimationPlayStateRunning, info.animationPlayState);
}

@end
