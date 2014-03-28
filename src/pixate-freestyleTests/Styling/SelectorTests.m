//
//  SelectorTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/24/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "StyleableView.h"
#import "UIView+PXStyling.h"
#import "PXStyleable.h"
#import "PXTypeSelector.h"
#import "PXIdSelector.h"
#import "PXClassSelector.h"
#import "PXChildCombinator.h"
#import "PXDescendantCombinator.h"
#import "PXAdjacentSiblingCombinator.h"
#import "PXSiblingCombinator.h"
#import "NSMutableArray+QueueAdditions.h"
#import "PXPseudoClassFunction.h"

@interface SelectorTests : XCTestCase
@end

#pragma mark - Selector Tests class

@implementation SelectorTests

#pragma mark - Type Selector Tests

- (void)testElementSelectorMatch
{
    id<PXStyleable> element = [[StyleableView alloc] initWithElementName:@"test"];
    PXTypeSelector *expr = [[PXTypeSelector alloc] initWithTypeName:@"test"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by element name");
}

- (void)testElementSelectorNonMatch
{
    id<PXStyleable> element = [[StyleableView alloc] initWithElementName:@"test"];
    PXTypeSelector *expr = [[PXTypeSelector alloc] initWithTypeName:@"no-match"];

    XCTAssertFalse([expr matches:element], @"Expected element not to match by element name");
}

#pragma mark - ID Selector Tests

- (void)testIdSelectorMatch
{
    id<PXStyleable> element = [self newClassWithId:@"hello"];
    PXIdSelector *expr = [[PXIdSelector alloc] initWithIdValue:@"hello"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by id");
}

- (void)testIdSelectorMatch2
{
    id<PXStyleable> element = [self newClassWithId:@" hello"];
    PXIdSelector *expr = [[PXIdSelector alloc] initWithIdValue:@"hello"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by id");
}

- (void)testIdSelectorMatch3
{
    id<PXStyleable> element = [self newClassWithId:@"hello "];
    PXIdSelector *expr = [[PXIdSelector alloc] initWithIdValue:@"hello"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by id");
}

- (void)testIdSelectorMatch4
{
    id<PXStyleable> element = [self newClassWithId:@" hello "];
    PXIdSelector *expr = [[PXIdSelector alloc] initWithIdValue:@"hello"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by id");
}

- (void)testIdSelectorNonMatch
{
    id<PXStyleable> element = [self newClassWithId:@"hellos"];
    PXIdSelector *expr = [[PXIdSelector alloc] initWithIdValue:@"hello"];

    XCTAssertFalse([expr matches:element], @"Expected element not to match by id");
}

- (void)testIdSelectorNonMatch2
{
    id<PXStyleable> element = [self newClassWithId:@"shello"];
    PXIdSelector *expr = [[PXIdSelector alloc] initWithIdValue:@"hello"];

    XCTAssertFalse([expr matches:element], @"Expected element not to match by id");
}

- (void)testIdSelectorNonMatch3
{
    id<PXStyleable> element = [self newClassWithId:@""];
    PXIdSelector *expr = [[PXIdSelector alloc] initWithIdValue:@"hello"];

    XCTAssertFalse([expr matches:element], @"Expected element not to match by id");
}

- (void)testIdSelectorNonMatch4
{
    id<PXStyleable> element = [self newClassWithId:nil];
    PXIdSelector *expr = [[PXIdSelector alloc] initWithIdValue:@"hello"];

    XCTAssertFalse([expr matches:element], @"Expected element not to match by id");
}

#pragma mark - Class Selector Tests

- (void)testClassSelectorMatch
{
    id<PXStyleable> element = [self newClassWithClass:@"myclass"];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by class");
}

- (void)testClassSelectorMatch2
{
    id<PXStyleable> element = [self newClassWithClass:@"before myclass"];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by class");
}

- (void)testClassSelectorMatch3
{
    id<PXStyleable> element = [self newClassWithClass:@"myclass after"];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by class");
}

- (void)testClassSelectorMatch4
{
    id<PXStyleable> element = [self newClassWithClass:@"before myclass after"];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by class");
}

- (void)testClassSelectorMatch5
{
    id<PXStyleable> element = [self newClassWithClass:@" myclass"];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by class");
}

- (void)testClassSelectorMatch6
{
    id<PXStyleable> element = [self newClassWithClass:@"myclass "];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by class");
}

- (void)testClassSelectorMatch7
{
    id<PXStyleable> element = [self newClassWithClass:@" myclass "];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertTrue([expr matches:element], @"Expected element to match by class");
}

- (void)testClassSelectorNonMatch
{
    id<PXStyleable> element = [self newClassWithClass:@"myclasses"];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertFalse([expr matches:element], @"Expected element not to match by class");
}

- (void)testClassSelectorNonMatch2
{
    id<PXStyleable> element = [self newClassWithClass:@"before myclasses"];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertFalse([expr matches:element], @"Expected element not to match by class");
}

- (void)testClassSelectorNonMatch3
{
    id<PXStyleable> element = [self newClassWithClass:@"myclasses after"];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertFalse([expr matches:element], @"Expected element not to match by class");
}

- (void)testClassSelectorNonMatch4
{
    id<PXStyleable> element = [self newClassWithClass:@"before myclasses after"];
    PXClassSelector *expr = [[PXClassSelector alloc] initWithClassName:@"myclass"];

    XCTAssertFalse([expr matches:element], @"Expected element not to match by class");
}

#pragma mark - Child Combinator Tests

- (void)testChildCombinator
{
    // build tree
    StyleableView *root = [[StyleableView alloc] initWithElementName:@"root"];
    StyleableView *child = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *sibling = [[StyleableView alloc] initWithElementName:@"sibling"];
    StyleableView *grandchild = [[StyleableView alloc] initWithElementName:@"child"];

    [root addSubview:child];
    [root addSubview:sibling];
    [child addSubview:grandchild];

    // build selector
    PXTypeSelector *rootSelector = [[PXTypeSelector alloc] initWithTypeName:@"root"];
    PXTypeSelector *childSelector = [[PXTypeSelector alloc] initWithTypeName:@"child"];
    PXChildCombinator *selector = [[PXChildCombinator alloc] initWithLHS:rootSelector RHS:childSelector];

    // test
    [self assertMatches:@[child] onElement:root withSelector:selector];
}

#pragma mark - Descendant Combinator Tests

- (void)testDescendantCombinator
{
    // build tree
    StyleableView *root = [[StyleableView alloc] initWithElementName:@"root"];
    StyleableView *child = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *sibling = [[StyleableView alloc] initWithElementName:@"sibling"];
    StyleableView *grandchild = [[StyleableView alloc] initWithElementName:@"child"];

    [root addSubview:child];
    [root addSubview:sibling];
    [child addSubview:grandchild];

    // build selector
    PXTypeSelector *rootSelector = [[PXTypeSelector alloc] initWithTypeName:@"root"];
    PXTypeSelector *childSelector = [[PXTypeSelector alloc] initWithTypeName:@"child"];
    PXDescendantCombinator *selector = [[PXDescendantCombinator alloc] initWithLHS:rootSelector RHS:childSelector];

    // test
    [self assertMatches:@[child, grandchild] onElement:root withSelector:selector];
}

#pragma mark - Adjacent Sibling Combinator Tests

- (void)testAdjacentSiblingCombinator
{
    // build tree
    StyleableView *root = [[StyleableView alloc] initWithElementName:@"root"];
    StyleableView *child1 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *child2 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *sibling = [[StyleableView alloc] initWithElementName:@"sibling"];
    StyleableView *grandchild = [[StyleableView alloc] initWithElementName:@"child"];

    [root addSubview:child1];
    [root addSubview:child2];
    [root addSubview:sibling];
    [child1 addSubview:grandchild];

    // build selector
    PXTypeSelector *rootSelector = [[PXTypeSelector alloc] initWithTypeName:@"child"];
    PXTypeSelector *childSelector = [[PXTypeSelector alloc] initWithTypeName:@"child"];
    PXAdjacentSiblingCombinator *selector = [[PXAdjacentSiblingCombinator alloc] initWithLHS:rootSelector RHS:childSelector];

    // test
    [self assertMatches:@[child2] onElement:root withSelector:selector];
}

#pragma mark - General Sibling Combinator Tests

- (void)testSiblingCombinator
{
    // build tree
    StyleableView *root = [[StyleableView alloc] initWithElementName:@"root"];
    StyleableView *child1 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *child2 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *child3 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *sibling = [[StyleableView alloc] initWithElementName:@"sibling"];
    StyleableView *grandchild1 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *grandchild2 = [[StyleableView alloc] initWithElementName:@"child"];

    [root addSubview:child1];
    [root addSubview:child2];
    [root addSubview:child3];
    [root addSubview:sibling];
    [child1 addSubview:grandchild1];
    [child1 addSubview:grandchild2];

    // build selector
    PXTypeSelector *rootSelector = [[PXTypeSelector alloc] initWithTypeName:@"child"];
    PXTypeSelector *childSelector = [[PXTypeSelector alloc] initWithTypeName:@"child"];
    PXSiblingCombinator *selector = [[PXSiblingCombinator alloc] initWithLHS:rootSelector RHS:childSelector];

    // test
    [self assertMatches:@[child2, child3, grandchild2] onElement:root withSelector:selector];
}

#pragma mark - Nth-child tests

- (void)testSpecificNthChild
{
    StyleableView *root = [[StyleableView alloc] initWithElementName:@"root"];
    StyleableView *child1 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *child2 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *child3 = [[StyleableView alloc] initWithElementName:@"child"];

    [root addSubview:child1];
    [root addSubview:child2];
    [root addSubview:child3];

    // build selector
    PXTypeSelector *childSelector = [[PXTypeSelector alloc] initWithTypeName:@"child"];
    PXPseudoClassFunction *nthChild = [[PXPseudoClassFunction alloc] initWithFunctionType:PXPseudoClassFunctionNthChild modulus:1 remainder:2];
    [childSelector addAttributeExpression:nthChild];

    [self assertMatches:@[child2] onElement:root withSelector:childSelector];
}

- (void)testSpecificNthChildOfType
{
    StyleableView *root = [[StyleableView alloc] initWithElementName:@"root"];
    StyleableView *child1 = [[StyleableView alloc] initWithElementName:@"child1"];
    StyleableView *child2 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *child3 = [[StyleableView alloc] initWithElementName:@"child"];

    [root addSubview:child1];
    [root addSubview:child2];
    [root addSubview:child3];

    // build selector
    PXTypeSelector *childSelector = [[PXTypeSelector alloc] initWithTypeName:@"child"];
    PXPseudoClassFunction *nthChild = [[PXPseudoClassFunction alloc] initWithFunctionType:PXPseudoClassFunctionNthOfType modulus:1 remainder:2];
    [childSelector addAttributeExpression:nthChild];

    [self assertMatches:@[child3] onElement:root withSelector:childSelector];
}

- (void)testSpecificNthLastChild
{
    StyleableView *root = [[StyleableView alloc] initWithElementName:@"root"];
    StyleableView *child1 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *child2 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *child3 = [[StyleableView alloc] initWithElementName:@"child"];

    [root addSubview:child1];
    [root addSubview:child2];
    [root addSubview:child3];

    // build selector
    PXTypeSelector *childSelector = [[PXTypeSelector alloc] initWithTypeName:@"child"];
    PXPseudoClassFunction *nthChild = [[PXPseudoClassFunction alloc] initWithFunctionType:PXPseudoClassFunctionNthLastChild modulus:1 remainder:2];
    [childSelector addAttributeExpression:nthChild];

    [self assertMatches:@[child2] onElement:root withSelector:childSelector];
}

- (void)testSpecificNthLastChildOfType
{
    StyleableView *root = [[StyleableView alloc] initWithElementName:@"root"];
    StyleableView *child1 = [[StyleableView alloc] initWithElementName:@"child1"];
    StyleableView *child2 = [[StyleableView alloc] initWithElementName:@"child"];
    StyleableView *child3 = [[StyleableView alloc] initWithElementName:@"child"];

    [root addSubview:child1];
    [root addSubview:child2];
    [root addSubview:child3];

    // build selector
    PXTypeSelector *childSelector = [[PXTypeSelector alloc] initWithTypeName:@"child"];
    PXPseudoClassFunction *nthChild = [[PXPseudoClassFunction alloc] initWithFunctionType:PXPseudoClassFunctionNthLastOfType modulus:1 remainder:2];
    [childSelector addAttributeExpression:nthChild];

    [self assertMatches:@[child2] onElement:root withSelector:childSelector];
}

#pragma mark - Helper methods

- (void)assertMatches:(NSArray *)expectedMatches onElement:(id<PXStyleable>)element withSelector:(id<PXSelector>)selector
{
    NSArray *elements = [self descendantsAndSelf:element];
    NSMutableArray *actualMatches = [NSMutableArray array];

    for (id<PXStyleable> candidate in elements)
    {
        if ([selector matches:candidate])
        {
            [actualMatches addObject:candidate];
        }
    }

    XCTAssertEqual(expectedMatches.count, actualMatches.count, @"Expected %lu matches but found %lu", (unsigned long)expectedMatches.count, (unsigned long)actualMatches.count);

    if (expectedMatches.count == actualMatches.count)
    {
        for (id<PXStyleable> expectedMatch in expectedMatches)
        {
            NSUInteger index = [actualMatches indexOfObject:expectedMatch];

            if (index == NSNotFound)
            {
                XCTFail(@"Did not find %@ in matched elements", expectedMatch.pxStyleElementName);
            }
        }
    }
}

- (NSArray *)descendantsAndSelf:(id<PXStyleable>)element
{
    NSMutableArray *elements = [NSMutableArray array];
    NSMutableArray *result = [NSMutableArray array];

    [elements enqueue:element];

    while (elements.count > 0)
    {
        id<PXStyleable> element = [elements dequeue];

        if ([element conformsToProtocol:@protocol(PXStyleable)])
        {
            [result addObject:element];
        }

        for (id child in element.pxStyleChildren)
        {
            [elements enqueue:child];
        }
    }

    return [NSArray arrayWithArray:result];
}

- (StyleableView *)newClassWithId:(NSString *)identifer;
{
    StyleableView *result = [[StyleableView alloc] initWithElementName:@"test"];

    result.styleId = identifer;

    return result;
}

- (StyleableView *)newClassWithClass:(NSString *)class;
{
    StyleableView *result = [[StyleableView alloc] initWithElementName:@"test"];

    result.styleClass = class;

    return result;
}

@end
