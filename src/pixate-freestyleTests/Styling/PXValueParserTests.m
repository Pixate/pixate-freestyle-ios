//
//  PXValueParserTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/17/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXValueParser.h"
#import "PXStylesheetLexeme.h"
#import "PXSolidPaint.h"
#import "PXPaintGroup.h"
#import "UIColor+PXColors.h"
#import "PXDimension.h"
#import "PXMath.h"
#import "PXLinearGradient.h"
#import <XCTest/XCTest.h>

@interface PXValueParserTests : XCTestCase

@end

@implementation PXValueParserTests

#pragma mark - Assertions

- (void)assertColor:(UIColor *)expectedColor fromSource:(NSString *)source
{
    UIColor *color = [self colorFromSource:source];

    XCTAssertTrue([color isKindOfClass:[UIColor class]], @"Expected an instance of UIColor");
    XCTAssertTrue([color isEqual:expectedColor], @"Colors are not equal: %@ != %@", color, expectedColor);
}

#pragma mark - Helper Methods

- (NSArray *)lexemesFromSource:(NSString *)source
{
    NSArray *lexemes = [PXValueParser lexemesForSource:source];
    XCTAssertNotNil(lexemes, @"Expected an array of lexemes");
    XCTAssertTrue(lexemes.count > 0, @"Expected at least one lexeme");

    return lexemes;
}

- (UIColor *)colorFromSource:(NSString *)source
{
    PXValueParser *parser = [[PXValueParser alloc] init];

    UIColor *color = [parser parseColor:[self lexemesFromSource:source]];
    XCTAssertNotNil(color, @"Expected a paint");

    return color;
}

- (PXDimension *)dimensionFromSource:(NSString *)source
{
    NSArray *lexemes = [self lexemesFromSource:source];
    PXStylesheetLexeme *lexeme = [lexemes objectAtIndex:0];
    id value = lexeme.value;

    XCTAssertTrue([value isKindOfClass:[PXDimension class]], @"Expected lexeme value to a PXDimension");

    return value;
}

- (id<PXPaint>)paintFromSource:(NSString *)source
{
    PXValueParser *parser = [[PXValueParser alloc] init];

    id<PXPaint> paint = [parser parsePaint:[self lexemesFromSource:source]];
    XCTAssertNotNil(paint, @"Expected a paint");

    return paint;
}

- (UIEdgeInsets)insetsFromSource:(NSString *)source
{
    PXValueParser *parser = [[PXValueParser alloc] init];

    return [parser parseInsets:[self lexemesFromSource:source]];
}

- (id<PXShadowPaint>)shadowFromSource:(NSString *)source
{
    PXValueParser *parser = [[PXValueParser alloc] init];

    return [parser parseShadow:[self lexemesFromSource:source]];
}

#pragma mark - Angle Tests

// [KL] not sure where these go, but since the value parser uses dimension conversions, I'm putting them here

- (void)testDegree
{
    PXDimension *dimension = [self dimensionFromSource:@"180deg"];

    XCTAssertTrue(dimension.isAngle, @"Expected dimension to be an angle");
    XCTAssertEqual(180.0f, dimension.number, @"Angles do not match");
}

- (void)testGradian
{
    PXDimension *dimension = [self dimensionFromSource:@"180grad"];

    XCTAssertTrue(dimension.isAngle, @"Expected dimension to be an angle");

    PXDimension *degrees = dimension.degrees;

    XCTAssertEqual(degrees.number, 180.0f * 0.9f, @"Angles do not match");
}

- (void)testRadian
{
    PXDimension *dimension = [self dimensionFromSource:@"1rad"];

    XCTAssertTrue(dimension.isAngle, @"Expected dimension to be an angle");

    PXDimension *degrees = dimension.degrees;

    XCTAssertEqual(degrees.number, (CGFloat) RADIANS_TO_DEGREES(1.0), @"Angles do not match: %f != %f", degrees.number, RADIANS_TO_DEGREES(1.0f));
}

#pragma mark - Color Tests

- (void)testNamedColor
{
    [self assertColor:[UIColor redColor] fromSource:@"red"];
}

- (void)testHexColorThreeDigit
{
    [self assertColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] fromSource:@"#FFF"];
}

- (void)testHexColorSixDigit
{
    [self assertColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] fromSource:@"#FFFFFF"];
}

