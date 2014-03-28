//
//  PXStylesheetParserTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/12/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PXStylesheetParser.h"
#import "PXStylesheet.h"
#import "PXMediaGroup.h"
#import "PXNamedMediaExpression.h"
#import "PXMediaExpressionGroup.h"
#import "PXKeyframeBlock.h"
#import "PXLinearGradient.h"

@interface PXStylesheetParserTests : XCTestCase

@end

@implementation PXStylesheetParserTests

// TODO: Write assertStyleSheet method to remove code duplication in these tests

- (void)testSimpleDeclaration
{
    NSString *source = @"button { abc: def }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse errors encountered");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *declarations = ruleSet.declarations;
    XCTAssertTrue(declarations.count == 1, @"Expected a single declaration");

    PXDeclaration *declaration = [declarations objectAtIndex:0];
    XCTAssertEqualObjects(@"abc", declaration.name, @"Expected 'abc' declaration");
}

- (void)testSimpleDeclarations
{
    NSString *source = @"button { abc: def; ghi: jkl }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse errors encountered");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *declarations = ruleSet.declarations;
    XCTAssertTrue(declarations.count == 2, @"Expected two declarations");

    PXDeclaration *declaration = [declarations objectAtIndex:0];
    XCTAssertEqualObjects(@"abc", declaration.name, @"Expected 'abc' declaration");

    declaration = [declarations objectAtIndex:1];
    XCTAssertEqualObjects(@"ghi", declaration.name, @"Expected 'abc' declaration");
}

- (void)testSimpleDeclarationsMissingSemicolon
{
    NSString *source = @"button { abc: def ghi: jkl }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse errors encountered");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *declarations = ruleSet.declarations;
    XCTAssertTrue(declarations.count == 2, @"Expected two declarations");

    PXDeclaration *declaration = [declarations objectAtIndex:0];
    XCTAssertEqualObjects(@"abc", declaration.name, @"Expected 'abc' declaration");

    declaration = [declarations objectAtIndex:1];
    XCTAssertEqualObjects(@"ghi", declaration.name, @"Expected 'abc' declaration");
}

- (void)testMissingSelector
{
    NSString *source = @"{ abc: def }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 1, @"Expected one parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *declarations = ruleSet.declarations;
    XCTAssertTrue(declarations.count == 1, @"Expected one declaration");

    PXDeclaration *declaration = [declarations objectAtIndex:0];
    XCTAssertEqualObjects(@"abc", declaration.name, @"Expected 'abc' declaration");
}

- (void)testBadDeclarationName
{
    NSString *source = @"button { 10: def; ghi: jkl }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 1, @"Expected one parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *declarations = ruleSet.declarations;
    XCTAssertTrue(declarations.count == 1, @"Expected one declaration");

    PXDeclaration *declaration = [declarations objectAtIndex:0];
    XCTAssertEqualObjects(@"ghi", declaration.name, @"Expected 'ghi' declaration");
}

- (void)testColonInValue
{
    NSString *source = @"button { abc: :; }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *declarations = ruleSet.declarations;
    XCTAssertTrue(declarations.count == 1, @"Expected one declaration");

    PXDeclaration *declaration = [declarations objectAtIndex:0];
    XCTAssertEqualObjects(@"abc", declaration.name, @"Expected 'ghi' declaration");
}

#pragma mark - Selector Tests

- (void)testTypeSelector
{
    NSString *source = @"button {}";
    NSString *expected = @"(button)";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");

    id<PXSelector> selector = [selectors objectAtIndex:0];

    XCTAssertEqualObjects(expected, selector.source, @"Selector trees do not match:\nexpected = %@\nactual = %@", expected, selector.source);
}

- (void)testAdjacentSiblingCombinator
{
    NSString *source = @"view + button {}";
    NSString *expected =
        @"(ADJACENT_SIBLING_COMBINATOR\n"
        "  (view)\n"
        "  (button))";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");

    id<PXSelector> selector = [selectors objectAtIndex:0];

    XCTAssertEqualObjects(expected, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected, selector.source);
}

