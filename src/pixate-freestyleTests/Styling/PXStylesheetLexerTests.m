//
//  PXStylesheetLexerTests.m
//  PXSParser
//
//  Created by Kevin Lindsey on 6/25/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStylesheetLexeme.h"
#import "PXStylesheetTokenType.h"
#import "PXDimension.h"
#import <XCTest/XCTest.h>

void css_lexer_set_source(NSString *source);
void css_lexer_delete_buffer();
PXStylesheetLexeme *css_lexer_get_lexeme();

@interface PXStylesheetLexerTests : XCTestCase

@end

@implementation PXStylesheetLexerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (PXStylesheetLexeme *)assertLexemeType:(PXStylesheetTokens)type withSource:(NSString *)source
{
    return [self assertLexemeType:type withSource:source length:source.length];
}

- (PXStylesheetLexeme *)assertLexemeType:(PXStylesheetTokens)type withSource:(NSString *)source length:(NSInteger)length;
{
//    lexer.source = source;
//    PXStylesheetLexeme *lexeme = [lexer nextLexeme];
    css_lexer_set_source(source);
    PXStylesheetLexeme *lexeme = css_lexer_get_lexeme();
    css_lexer_delete_buffer();

    XCTAssertNotNil(lexeme, @"Expected lexeme");

    NSString *expectedType = [PXStylesheetTokenType typeNameForInt:type];
    NSString *actualType = [PXStylesheetTokenType typeNameForInt:lexeme.type];

    XCTAssertTrue(lexeme.type == type, @"Expected %d(%@) but found %d(%@)", (int)type, expectedType, lexeme.type, actualType);
    XCTAssertTrue(lexeme.range.location == 0, @"Lexeme does not start at offset zero");
    XCTAssertTrue(lexeme.range.length == length, @"Expected %ld characters but found %lu: %@", (long)length, (unsigned long)lexeme.range.length, lexeme);

    return lexeme;
}

- (void)assertLexemeType:(PXStylesheetTokens)tokenType dimensionType:(PXDimensionType)dimensionType withSource:(NSString *)source
{
    PXStylesheetLexeme *lexeme = [self assertLexemeType:tokenType withSource:source];
    id value = lexeme.value;

    XCTAssertNotNil(value, @"Lexeme value should be defined");
    XCTAssertTrue([value isKindOfClass:[PXDimension class]], @"Lexeme value should be an instance of PXSSDimension");

    PXDimension *dimension = (PXDimension *)value;

    XCTAssertEqual(dimensionType, dimension.type, @"Dimension types do not match: %d does not equal %d", dimensionType, dimension.type);
}

- (void)testInteger
{
    [self assertLexemeType:PXSS_NUMBER withSource:@"123"];
}

- (void)testFloat
{
    [self assertLexemeType:PXSS_NUMBER withSource:@"123.456"];
}

- (void)testClass
{
    [self assertLexemeType:PXSS_CLASS withSource:@".class"];
}

- (void)testClassWithEscapeSequence
{
    [self assertLexemeType:PXSS_CLASS withSource:@".one\\ two"];
}

- (void)testId
{
    [self assertLexemeType:PXSS_ID withSource:@"#id"];
}

- (void)testIdWithEscapeSequence
{
    [self assertLexemeType:PXSS_ID withSource:@"#one\\ two"];
}

- (void)testIdentifier
{
    [self assertLexemeType:PXSS_IDENTIFIER withSource:@"identifier0-with-dashes-and-numbers"];
}

- (void)testIdentifierWithEscapeSequence
{
    [self assertLexemeType:PXSS_IDENTIFIER withSource:@"one\\ two"];
}

- (void)testLCurly
{
    [self assertLexemeType:PXSS_LCURLY withSource:@"{"];
}

- (void)testRCurly
{
    [self assertLexemeType:PXSS_RCURLY withSource:@"}"];
}

- (void)testLParen
{
    [self assertLexemeType:PXSS_LPAREN withSource:@"("];
}

- (void)testRParen
{
    [self assertLexemeType:PXSS_RPAREN withSource:@")"];
}