- (void)testRGBColorNumbers
{
    [self assertColor:[UIColor colorWithRed:128.0f/255.0f green:255.0f/255.0f blue:0.0f alpha:1.0f]
           fromSource:@"rgb(128,255,0)"];
}

- (void)testRGBColorPercents
{
    [self assertColor:[UIColor colorWithRed:0.5f green:1.0f blue:0.0f alpha:1.0f]
           fromSource:@"rgb(50%,100%,0%)"];
}

- (void)testRGBAColorNumbers
{
    [self assertColor:[UIColor colorWithRed:128.0f/255.0f green:255.0f/255.0f blue:0.0f alpha:1.0f]
           fromSource:@"rgba(128,255,0,1.0)"];
}

- (void)testRGBAColorPercents
{
    [self assertColor:[UIColor colorWithRed:0.5f green:1.0f blue:0.0f alpha:1.0f]
           fromSource:@"rgba(50%,100%,0%,100%)"];
}

- (void)testRGBAHex
{
    [self assertColor:[UIColor colorWithRed:1.0f green:0.0f blue:1.0f alpha:0.3f]
           fromSource:@"rgba(#F0F, 0.3)"];
}

- (void)testRGBANamedColor
{
    [self assertColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f]
           fromSource:@"rgba(red, 0.3)"];
}

- (void)testHSLNumber
{
    [self assertColor:[UIColor colorWithHue:180.0/360.0 saturation:0.5f lightness:0.5f alpha:1.0f]
           fromSource:@"hsl(180,50%,50%)"];
}

- (void)testHSLAngle
{
    [self assertColor:[UIColor colorWithHue:180.0/360.0 saturation:0.5f lightness:0.5f alpha:1.0f]
           fromSource:@"hsl(180deg,50%,50%)"];
}

- (void)testHSLANumber
{
    [self assertColor:[UIColor colorWithHue:180.0/360.0 saturation:0.5f lightness:0.5f alpha:1.0f]
           fromSource:@"hsla(180,50%,50%,100%)"];
}

- (void)testHSLAAngle
{
    [self assertColor:[UIColor colorWithHue:180.0/360.0 saturation:0.5f lightness:0.5f alpha:1.0f]
           fromSource:@"hsla(180deg,50%,50%,100%)"];
}

- (void)testHSBNumber
{
    [self assertColor:[UIColor colorWithHue:180.0/360.0 saturation:0.5f brightness:0.5f alpha:1.0f]
           fromSource:@"hsb(180,50%,50%)"];
}

- (void)testHSBAngle
{
    [self assertColor:[UIColor colorWithHue:180.0/360.0 saturation:0.5f brightness:0.5f alpha:1.0f]
           fromSource:@"hsb(180deg,50%,50%)"];
}

- (void)testHSBANumber
{
    [self assertColor:[UIColor colorWithHue:180.0/360.0 saturation:0.5f brightness:0.5f alpha:1.0f]
           fromSource:@"hsba(180,50%,50%,100%)"];
}

- (void)testHSBAAngle
{
    [self assertColor:[UIColor colorWithHue:180.0/360.0 saturation:0.5f brightness:0.5f alpha:1.0f]
           fromSource:@"hsba(180,50%,50%,1.0)"];
}

#pragma mark - Paint Tests

- (void)testSolidPaint
{
    NSString *source = @"red";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXSolidPaint class]], @"Expected an instance of PXSolidPaint");
}

- (void)testPaintGroup
{
    NSString *source = @"red,blue";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXPaintGroup class]], @"Expected an instance of PXPaintGroup");
}

- (void)testLinearGradient
{
    NSString *source = @"linear-gradient(white, blue, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    NSArray *offsets = linearGradient.offsets;
    XCTAssertTrue(0 == [offsets count], @"Expected 0 offsets, but found %lu", (unsigned long)[offsets count]);
}

- (void)testLinearGradientWithAngle
{
    NSString *source = @"linear-gradient(12deg, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    CGFloat angle = linearGradient.cssAngle;
    XCTAssertTrue(12.0f == angle, @"Expected 12 degrees, but found %f", angle);
}

- (void)testLinearGradientWithOffsets
{
    NSString *source = @"linear-gradient(white 25%, black 75%)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    NSArray *offsets = linearGradient.offsets;
    XCTAssertTrue(2 == [offsets count], @"Expected 2 offsets, but found %lu", (unsigned long)[offsets count]);
    CGFloat offset1 = ((NSNumber *)[offsets objectAtIndex:0]).floatValue;
    CGFloat offset2 = ((NSNumber *)[offsets objectAtIndex:1]).floatValue;
    XCTAssertEqual(offset1, 0.25f, @"Expected 0.25f");
    XCTAssertEqual(offset2, 0.75f, @"Expected 0.75f");
}