- (void)testSiblingCombinator
{
    NSString *source = @"view ~ button {}";
    NSString *expected =
    @"(GENERAL_SIBLING_COMBINATOR\n"
    "  (view)\n"
    "  (button))";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");

    id<PXSelector> selector = [selectors objectAtIndex:0];

    XCTAssertEqualObjects(expected, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected, selector.source);
}

- (void)testChildCombinator
{
    NSString *source = @"view > button {}";
    NSString *expected =
    @"(CHILD_COMBINATOR\n"
    "  (view)\n"
    "  (button))";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");

    id<PXSelector> selector = [selectors objectAtIndex:0];

    XCTAssertEqualObjects(expected, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected, selector.source);
}

- (void)testDescendantCombinator
{
    NSString *source = @"view button {}";
    NSString *expected =
    @"(DESCENDANT_COMBINATOR\n"
    "  (view)\n"
    "  (button))";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");

    id<PXSelector> selector = [selectors objectAtIndex:0];

    XCTAssertEqualObjects(expected, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected, selector.source);
}

- (void)testDescendantCombinator2
{
    NSString *source = @"view button label {}";
    NSString *expected =
    @"(DESCENDANT_COMBINATOR\n"
    "  (DESCENDANT_COMBINATOR\n"
    "    (view)\n"
    "    (button))\n"
    "  (label))";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");

    id<PXSelector> selector = [selectors objectAtIndex:0];

    XCTAssertEqualObjects(expected, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected, selector.source);
}

- (void)testDescendantCombinator3
{
    NSString *source = @".t1 :only-of-type {}";
    NSString *expected =
    @"(DESCENDANT_COMBINATOR\n"
    "  (*\n"
    "    (CLASS t1))\n"
    "  (*\n"
    "    (PSEUDO_CLASS_PREDICATE :only-of-type)))";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected a single rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");

    id<PXSelector> selector = [selectors objectAtIndex:0];

    XCTAssertEqualObjects(expected, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected, selector.source);
}

- (void)testSelectorSequence
{
    NSString *source = @"button, slider {}";
    NSString *expected1 = @"(button)";
    NSString *expected2 = @"(slider)";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 2, @"Expected two rule sets");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");
    id<PXSelector> selector = [selectors objectAtIndex:0];
    XCTAssertEqualObjects(expected1, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected1, selector.source);

    ruleSet = [ruleSets objectAtIndex:1];
    selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");
    selector = [selectors objectAtIndex:0];
    XCTAssertEqualObjects(expected2, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected2, selector.source);
}

- (void)testPseudoElement
{
    // NOTE: we don't place psuedo-elements in the tree yet
    NSString *source = @"button::before {}";
    NSString *expected =
    @"(button\n"
    "  (PSEUDO_ELEMENT before))";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected one rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");
    id<PXSelector> selector = [selectors objectAtIndex:0];
    XCTAssertEqualObjects(expected, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected, selector.source);
}

- (void)testPseudoElements
{
    // NOTE: we don't place psuedo-elements in the tree yet
    NSString *source = @"button::before, slider::before {}";
    NSString *expected1 =
    @"(button\n"
    "  (PSEUDO_ELEMENT before))";
    NSString *expected2 =
    @"(slider\n"
    "  (PSEUDO_ELEMENT before))";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 2, @"Expected two rule sets");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");
    id<PXSelector> selector = [selectors objectAtIndex:0];
    XCTAssertEqualObjects(expected1, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected1, selector.source);

    ruleSet = [ruleSets objectAtIndex:1];
    selectors = ruleSet.selectors;
    XCTAssertTrue(selectors.count == 1, @"Expected one selector");
    selector = [selectors objectAtIndex:0];
    XCTAssertEqualObjects(expected2, selector.source, @"Selector trees do not match:\nexpected = \n%@\nactual = \n%@", expected2, selector.source);
}

#pragma mark - At-keyword Tests

