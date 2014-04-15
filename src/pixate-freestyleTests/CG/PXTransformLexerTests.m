//
//  PXTransformLexerTests.m
//  PXShapeKit
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXTransformLexer.h"
#import "PXTransformTokenType.h"
#import "PXDimension.h"
#import <XCTest/XCTest.h>

@interface PXTransformLexerTests : XCTestCase

@end

@implementation PXTransformLexerTests
{
    PXTransformLexer *lexer;
}

- (void)setUp
{
    [super setUp];

    lexer = [[PXTransformLexer alloc] init];
}

- (void)tearDown
{
    lexer = nil;

    [super tearDown];
}

- (PXStylesheetLexeme *)assertLexemeType:(PXTransformTokens)type withSource:(NSString *)source
{
    lexer.source = source;
    PXStylesheetLexeme *lexeme = [lexer nextLexeme];

    XCTAssertNotNil(lexeme, @"Expected lexeme");

    NSString *expectedType = [PXTransformTokenType typeNameForInt:type];
    NSString *actualType = [PXTransformTokenType typeNameForInt:lexeme.type];

    XCTAssertTrue(lexeme.type == type, @"Expected %d(%@) but found %d(%@)", type, expectedType, lexeme.type, actualType);
    XCTAssertTrue(lexeme.range.location == 0, @"Lexeme does not start at offset zero");
    XCTAssertTrue(lexeme.range.length == source.length, @"Expected %lu characters but found %lu", (unsigned long)source.length, (unsigned long)lexeme.range.length);

    return lexeme;
}

- (void)assertLexemeType:(PXTransformTokens)tokenType dimensionType:(PXDimensionType)dimensionType withSource:(NSString *)source
{
    PXStylesheetLexeme *lexeme = [self assertLexemeType:tokenType withSource:source];
    id value = lexeme.value;

    XCTAssertNotNil(value, @"Lexeme value should be defined");
    XCTAssertTrue([value isKindOfClass:[PXDimension class]], @"Lexeme value should be an instance of PXSSDimension");

    PXDimension *dimension = (PXDimension *)value;

    XCTAssertEqual(dimensionType, dimension.type, @"Dimension types do not match: %d does not equal %d", dimensionType, dimension.type);
}

- (void)testTranslate
{
    [self assertLexemeType:PXTransformToken_TRANSLATE withSource:@"translate"];
}

- (void)testTranslateX
{
    [self assertLexemeType:PXTransformToken_TRANSLATEX withSource:@"translateX"];
}

- (void)testTranslateY
{
    [self assertLexemeType:PXTransformToken_TRANSLATEY withSource:@"translateY"];
}

- (void)testScale
{
    [self assertLexemeType:PXTransformToken_SCALE withSource:@"scale"];
}

- (void)testScaleX
{
    [self assertLexemeType:PXTransformToken_SCALEX withSource:@"scaleX"];
}

- (void)testScaleY
{
    [self assertLexemeType:PXTransformToken_SCALEY withSource:@"scaleY"];
}

- (void)testSkew
{
    [self assertLexemeType:PXTransformToken_SKEW withSource:@"skew"];
}

- (void)testSkewX
{
    [self assertLexemeType:PXTransformToken_SKEWX withSource:@"skewX"];
}

- (void)testSkewY
{
    [self assertLexemeType:PXTransformToken_SKEWY withSource:@"skewY"];
}

- (void)testRotate
{
    [self assertLexemeType:PXTransformToken_ROTATE withSource:@"rotate"];
}

- (void)testMatrix
{
    [self assertLexemeType:PXTransformToken_MATRIX withSource:@"matrix"];
}

- (void)testLParen
{
    [self assertLexemeType:PXTransformToken_LPAREN withSource:@"("];
}

- (void)testRParen
{
    [self assertLexemeType:PXTransformToken_RPAREN withSource:@")"];
}

- (void)testComma
{
    [self assertLexemeType:PXTransformToken_COMMA withSource:@","];
}

- (void)testEm
{
    [self assertLexemeType:PXTransformToken_EMS dimensionType:kDimensionTypeEms withSource:@"10em"];
}

- (void)testEx
{
    [self assertLexemeType:PXTransformToken_EXS dimensionType:kDimensionTypeExs withSource:@"10ex"];
}

- (void)testPixel
{
    [self assertLexemeType:PXTransformToken_LENGTH dimensionType:kDimensionTypePixels withSource:@"10px"];
}

- (void)testDevicePixel
{
    [self assertLexemeType:PXTransformToken_LENGTH dimensionType:kDimensionTypeDevicePixels withSource:@"10dpx"];
}

- (void)testCentimeter
{
    [self assertLexemeType:PXTransformToken_LENGTH dimensionType:kDimensionTypeCentimeters withSource:@"10cm"];
}

- (void)testMillimeter
{
    [self assertLexemeType:PXTransformToken_LENGTH dimensionType:kDimensionTypeMillimeters withSource:@"10mm"];
}

- (void)testInch
{
    [self assertLexemeType:PXTransformToken_LENGTH dimensionType:kDimensionTypeInches withSource:@"10in"];
}

- (void)testPoint
{
    [self assertLexemeType:PXTransformToken_LENGTH dimensionType:kDimensionTypePoints withSource:@"10pt"];
}

- (void)testPica
{
    [self assertLexemeType:PXTransformToken_LENGTH dimensionType:kDimensionTypePicas withSource:@"10pc"];
}

- (void)testDegree
{
    [self assertLexemeType:PXTransformToken_ANGLE dimensionType:kDimensionTypeDegrees withSource:@"10deg"];
}

- (void)testRadian
{
    [self assertLexemeType:PXTransformToken_ANGLE dimensionType:kDimensionTypeRadians withSource:@"10rad"];
}

- (void)testGradian
{
    [self assertLexemeType:PXTransformToken_ANGLE dimensionType:kDimensionTypeGradians withSource:@"10grad"];
}

- (void)testMillisecond
{
    [self assertLexemeType:PXTransformToken_TIME dimensionType:kDimensionTypeMilliseconds withSource:@"10ms"];
}

- (void)testSecond
{
    [self assertLexemeType:PXTransformToken_TIME dimensionType:kDimensionTypeSeconds withSource:@"10s"];
}

- (void)testHertz
{
    [self assertLexemeType:PXTransformToken_FREQUENCY dimensionType:kDimensionTypeHertz withSource:@"10Hz"];
}

- (void)testKilohertz
{
    [self assertLexemeType:PXTransformToken_FREQUENCY dimensionType:kDimensionTypeKilohertz withSource:@"10kHz"];
}

- (void)testPercentage
{
    [self assertLexemeType:PXTransformToken_PERCENTAGE dimensionType:kDimensionTypePercentage withSource:@"10%"];
}

- (void)testUserDefinedDimension
{
    [self assertLexemeType:PXTransformToken_DIMENSION dimensionType:kDimensionTypeUserDefined withSource:@"10units"];
}

@end
