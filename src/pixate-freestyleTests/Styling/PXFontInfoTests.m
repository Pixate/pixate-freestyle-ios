//
//  PXFontInfoTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/26/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXFontEntry.h"
#import <XCTest/XCTest.h>

@interface PXFontInfoTests : XCTestCase

@end

@implementation PXFontInfoTests

- (void)testStretchFilter
{
    NSString *family = @"Test";
    PXFontEntry *normal = [[PXFontEntry alloc] initWithFontFamily:family fontName:family];
    PXFontEntry *condensed = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Condensed", family]];
    PXFontEntry *expanded = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Expanded", family]];
    NSArray *entries = @[normal, condensed, expanded];

    NSArray *result = [PXFontEntry filterEntries:entries byStretch:[PXFontEntry indexFromStretchName:@"normal"]];

    XCTAssertNotNil(result, @"Expected an array back when filtering by stretch");
    XCTAssertTrue(result.count == 1, @"Expected only a single font info but found %d", result.count);
    PXFontEntry *item = [result objectAtIndex:0];
    XCTAssertEqualObjects(normal, item, @"Expected to find normal stretch font");
}

- (void)testStretchFilter2
{
    NSString *family = @"Test";
    PXFontEntry *condensed = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Condensed", family]];
    PXFontEntry *expanded = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Expanded", family]];
    NSArray *entries = @[condensed, expanded];

    NSArray *result = [PXFontEntry filterEntries:entries byStretch:[PXFontEntry indexFromStretchName:@"normal"]];

    XCTAssertNotNil(result, @"Expected an array back when filtering by stretch");
    XCTAssertTrue(result.count == 1, @"Expected only a single font info but found %d", result.count);
    PXFontEntry *item = [result objectAtIndex:0];
    XCTAssertEqualObjects(condensed, item, @"Expected to find normal stretch font");
}

- (void)testWeightFilter
{
    NSString *family = @"Test";
    PXFontEntry *normal = [[PXFontEntry alloc] initWithFontFamily:family fontName:family];
    PXFontEntry *bold = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Medium", family]];
    PXFontEntry *light = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Light", family]];
    NSArray *entries = @[normal, bold, light];

    NSArray *result = [PXFontEntry filterEntries:entries byWeight:[PXFontEntry indexFromWeightName:@"normal"]];

    XCTAssertNotNil(result, @"Expected an array back when filtering by weight");
    XCTAssertTrue(result.count == 1, @"Expected only a single font info but found %d", result.count);
    PXFontEntry *item = [result objectAtIndex:0];
    XCTAssertEqualObjects(normal, item, @"Expected %@ but found %@", normal, item);
}

- (void)testWeightFilter2
{
    NSString *family = @"Test";
    PXFontEntry *bold = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Medium", family]];
    PXFontEntry *light = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Light", family]];
    NSArray *entries = @[bold, light];

    NSArray *result = [PXFontEntry filterEntries:entries byWeight:[PXFontEntry indexFromWeightName:@"normal"]];

    XCTAssertNotNil(result, @"Expected an array back when filtering by weight");
    XCTAssertTrue(result.count == 1, @"Expected only a single font info but found %d", result.count);
    PXFontEntry *item = [result objectAtIndex:0];
    XCTAssertEqualObjects(bold, item, @"Expected %d but found %@", (int) normal, item);
}

- (void)testStyleFilter
{
    NSString *family = @"Test";
    PXFontEntry *normal = [[PXFontEntry alloc] initWithFontFamily:family fontName:family];
    PXFontEntry *italic = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Italic", family]];
    PXFontEntry *oblique = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Oblique", family]];
    NSArray *entries = @[normal, italic, oblique];

    NSArray *result = [PXFontEntry filterEntries:entries byStyle:@"normal"];

    XCTAssertNotNil(result, @"Expected an array back when filtering by style");
    XCTAssertTrue(result.count == 1, @"Expected only a single font info but found %d", result.count);
    PXFontEntry *item = [result objectAtIndex:0];
    XCTAssertEqualObjects(normal, item, @"Expected %@ but found %@", normal, item);
}