- (void)testDefaultNamespace
{
    NSString *url = @"http://www.pixate.com";
    NSString *source = [NSString stringWithFormat:@"@namespace \"%@\";", url];

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSString *defaultNamespace = [stylesheet namespaceForPrefix:nil];
    XCTAssertTrue([url isEqualToString:defaultNamespace], @"Default namespace, '%@', does not equal '%@'", defaultNamespace, url);
}

- (void)testNamespacePrefix
{
    NSString *prefix = @"px";
    NSString *url = @"http://www.pixate.com";
    NSString *source = [NSString stringWithFormat:@"@namespace %@ \"%@\";", prefix, url];

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSString *prefixNamespace = [stylesheet namespaceForPrefix:prefix];
    XCTAssertTrue([url isEqualToString:prefixNamespace], @"'%@' prefix namespace, '%@', does not equal '%@'", prefix, prefixNamespace, url);
}

#pragma mark - Failures from W3C Selector tests

- (void)testNot
{
    NSString *source = @"div.test *:not(a|p) { background-color : lime }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    /*PXStylesheet *stylesheet =*/ [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Found %lu unexpected parse error(s): %@", (unsigned long)errors.count, [errors componentsJoinedByString:@"\n"]);
}

- (void)testNthOfType
{
    NSString *source = @"line:nth-of-type(odd) { background: lime; }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    /*PXStylesheet *stylesheet =*/ [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Found %lu unexpected parse error(s): %@", (unsigned long)errors.count, [errors componentsJoinedByString:@"\n"]);
}

- (void)testNthChildWithoutSpaces
{
    NSString *source = @"line:nth-child(2n+1) { background: red; }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    /*PXStylesheet *stylesheet =*/ [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Found %lu unexpected parse error(s): %@", (unsigned long)errors.count, [errors componentsJoinedByString:@"\n"]);
}

- (void)testNthChildWithoutSpaces2
{
    NSString *source = @"line:nth-child(2n-1) { background: red; }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    /*PXStylesheet *stylesheet =*/ [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Found %lu unexpected parse error(s): %@", (unsigned long)errors.count, [errors componentsJoinedByString:@"\n"]);
}

- (void)testNthChildWithSpaces
{
    NSString *source = @"line:nth-child(2n + 1) { background: red; }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    /*PXStylesheet *stylesheet =*/ [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Found %lu unexpected parse error(s): %@", (unsigned long)errors.count, [errors componentsJoinedByString:@"\n"]);
}

- (void)testNthLastChild
{
    NSString *source = @"line:nth-last-child(n) { background: red; }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    /*PXStylesheet *stylesheet =*/ [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Found %lu unexpected parse error(s): %@", (unsigned long)errors.count, [errors componentsJoinedByString:@"\n"]);
}

- (void)testNthLastOfType
{
    NSString *source = @"line:nth-last-of-type(1) { background: red; }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    /*PXStylesheet *stylesheet =*/ [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Found %lu unexpected parse error(s): %@", (unsigned long)errors.count, [errors componentsJoinedByString:@"\n"]);
}

- (void)testImportant
{
    NSString *source = @"* { background: red !important; }";

    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected two rule sets");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    NSArray *declarations = ruleSet.declarations;
    XCTAssertTrue(declarations.count == 1, @"Expected one declaration");
    PXDeclaration *declaration = [declarations objectAtIndex:0];
    XCTAssertTrue(declaration.important, @"declaration should be marked as important");

    NSString *stringValue = declaration.stringValue;
    NSString *expectedValue = @"red";
    XCTAssertTrue([stringValue isEqualToString:expectedValue], @"declaration string value does not match: '%@' != '%@'", stringValue, expectedValue);
}