- (void)testLBracket
{
    [self assertLexemeType:PXSS_LBRACKET withSource:@"["];
}

- (void)testRBracket
{
    [self assertLexemeType:PXSS_RBRACKET withSource:@"]"];
}

- (void)testSemicolon
{
    [self assertLexemeType:PXSS_SEMICOLON withSource:@";"];
}

- (void)testGreaterThan
{
    [self assertLexemeType:PXSS_GREATER_THAN withSource:@">"];
}

- (void)testPlus
{
    [self assertLexemeType:PXSS_PLUS withSource:@"+"];
}

- (void)testTilde
{
    [self assertLexemeType:PXSS_TILDE withSource:@"~"];
}

- (void)testStar
{
    [self assertLexemeType:PXSS_STAR withSource:@"*"];
}

- (void)testEqual
{
    [self assertLexemeType:PXSS_EQUAL withSource:@"="];
}

- (void)testColon
{
    [self assertLexemeType:PXSS_COLON withSource:@":"];
}

- (void)testComma
{
    [self assertLexemeType:PXSS_COMMA withSource:@","];
}

- (void)testPipe
{
    [self assertLexemeType:PXSS_PIPE withSource:@"|"];
}

- (void)testDoubleColon
{
    [self assertLexemeType:PXSS_DOUBLE_COLON withSource:@"::"];
}

- (void)testStartsWith
{
    [self assertLexemeType:PXSS_STARTS_WITH withSource:@"^="];
}

- (void)testEndsWith
{
    [self assertLexemeType:PXSS_ENDS_WITH withSource:@"$="];
}

- (void)testContains
{
    [self assertLexemeType:PXSS_CONTAINS withSource:@"*="];
}

- (void)testListContains
{
    [self assertLexemeType:PXSS_LIST_CONTAINS withSource:@"~="];
}

- (void)testHyphenListContains
{
    [self assertLexemeType:PXSS_EQUALS_WITH_HYPHEN withSource:@"|="];
}

- (void)testDoubleQuotedString
{
    [self assertLexemeType:PXSS_STRING withSource:@"\"abc\""];
}

- (void)testDoubleQuotedStringWithEscapes
{
    [self assertLexemeType:PXSS_STRING withSource:@"\"This is a test with a tab \\t and a double-quote \\\"\""];
}

- (void)testSingleQuotedString
{
    [self assertLexemeType:PXSS_STRING withSource:@"'abc'"];
}

- (void)testSingleQuotedStringWithEscapes
{
    [self assertLexemeType:PXSS_STRING withSource:@"'This is a test with a tab \\t and a single-quote \\''"];
}

- (void)testNot
{
    [self assertLexemeType:PXSS_NOT_PSEUDO_CLASS withSource:@":not("];
}

- (void)testLinearGradient
{
    [self assertLexemeType:PXSS_LINEAR_GRADIENT withSource:@"linear-gradient("];
}

- (void)testHSB
{
    [self assertLexemeType:PXSS_HSB withSource:@"hsb("];
}

- (void)testHSBA
{
    [self assertLexemeType:PXSS_HSBA withSource:@"hsba("];
}

- (void)testRGB
{
    [self assertLexemeType:PXSS_RGB withSource:@"rgb("];
}

- (void)testRGBA
{
    [self assertLexemeType:PXSS_RGBA withSource:@"rgba("];
}

- (void)test3DigitHexColor
{
    NSString *source = @"{#abc";
    css_lexer_set_source(source);
    PXStylesheetLexeme *lexeme = css_lexer_get_lexeme();

    lexeme = css_lexer_get_lexeme();
    css_lexer_delete_buffer();
    XCTAssertNotNil(lexeme, @"Expected lexeme");

    PXStylesheetTokens type = PXSS_HEX_COLOR;
    NSString *expectedType = [PXStylesheetTokenType typeNameForInt:type];
    NSString *actualType = [PXStylesheetTokenType typeNameForInt:lexeme.type];

    XCTAssertTrue(lexeme.type == type, @"Expected %ld(%@) but found %d(%@)", type, expectedType, lexeme.type, actualType);
    XCTAssertTrue(lexeme.range.location == 1, @"Lexeme does not start at offset one");
    XCTAssertTrue(lexeme.range.length == source.length - 1, @"Expected %lu characters but found %lu", source.length - 1, (unsigned long)lexeme.range.length);
}