- (void)testLinearGradientToTop
{
    NSString *source = @"linear-gradient(to top, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToTop, @"Expected gradient direction to be to-top");
}

- (void)testLinearGradientToTopLeft
{
    NSString *source = @"linear-gradient(to top left, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToTopLeft, @"Expected gradient direction to be to-top-left");
}

- (void)testLinearGradientToLeftTop
{
    NSString *source = @"linear-gradient(to left top, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToTopLeft, @"Expected gradient direction to be to-top-left");
}

- (void)testLinearGradientToTopRight
{
    NSString *source = @"linear-gradient(to top right, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToTopRight, @"Expected gradient direction to be to-top-right");
}

- (void)testLinearGradientToRightTop
{
    NSString *source = @"linear-gradient(to right top, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToTopRight, @"Expected gradient direction to be to-top-right");
}

- (void)testLinearGradientToRight
{
    NSString *source = @"linear-gradient(to right, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToRight, @"Expected gradient direction to be to-right");
}

- (void)testLinearGradientToBottom
{
    NSString *source = @"linear-gradient(to bottom, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToBottom, @"Expected gradient direction to be to-bottom");
}

- (void)testLinearGradientToBottomRight
{
    NSString *source = @"linear-gradient(to bottom right, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToBottomRight, @"Expected gradient direction to be to-bottom-right");
}

- (void)testLinearGradientToRightBottom
{
    NSString *source = @"linear-gradient(to right bottom, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToBottomRight, @"Expected gradient direction to be to-bottom-right");
}

- (void)testLinearGradientToBottomLeft
{
    NSString *source = @"linear-gradient(to bottom left, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToBottomLeft, @"Expected gradient direction to be to-bottom-left");
}

- (void)testLinearGradientToLeftBottom
{
    NSString *source = @"linear-gradient(to left bottom, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToBottomLeft, @"Expected gradient direction to be to-bottom-left");
}

- (void)testLinearGradientToLeft
{
    NSString *source = @"linear-gradient(to left, white, black)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue([paint isKindOfClass:[PXLinearGradient class]], @"Expected an instance of PXLinearGradient");

    PXLinearGradient *linearGradient = paint;
    XCTAssertTrue(linearGradient.gradientDirection == PXLinearGradientDirectionToLeft, @"Expected gradient direction to be to-left");
}

#pragma mark - Blend Mode Tests

- (void)testNormalBlendMode
{
    NSString *source = @"linear-gradient(red, blue)";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeNormal, @"Expected 'normal' blend mode");
}

- (void)testNormalBlendMode2
{
    NSString *source = @"linear-gradient(red, blue) normal";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeNormal, @"Expected 'normal' blend mode");
}

- (void)testNormalBlendMode3
{
    NSString *source = @"linear-gradient(red, blue) unrecognized-blend-mode";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeNormal, @"Expected 'normal' blend mode");
}

- (void)testMultiplyBlendMode
{
    NSString *source = @"linear-gradient(red, blue) multiply";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeMultiply, @"Expected 'multiply' blend mode");
}

- (void)testScreenMode
{
    NSString *source = @"linear-gradient(red, blue) screen";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeScreen, @"Expected 'screen' blend mode");
}

- (void)testOverlayBlendMode
{
    NSString *source = @"linear-gradient(red, blue) overlay";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeOverlay, @"Expected 'overlay' blend mode");
}

- (void)testDarkenBlendMode
{
    NSString *source = @"linear-gradient(red, blue) darken";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeDarken, @"Expected 'darken' blend mode");
}

- (void)testLightenBlendMode
{
    NSString *source = @"linear-gradient(red, blue) lighten";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeLighten, @"Expected 'lighten' blend mode");
}

- (void)testColorDodgeBlendMode
{
    NSString *source = @"linear-gradient(red, blue) color-dodge";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeColorDodge, @"Expected 'color-dodge' blend mode");
}

- (void)testColorBurnBlendMode
{
    NSString *source = @"linear-gradient(red, blue) color-burn";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeColorBurn, @"Expected 'color-burn' blend mode");
}

- (void)testSoftLightBlendMode
{
    NSString *source = @"linear-gradient(red, blue) soft-light";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeSoftLight, @"Expected 'soft-light' blend mode");
}

