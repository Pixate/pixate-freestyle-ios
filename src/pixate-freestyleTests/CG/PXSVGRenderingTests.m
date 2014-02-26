//
//  PXSVGRenderingTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/29/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "ImageBasedTests.h"
#import <XCTest/XCTest.h>
#import "PXShapeView.h"
#import "PXShapeGroup.h"

//#define WRITE_SVG_TO_DISK

@interface PXSVGRenderingTests : ImageBasedTests

@end

@implementation PXSVGRenderingTests

- (NSString *)rasterImageDirectoryName
{
    return @"SVG-Rendering";
}

- (void)assertSVG:(NSString *)name
{
    // render SVG file
    UIImage *image = [self getSVGImageForName:name];

#ifdef WRITE_SVG_TO_DISK
    //NSString *path = [NSString stringWithFormat:@"/Users/pcolton/Development/Pixate/products/pixate-freestyle-ios/src/pixate-freestyleTests/Resources/SVG-Rendering/%@.png", name];
    [self writeImage:image withPath:path overwrite:YES];
#else
    // save results to file system
    NSString *tempName = @"temp";
    NSString *tempFile = [self localPathForName:tempName];

    [self writeImage:image withName:tempName overwrite:YES];

    // load images from disk
    UIImage *sourceImage = [UIImage imageWithContentsOfFile:tempFile];
    UIImage *targetImage = [self getImageForName:name];

    // make sure the images loaded
    XCTAssertNotNil(sourceImage, @"Unable to load %@", tempFile);
    XCTAssertNotNil(targetImage, @"Unable to locate %@.png", name);

    // compare
    [self assertImage:sourceImage equalsImage:targetImage];

    // cleanup
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:tempFile error:NULL];
#endif
}

- (UIImage *)getSVGImageForName:(NSString *)name
{
    // get path to SVG file
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.pixate.pixate-freestyleTests"] pathForResource:name ofType:@"svg"];

    // create view
    PXShapeView *shapeView = [[PXShapeView alloc] init];

    // load SVG image
    [shapeView loadSceneFromURL:[NSURL fileURLWithPath:path]];

    // grab root shape
    PXShapeGroup *root = (PXShapeGroup *) shapeView.document.shape;
    CGRect bounds = root.viewport;

    if (CGRectIsEmpty(bounds))
    {
        // use 100x100 if we didn't find a view port in the SVG file
        bounds = CGRectMake(0.0, 0.0, 100.0, 100.0);
    }

    // set size
    shapeView.frame = bounds;

    // render to UIImage
    return [shapeView renderToImage];
}

#pragma mark - Element Tests

- (void)testLine
{
    [self assertSVG:@"line"];
}

- (void)testCircle
{
    [self assertSVG:@"circlesvg"];
}

- (void)testEllipse
{
    [self assertSVG:@"ellipsesvg"];
}

- (void)testRectangle
{
    [self assertSVG:@"rect"];
}

#pragma mark - Path Command Tests

- (void)testArcCommand
{
    [self assertSVG:@"arcCommand"];
}

- (void)testCloseCommand
{
    [self assertSVG:@"closeCommand"];
}

- (void)testCubicBezierCommand
{
    [self assertSVG:@"cubicBezierCommand"];
}

- (void)testHorizontalLineCommand
{
    [self assertSVG:@"horizontalLineCommand"];
}

- (void)testLineCommand
{
    [self assertSVG:@"lineCommand"];
}

- (void)testMoveCommand
{
    [self assertSVG:@"moveCommand"];
}

- (void)testMoveCommand2
{
    // NOTE: This is actually failing but this is due to a bug in CoreGraphics
    [self assertSVG:@"moveCommand2"];
}

- (void)testQuadraticBezierCommand
{
    [self assertSVG:@"quadraticBezierCommand"];
}

- (void)testSmoothCubicBezierCommand
{
    [self assertSVG:@"smoothCubicBezierCommand"];
}

- (void)testSmoothQuadraticBezierCommand
{
    [self assertSVG:@"smoothQuadraticBezierCommand"];
}

- (void)testVerticalLineCommand
{
    [self assertSVG:@"verticalLineCommand"];
}

- (void)testRelativeArcCommand
{
    [self assertSVG:@"relativeArcCommand"];
}

- (void)testRelativeCloseCommand
{
    [self assertSVG:@"relativeCloseCommand"];
}

- (void)testRelativeCubicBezierCommand
{
    [self assertSVG:@"relativeCubicBezierCommand"];
}

- (void)testRelativeHorizontalLineCommand
{
    [self assertSVG:@"relativeHorizontalLineCommand"];
}

- (void)testRelativeLineCommand
{
    [self assertSVG:@"relativeLineCommand"];
}

- (void)testRelativeMoveCommand
{
    [self assertSVG:@"relativeMoveCommand"];
}

- (void)testRelativeQuadraticBezierCommand
{
    [self assertSVG:@"relativeQuadraticBezierCommand"];
}

- (void)testRelativeSmoothCubicBezierCommand
{
    [self assertSVG:@"relativeSmoothCubicBezierCommand"];
}

- (void)testRelativeSmoothQuadraticBezierCommand
{
    [self assertSVG:@"relativeSmoothQuadraticBezierCommand"];
}

- (void)testRelativeVerticalLineCommand
{
    [self assertSVG:@"relativeVerticalLineCommand"];
}

#pragma mark - Text Tests

//- (void)testText
//{
//    [self assertSVG:@"text"];
//}

#pragma mark - Color Tests

- (void)testOpacity
{
    [self assertSVG:@"opacity"];
}

#pragma mark - Gradient Tests

- (void)testLinearGradient
{
    [self assertSVG:@"linear-gradient"];
}

- (void)testRadialGradient
{
    [self assertSVG:@"radial-gradient"];
}

#pragma mark - Strokes

- (void)testLineCaps
{
    [self assertSVG:@"line-caps"];
}

- (void)testLineJoin
{
    [self assertSVG:@"line-join"];
}

- (void)testStrokeTypes
{
    [self assertSVG:@"stroke-types"];
}

#pragma mark - Clipping Path Tests

//- (void)testClippingPath
//{
//    [self assertSVG:@"clipping-path"];
//}

//- (void)testClippingPath2
//{
//    [self assertSVG:@"clipping-path2"];
//}

#pragma mark - Samples

- (void)testLion
{
    [self assertSVG:@"lion"];
}

- (void)testPeople
{
    [self assertSVG:@"people"];
}

- (void)testToucan
{
    [self assertSVG:@"toucan"];
}

- (void)testWoodGrain
{
    [self assertSVG:@"wood"];
}

- (void)testIcon1
{
    [self assertSVG:@"icon1"];
}

- (void)testIcon2
{
    [self assertSVG:@"icon2"];
}

- (void)testIcon3
{
    [self assertSVG:@"icon3"];
}

- (void)testIcon4
{
    [self assertSVG:@"icon4"];
}

- (void)testFaAdjust
{
//    [self assertSVG:@"fa-adjust"];
}

@end