- (void)test6DigitHexColor
{
    NSString *source = @"{#aabbcc";
    lexer.source = source;
    PXStylesheetLexeme *lexeme = [lexer nextLexeme];

    lexeme = [lexer nextLexeme];
    XCTAssertNotNil(lexeme, @"Expected lexeme");

    PXStylesheetTokens type = PXSS_HEX_COLOR;
    NSString *expectedType = [PXStylesheetTokenType typeNameForInt:type];
    NSString *actualType = [PXStylesheetTokenType typeNameForInt:lexeme.type];

    XCTAssertTrue(lexeme.type == type, @"Expected %d(%@) but found %d(%@)", (int) type, expectedType, lexeme.type, actualType);
    XCTAssertTrue(lexeme.range.location == 1, @"Lexeme does not start at offset one");
    XCTAssertTrue(lexeme.range.length == source.length - 1, @"Expected %lu characters but found %lu", source.length - 1, (unsigned long)lexeme.range.length);
}

- (void)testEm
{
    [self assertLexemeType:PXSS_EMS dimensionType:kDimensionTypeEms withSource:@"10em"];
}

- (void)testEx
{
    [self assertLexemeType:PXSS_EXS dimensionType:kDimensionTypeExs withSource:@"10ex"];
}

- (void)testPixel
{
    [self assertLexemeType:PXSS_LENGTH dimensionType:kDimensionTypePixels withSource:@"10px"];
}

- (void)testDevicePixel
{
    [self assertLexemeType:PXSS_LENGTH dimensionType:kDimensionTypeDevicePixels withSource:@"10dpx"];
}

- (void)testCentimeter
{
    [self assertLexemeType:PXSS_LENGTH dimensionType:kDimensionTypeCentimeters withSource:@"10cm"];
}

- (void)testMillimeter
{
    [self assertLexemeType:PXSS_LENGTH dimensionType:kDimensionTypeMillimeters withSource:@"10mm"];
}

- (void)testInch
{
    [self assertLexemeType:PXSS_LENGTH dimensionType:kDimensionTypeInches withSource:@"10in"];
}

- (void)testPoint
{
    [self assertLexemeType:PXSS_LENGTH dimensionType:kDimensionTypePoints withSource:@"10pt"];
}

- (void)testPica
{
    [self assertLexemeType:PXSS_LENGTH dimensionType:kDimensionTypePicas withSource:@"10pc"];
}

- (void)testDegree
{
    [self assertLexemeType:PXSS_ANGLE dimensionType:kDimensionTypeDegrees withSource:@"10deg"];
}

- (void)testRadian
{
    [self assertLexemeType:PXSS_ANGLE dimensionType:kDimensionTypeRadians withSource:@"10rad"];
}

- (void)testGradian
{
    [self assertLexemeType:PXSS_ANGLE dimensionType:kDimensionTypeGradians withSource:@"10grad"];
}

- (void)testMillisecond
{
    [self assertLexemeType:PXSS_TIME dimensionType:kDimensionTypeMilliseconds withSource:@"10ms"];
}

- (void)testSecond
{
    [self assertLexemeType:PXSS_TIME dimensionType:kDimensionTypeSeconds withSource:@"10s"];
}

- (void)testHertz
{
    [self assertLexemeType:PXSS_FREQUENCY dimensionType:kDimensionTypeHertz withSource:@"10Hz"];
}

- (void)testKilohertz
{
    [self assertLexemeType:PXSS_FREQUENCY dimensionType:kDimensionTypeKilohertz withSource:@"10kHz"];
}

- (void)testPercentage
{
    [self assertLexemeType:PXSS_PERCENTAGE dimensionType:kDimensionTypePercentage withSource:@"10%"];
}