- (void)testImportWithString
{
    NSString *source = @"@import \"test.css\";";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    /*PXStylesheet *stylesheet =*/ [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Found %lu unexpected parse error(s): %@", (unsigned long)errors.count, [errors componentsJoinedByString:@"\n"]);
}

- (void)testImportWithURL
{
    NSString *source = @"@import url(test.css);";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    /*PXStylesheet *stylesheet =*/ [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Found %lu unexpected parse error(s): %@", (unsigned long)errors.count, [errors componentsJoinedByString:@"\n"]);
}

#pragma mark - Keyframes Tests

- (void)testEmptyKeyframes
{
    NSString *source = @"@keyframes test {}";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    PXKeyframe *keyframe = [stylesheet keyframeForName:@"test"];
    XCTAssertNotNil(keyframe, @"Expected a 'test' keyframe to be defined in the stylesheet");

    NSArray *blocks = keyframe.blocks;
    XCTAssertTrue(blocks.count == 0, @"Expected no keyframe blocks but found %lu", (unsigned long)blocks.count);
}

- (void)testKeyframesWithTo
{
    NSString *source = @"@keyframes test { to { color: blue; } }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    PXKeyframe *keyframe = [stylesheet keyframeForName:@"test"];
    XCTAssertNotNil(keyframe, @"Expected a 'test' keyframe to be defined in the stylesheet");

    NSArray *blocks = keyframe.blocks;
    XCTAssertTrue(blocks.count == 1, @"Expected 1 keyframe block but found %lu", (unsigned long)blocks.count);

    PXKeyframeBlock *block = [blocks objectAtIndex:0];
    XCTAssertTrue(block.offset == 1.0f, @"Expected offset to be 1.0, but found %f", block.offset);
    XCTAssertTrue(block.declarations.count == 1, @"Expected 1 declaration but found %lu", (unsigned long)block.declarations.count);
}

- (void)testKeyframesWithFrom
{
    NSString *source = @"@keyframes test { from { color: blue; } }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    PXKeyframe *keyframe = [stylesheet keyframeForName:@"test"];
    XCTAssertNotNil(keyframe, @"Expected a 'test' keyframe to be defined in the stylesheet");

    NSArray *blocks = keyframe.blocks;
    XCTAssertTrue(blocks.count == 1, @"Expected 1 keyframe block but found %lu", (unsigned long)blocks.count);

    PXKeyframeBlock *block = [blocks objectAtIndex:0];
    XCTAssertTrue(block.offset == 0.0f, @"Expected offset to be 0.0, but found %f", block.offset);
    XCTAssertTrue(block.declarations.count == 1, @"Expected 1 declaration but found %lu", (unsigned long)block.declarations.count);
}

- (void)testKeyframesWithPercentage
{
    NSString *source = @"@keyframes test { 50% { color: blue; } }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    PXKeyframe *keyframe = [stylesheet keyframeForName:@"test"];
    XCTAssertNotNil(keyframe, @"Expected a 'test' keyframe to be defined in the stylesheet");

    NSArray *blocks = keyframe.blocks;
    XCTAssertTrue(blocks.count == 1, @"Expected 1 keyframe block but found %lu", (unsigned long)blocks.count);

    PXKeyframeBlock *block = [blocks objectAtIndex:0];
    XCTAssertTrue(block.offset == 0.5f, @"Expected offset to be 0.5, but found %f", block.offset);
    XCTAssertTrue(block.declarations.count == 1, @"Expected 1 declaration but found %lu", (unsigned long)block.declarations.count);
}

- (void)testKeyframesWithMultipleBlocks
{
    NSString *source = @"@keyframes test { from { color: red; } 50% { color: blue; } to { color: green; } }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    PXKeyframe *keyframe = [stylesheet keyframeForName:@"test"];
    XCTAssertNotNil(keyframe, @"Expected a 'test' keyframe to be defined in the stylesheet");

    NSArray *blocks = keyframe.blocks;
    XCTAssertTrue(blocks.count == 3, @"Expected 3 keyframe blocks but found %lu", (unsigned long)blocks.count);

    PXKeyframeBlock *block = [blocks objectAtIndex:0];
    XCTAssertTrue(block.offset == 0.0f, @"Expected offset to be 0.0, but found %f", block.offset);
    XCTAssertTrue(block.declarations.count == 1, @"Expected 1 declaration but found %lu", (unsigned long)block.declarations.count);

    block = [blocks objectAtIndex:1];
    XCTAssertTrue(block.offset == 0.5f, @"Expected offset to be 0.5, but found %f", block.offset);
    XCTAssertTrue(block.declarations.count == 1, @"Expected 1 declaration but found %lu", (unsigned long)block.declarations.count);

    block = [blocks objectAtIndex:2];
    XCTAssertTrue(block.offset == 1.0f, @"Expected offset to be 1.0, but found %f", block.offset);
    XCTAssertTrue(block.declarations.count == 1, @"Expected 1 declaration but found %lu", (unsigned long)block.declarations.count);
}

- (void)testKeyframesWithMultipleOffsets
{
    NSString *source = @"@keyframes test { from, to { color: red; } }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    PXKeyframe *keyframe = [stylesheet keyframeForName:@"test"];
    XCTAssertNotNil(keyframe, @"Expected a 'test' keyframe to be defined in the stylesheet");

    NSArray *blocks = keyframe.blocks;
    XCTAssertTrue(blocks.count == 2, @"Expected 2 keyframe blocks but found %lu", (unsigned long)blocks.count);

    PXKeyframeBlock *block = [blocks objectAtIndex:0];
    XCTAssertTrue(block.offset == 0.0f, @"Expected offset to be 0.0, but found %f", block.offset);
    XCTAssertTrue(block.declarations.count == 1, @"Expected 1 declaration but found %lu", (unsigned long)block.declarations.count);

    block = [blocks objectAtIndex:1];
    XCTAssertTrue(block.offset == 1.0f, @"Expected offset to be 1.0, but found %f", block.offset);
    XCTAssertTrue(block.declarations.count == 1, @"Expected 1 declaration but found %lu", (unsigned long)block.declarations.count);
}

#pragma mark - @media Tests

- (void)testMediaQuery
{
    NSString *source = @"@media (orientation:portrait) { button { background-color: red; } }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *mediaGroups = stylesheet.mediaGroups;
    XCTAssertTrue(mediaGroups.count == 1, @"Expected one media group");

    // check expressions
    PXMediaGroup *mediaGroup = [mediaGroups objectAtIndex:0];
    PXNamedMediaExpression *expression = mediaGroup.query;
    XCTAssertTrue([@"orientation" isEqualToString:expression.name], @"Expected name to be 'orientation'");
    XCTAssertTrue([@"portrait" isEqualToString:expression.value], @"Expected value to be 'portrait'");

    // check rule sets
    NSArray *ruleSets = mediaGroup.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected one rule set");
}

- (void)testMediaQueries
{
    NSString *source = @"@media (orientation:portrait) and (min-device-width:100) { button { background-color: red; } }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *mediaGroups = stylesheet.mediaGroups;
    XCTAssertTrue(mediaGroups.count == 1, @"Expected one media group");

    // check expressions
    PXMediaGroup *mediaGroup = [mediaGroups objectAtIndex:0];
    PXMediaExpressionGroup *expressionGroup = mediaGroup.query;
    NSArray *expressions = expressionGroup.expressions;
    XCTAssertTrue(expressions.count == 2, @"Expected two query expressions");

    PXNamedMediaExpression *expression = [expressions objectAtIndex:0];
    XCTAssertTrue([@"orientation" isEqualToString:expression.name], @"Expected name to be 'orientation'");
    XCTAssertTrue([@"portrait" isEqualToString:expression.value], @"Expected value to be 'portrait'");

    expression = [expressions objectAtIndex:1];
    XCTAssertTrue([@"min-device-width" isEqualToString:expression.name], @"Expected name to be 'orientation'");
    XCTAssertTrue([@(100) isEqual:expression.value], @"Expected value to be 100");

    // check rule sets
    NSArray *ruleSets = mediaGroup.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected one rule set");
}

- (void)testNoMediaQuery
{
    NSString *source = @"button { background-color: red; }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *mediaGroups = stylesheet.mediaGroups;
    XCTAssertTrue(mediaGroups.count == 1, @"Expected one media group");

    // check expressions
    PXMediaGroup *mediaGroup = [mediaGroups objectAtIndex:0];
    PXNamedMediaExpression *expression = mediaGroup.query;
    XCTAssertNil(expression, @"Expected the media group query to be nil");

    // check rule sets
    NSArray *ruleSets = mediaGroup.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected one rule set");
}

- (void)testMediaWithLeadingAnd
{
    NSString *source = @"@media screen and (min-width: 768px) { button { color: red; } }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error");

    NSArray *mediaGroups = stylesheet.mediaGroups;
    XCTAssertTrue(mediaGroups.count == 1, @"Expected 1 media group, found %lu", (unsigned long)mediaGroups.count);
}

- (void)testMediaWithRatio
{
    NSString *source = @"@media (device-aspect-ratio: 4/5) { button { color: red; } }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    NSArray *mediaGroups = stylesheet.mediaGroups;
    XCTAssertTrue(mediaGroups.count == 1, @"Expected one media group");

    // check expressions
    PXMediaGroup *mediaGroup = [mediaGroups objectAtIndex:0];
    PXNamedMediaExpression *expression = mediaGroup.query;
    id value = expression.value;
    XCTAssertTrue([value isKindOfClass: [NSNumber class]], @"Expected device aspect ratio to be an NSNumber");
    NSNumber *number = (NSNumber *) value;
    XCTAssertEqual(0.8f, [number floatValue], @"Expected device aspect ratio to be 0.8, but was %f", [number floatValue]);

    // check rule sets
    NSArray *ruleSets = mediaGroup.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected one rule set");
}

#pragma mark - inline CSS Tests

- (void)testInlineCssWithHexColor
{
    NSString *source = @"text: hello; size: 100 50; color: red; border-radius: 10; border-width: 1px; background-color: linear-gradient(red, #d97410);";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parseInlineCSS:source];

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error: %lu", (unsigned long)errors.count);

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected one rule set");

    PXRuleSet *ruleSet = [ruleSets objectAtIndex:0];
    PXDeclaration *backgroundColor = [ruleSet declarationForName:@"background-color"];
    XCTAssertNotNil(backgroundColor, @"Expected a 'background-color' declaration");

    id<PXPaint> paint = backgroundColor.paintValue;
    XCTAssertNotNil(paint, @"Expected a paint value");
    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected 'PXLinearGradient' class but found %@", [paint class]);
}

