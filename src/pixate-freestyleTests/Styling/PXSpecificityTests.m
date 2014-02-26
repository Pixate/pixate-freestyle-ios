//
//  PXSpecificityTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/28/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXRuleSet.h"
#import "PXStylesheetParser.h"
#import <XCTest/XCTest.h>
#import "PXStylesheet.h"

@interface PXSpecificityTests : XCTestCase

@end

@implementation PXSpecificityTests

#pragma mark - CSS Specification Examples

- (void)testAnyTypeSelector
{
    NSString *source = @"* {}";
    PXRuleSet *ruleSet = [self ruleSetFromSource:source];

    XCTAssertEqualObjects(@"(1,0,0,0)", ruleSet.specificity.description, @"specificities do not match");
}

- (void)testTypeSelector
{
    NSString *source = @"li {}";
    PXRuleSet *ruleSet = [self ruleSetFromSource:source];

    XCTAssertEqualObjects(@"(1,0,0,1)", ruleSet.specificity.description, @"specificities do not match");
}

- (void)testTypeSelectorAndPseudoElement
{
    NSString *source = @"li:first-line {}";
    PXRuleSet *ruleSet = [self ruleSetFromSource:source];

    XCTAssertEqualObjects(@"(1,0,0,2)", ruleSet.specificity.description, @"specificities do not match");
}

- (void)testTypeSelectors
{
    NSString *source = @"ul li {}";
    PXRuleSet *ruleSet = [self ruleSetFromSource:source];

    XCTAssertEqualObjects(@"(1,0,0,2)", ruleSet.specificity.description, @"specificities do not match");
}

- (void)testTypeSelectorAndChildCombinator
{
    NSString *source = @"ul ol+li {}";
    PXRuleSet *ruleSet = [self ruleSetFromSource:source];

    XCTAssertEqualObjects(@"(1,0,0,3)", ruleSet.specificity.description, @"specificities do not match");
}

- (void)testTypeSelectorChildCombinatorAndAttributeExpression
{
    NSString *source = @"h1 + *[rel=up] {}";
    PXRuleSet *ruleSet = [self ruleSetFromSource:source];

    XCTAssertEqualObjects(@"(1,0,1,1)", ruleSet.specificity.description, @"specificities do not match");
}

- (void)testTypeSelectorsAndClassExpression
{
    NSString *source = @"uo ol li.red {}";
    PXRuleSet *ruleSet = [self ruleSetFromSource:source];


    XCTAssertEqualObjects(@"(1,0,1,3)", ruleSet.specificity.description, @"specificities do not match");
}

- (void)testTypeSelectorAndClassExpressions
{
    NSString *source = @"li.red.level {}";
    PXRuleSet *ruleSet = [self ruleSetFromSource:source];

    XCTAssertEqualObjects(@"(1,0,2,1)", ruleSet.specificity.description, @"specificities do not match");
}

- (void)testIdExpression
{
    NSString *source = @"#x34y {}";
    PXRuleSet *ruleSet = [self ruleSetFromSource:source];

    XCTAssertEqualObjects(@"(1,1,0,0)", ruleSet.specificity.description, @"specificities do not match");
}

#pragma mark - Helper Methods

- (PXRuleSet *)ruleSetFromSource:(NSString *)source
{
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginUser];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    return [ruleSets objectAtIndex:0];
}

@end