- (void)testUserDefinedDimension
{
    [self assertLexemeType:PXSS_DIMENSION withSource:@"10units"];
}

- (void)testKeyframes
{
    [self assertLexemeType:PXSS_KEYFRAMES withSource:@"@keyframes"];
}

- (void)testError
{
    [self assertLexemeType:PXSS_ERROR withSource:@"&"];
}

- (void)testIdLooksLikeHexColor
{
    [self assertLexemeType:PXSS_ID withSource:@"#abc"];
}

- (void)testIdLooksLikeHexColor2
{
    [self assertLexemeType:PXSS_ID withSource:@"#back"];
}

- (void)testIdLooksLikeHexColor3
{
    [self assertLexemeType:PXSS_ID withSource:@"#background"];
}

- (void)testURLWithString
{
    [self assertLexemeType:PXSS_URL withSource:@"url(\"http://www.pixate.com\")"];
}

- (void)testURLWithURI
{
    [self assertLexemeType:PXSS_URL withSource:@"url(http://www.pixate.com)"];
}

- (void)testNamespace
{
    [self assertLexemeType:PXSS_NAMESPACE withSource:@"@namespace"];
}

- (void)testLinkPseudoClass
{
    [self assertLexemeType:PXSS_LINK_PSEUDO_CLASS withSource:@":link"];
}

- (void)testVisitedPseudoClass
{
    [self assertLexemeType:PXSS_VISITED_PSEUDO_CLASS withSource:@":visited"];
}

- (void)testHoverPseudoClass
{
    [self assertLexemeType:PXSS_HOVER_PSEUDO_CLASS withSource:@":hover"];
}

- (void)testActivePseudoClass
{
    [self assertLexemeType:PXSS_ACTIVE_PSEUDO_CLASS withSource:@":active"];
}

- (void)testFocusPseudoClass
{
    [self assertLexemeType:PXSS_FOCUS_PSEUDO_CLASS withSource:@":focus"];
}

- (void)testTargetPseudoClass
{
    [self assertLexemeType:PXSS_TARGET_PSEUDO_CLASS withSource:@":target"];
}

- (void)testLangPseudoClass
{
    [self assertLexemeType:PXSS_LANG_PSEUDO_CLASS withSource:@":lang("];
}

- (void)testEnabledPseudoClass
{
    [self assertLexemeType:PXSS_ENABLED_PSEUDO_CLASS withSource:@":enabled"];
}

- (void)testCheckedPseudoClass
{
    [self assertLexemeType:PXSS_CHECKED_PSEUDO_CLASS withSource:@":checked"];
}

- (void)tesIndeterminatePseudoClass
{
    [self assertLexemeType:PXSS_INDETERMINATE_PSEUDO_CLASS withSource:@":indeterminate"];
}

- (void)testRootPseudoClass
{
    [self assertLexemeType:PXSS_ROOT_PSEUDO_CLASS withSource:@":root"];
}

- (void)testNthChildPseudoClass
{
    [self assertLexemeType:PXSS_NTH_CHILD_PSEUDO_CLASS withSource:@":nth-child("];
}

- (void)testNthLastChildPseudoClass
{
    [self assertLexemeType:PXSS_NTH_LAST_CHILD_PSEUDO_CLASS withSource:@":nth-last-child("];
}

- (void)testNthOfTypePseudoClass
{
    [self assertLexemeType:PXSS_NTH_OF_TYPE_PSEUDO_CLASS withSource:@":nth-of-type("];
}

- (void)testNthLastOfTypePseudoClass
{
    [self assertLexemeType:PXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS withSource:@":nth-last-of-type("];
}

- (void)testFirstChildPseudoClass
{
    [self assertLexemeType:PXSS_FIRST_CHILD_PSEUDO_CLASS withSource:@":first-child"];
}

- (void)testLastChildPseudoClass
{
    [self assertLexemeType:PXSS_LAST_CHILD_PSEUDO_CLASS withSource:@":last-child"];
}

