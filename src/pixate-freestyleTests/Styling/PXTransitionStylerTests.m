//
//  PXTransitionStylerTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/12/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PXTransitionStyler.h"

@interface PXTransitionStylerTests : XCTestCase
@end

@implementation PXTransitionStylerTests

- (void)testTransitionPropertyName
{
    PXTransitionStyler *styler = [[PXTransitionStyler alloc] init];
    PXStylerContext *context = [[PXStylerContext alloc] init];
    PXDeclaration *declaration = [[PXDeclaration alloc] initWithName:@"transition" value:@"myProperty"];

    [styler processDeclaration:declaration withContext:context];

    NSArray *infos = context.transitionInfos;
    XCTAssertTrue(infos.count == 1, @"Expected one animation, but found %d", infos.count);

    PXAnimationInfo *info = [infos objectAtIndex:0];
    XCTAssertTrue([@"myProperty" isEqualToString:info.animationName], @"Expected 'myAnimation' as animation name, but found '%@'", info.animationName);
}

- (void)testTransitionPropertyAll
{
    PXTransitionStyler *styler = [[PXTransitionStyler alloc] init];
    PXStylerContext *context = [[PXStylerContext alloc] init];
    PXDeclaration *declaration = [[PXDeclaration alloc] initWithName:@"transition" value:@"myProperty 1s linear 0s"];

    [styler processDeclaration:declaration withContext:context];

    NSArray *infos = context.transitionInfos;
    XCTAssertTrue(infos.count == 1, @"Expected one animation, but found %d", infos.count);

    PXAnimationInfo *info = [infos objectAtIndex:0];
    XCTAssertTrue([@"myProperty" isEqualToString:info.animationName], @"Expected 'myAnimation' as animation name, but found '%@'", info.animationName);
    XCTAssertTrue(info.animationDuration == 1.0f, @"Expected a 1s delay, but found %f", info.animationDuration);
    XCTAssertTrue(info.animationTimingFunction == PXAnimationTimingFunctionLinear, @"Expected timing function %d, but found %d", PXAnimationTimingFunctionLinear, info.animationTimingFunction);
}

@end