#pragma mark - Performance Tests

- (void)testLargeCSS
{
    double start = [[NSDate date] timeIntervalSinceNow];
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.pixate.pixate-freestyleTests"] pathForResource:@"large" ofType:@"css"];
    PXStylesheet *stylesheet = [PXStylesheet styleSheetFromFilePath:path withOrigin:PXStylesheetOriginApplication];
    double diff = [[NSDate date] timeIntervalSinceNow] - start;

    XCTAssertNotNil(stylesheet, @"Expected a stylesheet");

    NSLog(@"Elapsed time = %f", diff * 1000);
}

#pragma mark - Bug Fixes

- (void)testCrashWithHexPaint
{
    NSString *source = @"button { background-color: #D4D4D; }";
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    PXStylesheet *stylesheet = [parser parse:source withOrigin:PXStylesheetOriginApplication];

    // NOTE: If we get this far, we didn't crash :)

    NSArray *errors = parser.errors;
    XCTAssertTrue(errors.count == 0, @"Unexpected parse error: %lu", (unsigned long)errors.count);

    NSArray *ruleSets = stylesheet.ruleSets;
    XCTAssertTrue(ruleSets.count == 1, @"Expected one rule set");
}

- (void)testCrashOnImport
{
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.pixate.pixate-freestyleTests"] pathForResource:@"crashOnImport" ofType:@"css"];
    PXStylesheet *stylesheet = [PXStylesheet styleSheetFromFilePath:path withOrigin:PXStylesheetOriginApplication];
    
    XCTAssertNotNil(stylesheet, @"Expected a stylesheet after parsing crashOnImport.css");
}

@end