- (void)testFirstOfTypePseudoClass
{
    [self assertLexemeType:PXSS_FIRST_OF_TYPE_PSEUDO_CLASS withSource:@":first-of-type"];
}

- (void)testLastOfTypePseudoClass
{
    [self assertLexemeType:PXSS_LAST_OF_TYPE_PSEUDO_CLASS withSource:@":last-of-type"];
}

- (void)testOnlyChildPseudoClass
{
    [self assertLexemeType:PXSS_ONLY_CHILD_PSEUDO_CLASS withSource:@":only-child"];
}

- (void)testOnlyOfTypePseudoClass
{
    [self assertLexemeType:PXSS_ONLY_OF_TYPE_PSEUDO_CLASS withSource:@":only-of-type"];
}

- (void)testEmptyPseudoClass
{
    [self assertLexemeType:PXSS_EMPTY_PSEUDO_CLASS withSource:@":empty"];
}

- (void)testWhitespaceFlag
{
    lexer.source = @"a b";
    PXStylesheetLexeme *a = [lexer nextLexeme];
    PXStylesheetLexeme *b = [lexer nextLexeme];

    XCTAssertNotNil(a, @"a should not be nil");
    XCTAssertNotNil(b, @"b should not be nil");

    XCTAssertFalse([a flagIsSet:PXLexemeFlagFollowsWhitespace], @"a does not follow whitespace");
    XCTAssertTrue([b flagIsSet:PXLexemeFlagFollowsWhitespace], @"b should follow whitespace");
}

- (void)testNthNOnly
{
    [self assertLexemeType:PXSS_NTH withSource:@"n"];
}

- (void)testNthMinusNOnly
{
    [self assertLexemeType:PXSS_NTH withSource:@"-n"];
}

- (void)testNthPlusNOnly
{
    [self assertLexemeType:PXSS_NTH withSource:@"+n"];
}

- (void)testNthMultiplier
{
    [self assertLexemeType:PXSS_NTH withSource:@"2n"];
}

- (void)testNthPostiiveMultiplier
{
    [self assertLexemeType:PXSS_NTH withSource:@"+2n"];
}

- (void)testNthNegativeMultiplier
{
    [self assertLexemeType:PXSS_NTH withSource:@"-2n"];
}

- (void)testImportant
{
    [self assertLexemeType:PXSS_IMPORTANT withSource:@"!important"];
}

- (void)testImportantWithWhitespace
{
    [self assertLexemeType:PXSS_IMPORTANT withSource:@"! important"];
}

- (void)testImport
{
    [self assertLexemeType:PXSS_IMPORT withSource:@"@import"];
}

- (void)testMedia
{
    [self assertLexemeType:PXSS_MEDIA withSource:@"@media"];
}

- (void)testAnd
{
    [self assertLexemeType:PXSS_AND withSource:@"and"];
}

- (void)testPushSource
{
    NSString *source1 = @"red blue";
    NSString *source2 = @"green";

    lexer.source = source1;
    PXStylesheetLexeme *lexeme1 = [lexer nextLexeme];

    [lexer pushSource:source2];
    PXStylesheetLexeme *lexeme2 = [lexer nextLexeme];

    PXStylesheetLexeme *lexeme3 = [lexer nextLexeme];

    XCTAssertTrue(lexeme1.type == PXSS_IDENTIFIER, @"Expected IDENTIFIER: %@", lexeme1);
    XCTAssertTrue([@"red" isEqualToString:lexeme1.value], @"Expected 'red': %@", lexeme1.value);

    XCTAssertTrue(lexeme2.type == PXSS_IDENTIFIER, @"Expected IDENTIFIER: %@", lexeme2);
    XCTAssertTrue([@"green" isEqualToString:lexeme2.value], @"Expected 'green': %@", lexeme2.value);

    XCTAssertTrue(lexeme3.type == PXSS_IDENTIFIER, @"Expected IDENTIFIER: %@", lexeme3);
    XCTAssertTrue([@"blue" isEqualToString:lexeme3.value], @"Expected 'blue': %@", lexeme3.value);
}

@end
