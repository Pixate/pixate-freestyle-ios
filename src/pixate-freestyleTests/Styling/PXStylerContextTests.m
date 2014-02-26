//
//  PXStylerContextTests.m
//  Pixate
//
//  Created by Robin Debreuil on 1/10/2014.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXStylerContext.h"
#import <XCTest/XCTest.h>

@interface PXStylerContextTests : XCTestCase

@end

@implementation PXStylerContextTests

#pragma mark - Tests

- (void)testTextTransformLowercase
{
    NSString *string = @"ThIs Is A tEsT";
    NSString *expected = @"this is a test";
    NSString *result = [PXStylerContext transformString:string usingAttribute:@"lowercase"];
    
    XCTAssertEqualObjects(result, expected, @"Transformed text does not match");
}

- (void)testTextTransformUppercase
{
    NSString *string = @"ThIs Is A tEsT";
    NSString *expected = @"THIS IS A TEST";
    NSString *result = [PXStylerContext transformString:string usingAttribute:@"uppercase"];
    
    XCTAssertEqualObjects(result, expected, @"Transformed text does not match");
}

- (void)testTextTransformCapitalize
{
    NSString *string = @"ThIs Is A tEsT";
    NSString *expected = @"This Is A Test";
    NSString *result = [PXStylerContext transformString:string usingAttribute:@"capitalize"];
    
    XCTAssertEqualObjects(result, expected, @"Transformed text does not match");
}

- (void)testKernSizePx
{
    PXDimension *pxd = [[PXDimension alloc] initWithNumber:12 withDimension:@"px"];
    UIFont *font = [UIFont fontWithName:@"Arial" size:16];
    NSNumber *expected = @12;
    NSNumber *result = [PXStylerContext kernPointsFrom:pxd usingFont:font];
    
    XCTAssertEqualObjects(result, expected, @"letter-spacing in px does not match");
}

- (void)testKernSizePts
{
    PXDimension *pxd = [[PXDimension alloc] initWithNumber:12 withDimension:@"pt"];
    UIFont *font = [UIFont fontWithName:@"Arial" size:16];
    NSNumber *expected = @12;
    NSNumber *result = [PXStylerContext kernPointsFrom:pxd usingFont:font];
    
    XCTAssertEqualObjects(result, expected, @"letter-spacing in pts does not match");
}

- (void)testKernSizeEms
{
    PXDimension *pxd = [[PXDimension alloc] initWithNumber:1 withDimension:@"em"];
    UIFont *font = [UIFont fontWithName:@"Arial" size:16];
    NSNumber *expected = @16;
    NSNumber *result = [PXStylerContext kernPointsFrom:pxd usingFont:font];
    
    XCTAssertEqualObjects(result, expected, @"letter-spacing in ems does not match");
}

- (void)testKernSizePercent
{
    PXDimension *pxd = [[PXDimension alloc] initWithNumber:125 withDimension:@"%"];
    UIFont *font = [UIFont fontWithName:@"Arial" size:16];
    NSNumber *expected = @20;
    NSNumber *result = [PXStylerContext kernPointsFrom:pxd usingFont:font];
    
    XCTAssertEqualObjects(result, expected, @"letter-spacing in percent does not match");
}


- (void)testGeneratedTextAttributesDefaults
{
    UILabel *defaultView = [UILabel new];
    defaultView.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:22];
    defaultView.text = @"DEFault text";
    
    PXStylerContext *context = [[PXStylerContext alloc] init];
    context.letterSpacing = [[PXDimension alloc] initWithNumber:.5 withDimension:@"em"];
    context.textDecoration = @"underline";
    context.textTransform = @"lowercase";
    
    NSDictionary *attributes = [context attributedTextAttributes:defaultView withDefaultText:defaultView.text andColor:[UIColor blueColor]];
    
    NSString *fullFontName = context.font.fontDescriptor.postscriptName;
    XCTAssertEqualObjects(context.transformedText, @"default text", @"capitalized text does not match");
    XCTAssertEqualObjects(context.font.familyName, @"American Typewriter", @"font name does not match");
    XCTAssertEqualObjects(fullFontName, @"AmericanTypewriter-Bold", @"font style does not match");
    XCTAssertEqualObjects(@(context.font.pointSize), @22, @"font size does not match");
    XCTAssertEqualObjects([attributes objectForKey:NSUnderlineStyleAttributeName], @(NSUnderlinePatternSolid | NSUnderlineStyleSingle), @"font underline does not match");
    
    XCTAssertEqualObjects([attributes objectForKey:NSKernAttributeName], @11, @"kerned em size does not match");
    XCTAssertEqualObjects([attributes objectForKey:NSForegroundColorAttributeName], [UIColor blueColor], @"text color does not match");
}

- (void)testGeneratedTextAttributes
{
    UIView *defaultView = [UIView new];
    PXStylerContext *context = [[PXStylerContext alloc] init];
    context.text = @"TeStinG ConteXt sTyler";
    context.letterSpacing = [[PXDimension alloc] initWithNumber:2 withDimension:@"em"];
    context.fontName = @"Arial";
    context.fontSize = 16;
    context.fontWeight = @"bold";
    [context setPropertyValue:[UIColor redColor] forName:@"color"];
    context.textDecoration = @"underline";
    context.textTransform = @"uppercase";
    
    NSDictionary *attributes = [context attributedTextAttributes:defaultView withDefaultText:context.text andColor:[UIColor blueColor]];
    
    NSString *fullFontName = context.font.fontDescriptor.postscriptName;
    XCTAssertEqualObjects(context.transformedText, @"TESTING CONTEXT STYLER", @"capitalized text does not match");
    XCTAssertEqualObjects(context.font.familyName, @"Arial", @"font name does not match");
    XCTAssertEqualObjects(fullFontName, @"Arial-BoldMT", @"font style does not match");
    XCTAssertEqualObjects(@(context.font.pointSize), @16, @"font kerning does not match");
    XCTAssertEqualObjects([attributes objectForKey:NSUnderlineStyleAttributeName], @(NSUnderlinePatternSolid | NSUnderlineStyleSingle), @"font underline does not match");
    
    XCTAssertEqualObjects([attributes objectForKey:NSKernAttributeName], @32, @"kerned em size does not match");
    XCTAssertEqualObjects([attributes objectForKey:NSForegroundColorAttributeName], [UIColor redColor], @"text color does not match");
}

- (void)testMergededAttributes
{
    NSDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [UIColor yellowColor], NSForegroundColorAttributeName,
                                       @22, NSKernAttributeName,
                                       nil];
    
    PXStylerContext *context = [[PXStylerContext alloc] init];
    context.fontName = @"Arial";
    context.fontSize = 16;
    context.fontWeight = @"bold";
    context.letterSpacing = [[PXDimension alloc] initWithNumber:16 withDimension:@"pt"];
    
    attributes = [context mergeTextAttributes:attributes];
    
    XCTAssertEqualObjects([attributes objectForKey:NSForegroundColorAttributeName], [UIColor yellowColor], @"text color does not match");
    XCTAssertEqualObjects(context.font.familyName, @"Arial", @"font name does not match");
    XCTAssertEqualObjects([attributes objectForKey:NSKernAttributeName], @16, @"font kerning does not match"); // should not be 22!
}

@end