- (void)testHardLightBlendMode
{
    NSString *source = @"linear-gradient(red, blue) hard-light";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeHardLight, @"Expected 'hard-light' blend mode");
}

- (void)testDifferenceBlendMode
{
    NSString *source = @"linear-gradient(red, blue) difference";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeDifference, @"Expected 'difference' blend mode");
}

- (void)testExclusionBlendMode
{
    NSString *source = @"linear-gradient(red, blue) exclusion";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeExclusion, @"Expected 'exclusion' blend mode");
}

- (void)testHueBlendMode
{
    NSString *source = @"linear-gradient(red, blue) hue";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeHue, @"Expected 'hue' blend mode");
}

- (void)testSaturationBlendMode
{
    NSString *source = @"linear-gradient(red, blue) saturation";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeSaturation, @"Expected 'saturation' blend mode");
}

- (void)testColorBlendMode
{
    NSString *source = @"linear-gradient(red, blue) color";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeColor, @"Expected 'color' blend mode");
}

- (void)testLuminosityBlendMode
{
    NSString *source = @"linear-gradient(red, blue) luminosity";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeLuminosity, @"Expected 'luminosity' blend mode");
}

- (void)testClearBlendMode
{
    NSString *source = @"linear-gradient(red, blue) clear";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeClear, @"Expected 'clear' blend mode");
}

- (void)testSourceInBlendMode
{
    NSString *source = @"linear-gradient(red, blue) source-in";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeSourceIn, @"Expected 'source-in' blend mode");
}

- (void)testSourceOutBlendMode
{
    NSString *source = @"linear-gradient(red, blue) source-out";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeSourceOut, @"Expected 'source-out' blend mode");
}

- (void)testSourceAtopBlendMode
{
    NSString *source = @"linear-gradient(red, blue) source-atop";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeSourceAtop, @"Expected 'source-atop' blend mode");
}

- (void)testDestinationOverBlendMode
{
    NSString *source = @"linear-gradient(red, blue) destination-over";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeDestinationOver, @"Expected 'destination-over' blend mode");
}

- (void)testDestinationInBlendMode
{
    NSString *source = @"linear-gradient(red, blue) destination-in";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeDestinationIn, @"Expected 'destination-in' blend mode");
}

- (void)testDestinationAtopBlendMode
{
    NSString *source = @"linear-gradient(red, blue) destination-atop";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeDestinationAtop, @"Expected 'destination-atop' blend mode");
}

- (void)testXorBlendMode
{
    NSString *source = @"linear-gradient(red, blue) xor";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModeXOR, @"Expected 'xor' blend mode");
}

- (void)testMultiplyPlusDarkerBlendMode
{
    NSString *source = @"linear-gradient(red, blue) plus-darker";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModePlusDarker, @"Expected 'plus-darker' blend mode");
}

- (void)testPlusLighterBlendMode
{
    NSString *source = @"linear-gradient(red, blue) plus-lighter";
    id<PXPaint> paint = [self paintFromSource:source];

    XCTAssertTrue(paint.blendMode == kCGBlendModePlusLighter, @"Expected 'plus-lighter' blend mode");
}

#pragma mark - Edge Inset Tests

- (void)testInsetWithNumbers
{
    NSString *source = @"0, 1.2, 0.1, 5";   // T R B L
    UIEdgeInsets expected = UIEdgeInsetsMake(0.0f, 5.0f, 0.1f, 1.2f);
    UIEdgeInsets insets = [self insetsFromSource:source];

    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(insets, expected), @"Insets do no match");
}

- (void)testInsetWithLengths
{
    NSString *source = @"0pt 1.2pt 0.1pt 5pt"; // T R B L
    UIEdgeInsets expected = UIEdgeInsetsMake(0.0f, 5.0f, 0.1f, 1.2f);
    UIEdgeInsets insets = [self insetsFromSource:source];

    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(insets, expected), @"Insets do not match");
}

- (void)testInsetWithInvalidValues
{
    NSString *source = @"inset";
    UIEdgeInsets insets = [self insetsFromSource:source];

    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero), @"Insets do not match");

}

#pragma mark - Bugs

- (void)testShadowValueCrash
{
    NSString *source = @"none;";
    id<PXShadowPaint> shadow = [self shadowFromSource:source];

    // if we got here, we didn't crash
    XCTAssertNil(shadow, @"Expected a nil shadow value");
}

@end