- (void)testStyleFilter2
{
    NSString *family = @"Test";
    PXFontEntry *italic = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Italic", family]];
    PXFontEntry *oblique = [[PXFontEntry alloc] initWithFontFamily:family fontName:[NSString stringWithFormat:@"%@-Oblique", family]];
    NSArray *entries = @[italic, oblique];

    NSArray *result = [PXFontEntry filterEntries:entries byStyle:@"normal"];

    XCTAssertNotNil(result, @"Expected an array back when filtering by style");
    XCTAssertTrue(result.count == 1, @"Expected only a single font info but found %d", result.count);
    PXFontEntry *item = [result objectAtIndex:0];
    XCTAssertEqualObjects(italic, item, @"Expected %d but found %@", (int) normal, item);
}

#pragma mark - Helvetica Neue Tests

- (void)testHelveticaNeue
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 400, @"Expected weight to be 400");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"normal" isEqualToString:entry.style], @"Expected style to be normal");
}

- (void)testHelveticaNeueBold
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-Bold";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 700, @"Expected weight to be 700");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"normal" isEqualToString:entry.style], @"Expected style to be normal");
}

- (void)testHelveticaNeueBoldItalic
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-BoldItalic";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 700, @"Expected weight to be 700");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"italic" isEqualToString:entry.style], @"Expected style to be italic");
}

- (void)testHelveticaNeueCondensedBlack
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-CondensedBlack";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 900, @"Expected weight to be 900");
    XCTAssertTrue(entry.stretch == 2, @"Expected stretch to be 2");
    XCTAssertTrue([@"normal" isEqualToString:entry.style], @"Expected style to be normal");
}

- (void)testHelveticaNeueCondensedBold
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-CondensedBold";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 700, @"Expected weight to be 700");
    XCTAssertTrue(entry.stretch == 2, @"Expected stretch to be 2");
    XCTAssertTrue([@"normal" isEqualToString:entry.style], @"Expected style to be normal");
}

- (void)testHelveticaNeueLight
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-Light";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 300, @"Expected weight to be 300");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"normal" isEqualToString:entry.style], @"Expected style to be normal");
}

- (void)testHelveticaNeueLightItalic
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-LightItalic";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 300, @"Expected weight to be 300");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"italic" isEqualToString:entry.style], @"Expected style to be italic");
}

- (void)testHelveticaNeueMedium
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-Medium";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 500, @"Expected weight to be 500");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"normal" isEqualToString:entry.style], @"Expected style to be normal");
}

- (void)testHelveticaNeueMediumItalic
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-MediumItalic";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 500, @"Expected weight to be 500");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"italic" isEqualToString:entry.style], @"Expected style to be italic");
}

- (void)testHelveticaNeueThin
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-Thin";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 100, @"Expected weight to be 100");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"normal" isEqualToString:entry.style], @"Expected style to be normal");
}

- (void)testHelveticaNeueThinItalic
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-ThinItalic";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 100, @"Expected weight to be 100");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"italic" isEqualToString:entry.style], @"Expected style to be italic");
}

- (void)testHelveticaNeueUltraLight
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-UltraLight";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 200, @"Expected weight to be 200");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"normal" isEqualToString:entry.style], @"Expected style to be normal");
}

- (void)testHelveticaNeueUltraLightItalic
{
    NSString *familyName = @"Helvetica Neue";
    NSString *fontName = @"HelveticaNeue-UltraLightItalic";
    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];

    XCTAssertTrue(entry.weight == 200, @"Expected weight to be 300");
    XCTAssertTrue(entry.stretch == 4, @"Expected stretch to be 4");
    XCTAssertTrue([@"italic" isEqualToString:entry.style], @"Expected style to be italic");
}

@end
