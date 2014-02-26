//
//  PXShapeRenderingTests.m
//  PXShapeKit
//
//  Created by Kevin Lindsey on 8/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "ImageBasedTests.h"
#import "PXGraphics.h"
#import "PXArrowRectangle.h"
#import "PXBoxModel.h"

//#define WRITE_TO_DISK

@interface PXShapeRenderingTests : ImageBasedTests

@end

@implementation PXShapeRenderingTests

- (void)assertShape:(PXShape *)shape equalsImageName:(NSString *)name
{
    [self assertShape:shape equalsImageName:name withWidth:100 withHeight:100];
}

- (void)assertShape:(PXShape *)shape equalsImageName:(NSString *)name withWidth:(UInt16)width withHeight:(UInt16)height
{
    // create context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (context)
    {
        [shape render:context];

        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

#ifdef WRITE_TO_DISK
//        NSString *path = [NSString stringWithFormat:@"/Users/pcolton/Development/Pixate/products/pixate-freestyle-ios/src/pixate-freestyleTests/Resources/Rendering/%@.png", name];
        [self writeImage:image withPath:path overwrite:YES];
#else
        NSString *tempName = @"temp";
        NSString *tempFile = [self localPathForName:tempName];

        // write generated image to disk
        [self writeImage:image withName:tempName overwrite:YES];

        // load images from disk
        UIImage *sourceImage = [UIImage imageWithContentsOfFile:tempFile];
        UIImage *targetImage = [self getImageForName:name];

        // make sure the images loaded
        XCTAssertNotNil(sourceImage, @"Unable to locate temp.png");
        XCTAssertNotNil(targetImage, @"Unable to locate %@.png", name);

        // compare
        [self assertImage:sourceImage equalsImage:targetImage];

        // cleanup
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:tempFile error:NULL];
#endif
    }

    UIGraphicsEndImageContext();
}

#pragma mark - Shape Tests

- (void)testCircle
{
    PXCircle *shape = [PXCircle circleWithCenter:CGPointMake(50.0f,50.0f) withRadius:45.0f];

    shape.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:shape equalsImageName:@"circle"];
}

- (void)testCircleLocationUpdate
{
    PXCircle *shape = [PXCircle circleWithCenter:CGPointMake(50.0f,50.0f) withRadius:45.0f];

    // before
    shape.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];
    [self assertShape:shape equalsImageName:@"circle"];

    // after
    shape.center = CGPointMake(45.0f, 45.0f);
    [self assertShape:shape equalsImageName:@"circle-location-update"];
}

- (void)testCircleRadiusUpdate
{
    PXCircle *shape = [PXCircle circleWithCenter:CGPointMake(50.0f,50.0f) withRadius:45.0f];

    // before
    shape.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];
    [self assertShape:shape equalsImageName:@"circle"];

    // after
    shape.radius = 40.0f;
    [self assertShape:shape equalsImageName:@"circle-radius-update"];
}

- (void)testEllipse
{
    PXEllipse *shape = [PXEllipse ellipseWithCenter:CGPointMake(50.0f,50.0f) withRadiusX:45.0f withRadiusY:25.0f];

    shape.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:shape equalsImageName:@"ellipse"];
}

- (void)testArc
{
    PXArc *shape = [[PXArc alloc] init];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 10.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor blueColor]];
    shape.center = CGPointMake(50.0f, 50.0f);
    shape.radius = 40.0f;
    shape.startingAngle = -90.0f;
    shape.endingAngle = 10.0f;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"arc"];
}

- (void)testPie
{
    PXPie *shape = [[PXPie alloc] init];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 10.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor blueColor]];
    shape.center = CGPointMake(50.0f, 50.0f);
    shape.radius = 40.0f;
    shape.startingAngle = -90.0f;
    shape.endingAngle = 10.0f;
    shape.stroke = stroke;
    shape.fill = [PXSolidPaint paintWithColor:[UIColor darkGrayColor]];

    [self assertShape:shape equalsImageName:@"pie"];
}

- (void)testRoundedRectangle
{
    PXRectangle *shape = [[PXRectangle alloc] initWithRect:CGRectMake(0.0f, 0.0f, 100.0f, 60.0f)];

    shape.cornerRadii = CGSizeMake(5.0f, 5.0f);
    shape.fill = [[PXSolidPaint alloc] initWithColor:[UIColor blueColor]];

    [self assertShape:shape equalsImageName:@"rectangle-rounded"];
}

- (void)testRoundedRectangleElliptical
{
    PXRectangle *shape = [[PXRectangle alloc] initWithRect:CGRectMake(0.0f, 0.0f, 100.0f, 60.0f)];

    shape.cornerRadii = CGSizeMake(15.0f, 5.0f);
    shape.fill = [[PXSolidPaint alloc] initWithColor:[UIColor blueColor]];

    [self assertShape:shape equalsImageName:@"rectangle-rounded-elliptical"];
}

- (void)testEllipticalArc
{
    PXPath *path = [[PXPath alloc] init];

    [path moveToX:10.0f y:40.0f];
    [path lineToX:90.0f y:40.0f];
    [path ellipticalArcX:10.0f y:40.0f radiusX:80.0f radiusY:20.0f startAngle:0.0f endAngle:M_PI_2];
    [path close];

    path.fill = [[PXSolidPaint alloc] initWithColor:[UIColor redColor]];

    [self assertShape:path equalsImageName:@"elliptical-arc"];
}

- (void)testArrowRectangleLeft
{
    PXArrowRectangle *button = [[PXArrowRectangle alloc] initWithRect:CGRectMake(0.0f, 0.0f, 100.0f, 60.0f) direction:PXArrowRectangleDirectionLeft];

    button.cornerRadii = CGSizeMake(5.0f, 5.0f);
    button.fill = [[PXSolidPaint alloc] initWithColor:[UIColor blueColor]];

    [self assertShape:button equalsImageName:@"arrow-rectangle-left"];
}

- (void)testArrowRectangleRight
{
    PXArrowRectangle *button = [[PXArrowRectangle alloc] initWithRect:CGRectMake(0.0f, 0.0f, 100.0f, 60.0f) direction:PXArrowRectangleDirectionRight];

    button.cornerRadii = CGSizeMake(5.0f, 5.0f);
    button.fill = [[PXSolidPaint alloc] initWithColor:[UIColor blueColor]];

    [self assertShape:button equalsImageName:@"arrow-rectangle-right"];
}

#pragma mark - Stroke Tests

- (void)testSolidStroke
{
    PXLine *shape = [[PXLine alloc] initX1:20.0f y1:50.0f x2:80.0f y2:50.0f];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 30.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"solid-stroke"];
}

- (void)testLinearGradientStroke
{
    PXLine *shape = [[PXLine alloc] initX1:20.0f y1:50.0f x2:80.0f y2:50.0f];
    PXStroke *stroke = [[PXStroke alloc] init];
    PXLinearGradient *gradient = [PXLinearGradient gradientFromStartColor:[UIColor blueColor] endColor:[UIColor whiteColor]];

    gradient.angle = 0.0f;
    stroke.width = 30.0f;
    stroke.color = gradient;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"linear-gradient-stroke"];
}

- (void)testRadialGradientStroke
{
    PXLine *shape = [[PXLine alloc] initX1:20.0f y1:50.0f x2:80.0f y2:50.0f];
    PXStroke *stroke = [[PXStroke alloc] init];
    PXRadialGradient *gradient = [[PXRadialGradient alloc] init];

    gradient.gradientUnits = PXGradientUnitsUserSpace;
    gradient.startCenter = CGPointMake(50.0f, 50.0f);
    gradient.endCenter = CGPointMake(50.0f, 50.0f);
    gradient.radius = 30.0f;
    [gradient addColor:[UIColor blueColor]];
    [gradient addColor:[UIColor whiteColor]];
    stroke.width = 30.0f;
    stroke.color = gradient;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"radial-gradient-stroke"];
}

- (void)testInnerStroke
{
    PXRectangle *shape = [[PXRectangle alloc] initWithRect:CGRectMake(20.0f, 20.0f, 60.0f, 60.0f)];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 30.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.type = kStrokeTypeInner;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"inner-stroke"];
}

- (void)testCenteredStroke
{
    PXRectangle *shape = [[PXRectangle alloc] initWithRect:CGRectMake(20.0f, 20.0f, 60.0f, 60.0f)];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 30.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.type = kStrokeTypeCenter;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"center-stroke"];
}

- (void)testOuterStroke
{
    /*
    PXRectangle *shape = [[PXRectangle alloc] initWithRect:CGRectMake(10.0f, 10.0f, 80.0f, 80.0f)];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 10.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.type = kStrokeTypeOuter;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"outer-stroke"];
    */
}

- (void)testLineCapButt
{
    PXLine *shape = [[PXLine alloc] initX1:20.0f y1:50.0f x2:80.0f y2:50.0f];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 30.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.lineCap = kCGLineCapButt;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"line-cap-butt"];
}

- (void)testLineCapRound
{
    PXLine *shape = [[PXLine alloc] initX1:20.0f y1:50.0f x2:80.0f y2:50.0f];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 30.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.lineCap = kCGLineCapRound;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"line-cap-round"];
}

- (void)testLineCapSquare
{
    PXLine *shape = [[PXLine alloc] initX1:20.0f y1:50.0f x2:80.0f y2:50.0f];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 30.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.lineCap = kCGLineCapSquare;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"line-cap-square"];
}

- (void)testLineJoinBevel
{
    PXPath *shape = [[PXPath alloc] init];
    PXStroke *stroke = [[PXStroke alloc] init];

    [shape moveToX:20.0f y:60.0f];
    [shape lineToX:50.0f y:20.0f];
    [shape lineToX:80.0f y:60.0f];

    stroke.width = 30.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.lineJoin = kCGLineJoinBevel;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"line-join-bevel"];
}

- (void)testLineJoinRound
{
    PXPath *shape = [[PXPath alloc] init];
    PXStroke *stroke = [[PXStroke alloc] init];

    [shape moveToX:20.0f y:60.0f];
    [shape lineToX:50.0f y:20.0f];
    [shape lineToX:80.0f y:60.0f];

    stroke.width = 30.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.lineJoin = kCGLineJoinRound;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"line-join-round"];
}

- (void)testLineJoinMiter
{
    PXPath *shape = [[PXPath alloc] init];
    PXStroke *stroke = [[PXStroke alloc] init];

    [shape moveToX:20.0f y:60.0f];
    [shape lineToX:50.0f y:20.0f];
    [shape lineToX:80.0f y:60.0f];

    stroke.width = 20.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.lineJoin = kCGLineJoinMiter;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"line-join-miter"];
}

- (void)testMiterLimit
{
    PXPath *shape = [[PXPath alloc] init];
    PXStroke *stroke = [[PXStroke alloc] init];

    [shape moveToX:20.0f y:60.0f];
    [shape lineToX:50.0f y:20.0f];
    [shape lineToX:80.0f y:60.0f];

    stroke.width = 20.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.lineJoin = kCGLineJoinMiter;
    stroke.miterLimit = 1.0f;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"line-join-miter-limit"];
}

- (void)testDashArray
{
    PXLine *shape = [[PXLine alloc] initX1:20.0f y1:50.0f x2:80.0f y2:50.0f];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 20.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.dashArray = @[@10.0f, @10.0f];
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"dash-array"];
}

- (void)testDashOffset
{
    PXLine *shape = [[PXLine alloc] initX1:20.0f y1:50.0f x2:80.0f y2:50.0f];
    PXStroke *stroke = [[PXStroke alloc] init];

    stroke.width = 20.0f;
    stroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    stroke.dashArray = @[@10.0f, @10.0f];
    stroke.dashOffset = 5.0f;
    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"dash-offset"];
}

- (void)testStrokeGroup
{
    PXLine *shape = [[PXLine alloc] initX1:10.0f y1:50.0f x2:90.0f y2:50.0f];
    PXStrokeGroup *stroke = [[PXStrokeGroup alloc] init];

    PXStroke *outsideStroke = [[PXStroke alloc] init];
    outsideStroke.width = 41.0f;
    outsideStroke.color = [PXSolidPaint paintWithColor:[UIColor redColor]];

    PXStroke *insideStroke = [[PXStroke alloc] init];
    insideStroke.width = 35.0f;
    insideStroke.color = [PXSolidPaint paintWithColor:[UIColor blackColor]];

    PXStroke *stripe = [[PXStroke alloc] init];
    stripe.width = 5.0f;
    stripe.color = [PXSolidPaint paintWithColor:[UIColor yellowColor]];
    stripe.dashArray = @[ @15, @8 ];

    [stroke addStroke:outsideStroke];
    [stroke addStroke:insideStroke];
    [stroke addStroke:stripe];

    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"stroke-group"];
}

- (void)testStrokeStroke
{
    PXLine *shape = [[PXLine alloc] initX1:10.0f y1:50.0f x2:90.0f y2:50.0f];
    PXStrokeStroke *stroke = [[PXStrokeStroke alloc] init];

    PXStroke *effect = [[PXStroke alloc] init];
    effect.width = 40.0f;
    effect.dashArray = @[ @15, @8 ];

    PXStroke *apply = [[PXStroke alloc] init];
    apply.width = 2.0f;
    apply.color = [PXSolidPaint paintWithColor:[UIColor redColor]];
    apply.dashArray = @[ @5, @5 ];

    stroke.strokeEffect = effect;
    stroke.strokeToApply = apply;

    shape.stroke = stroke;

    [self assertShape:shape equalsImageName:@"stroked-stroke"];
}

#pragma mark - Shadow Tests

- (void)testShadow
{
    PXCircle *shape = [PXCircle circleWithCenter:CGPointMake(50.0f, 50.0f) withRadius:40.0f];
    PXShadow *shadow = [[PXShadow alloc] init];

    shadow.horizontalOffset = 3.0f;
    shadow.verticalOffset = 3.0f;
    shadow.blurDistance = 3.0f;
    shape.shadow = shadow;
    shape.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:shape equalsImageName:@"shadow"];
}

/*
- (void)testShadow2
{
    PXShapeGroup *shape = [[PXShapeGroup alloc] init];

    PXCircle *circle1 = [PXCircle circleWithCenter:CGPointMake(30.0f, 50.0f) withRadius:25.0f];
    circle1.fill = [PXSolidPaint paintWithColor:[UIColor blueColor]];

    PXCircle *circle2 = [PXCircle circleWithCenter:CGPointMake(70.0f, 50.0f) withRadius:25.0f];
    circle2.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    PXShadow *shadow = [[PXShadow alloc] init];
    shadow.horizontalOffset = 3.0f;
    shadow.verticalOffset = 3.0f;
    shadow.blurDistance = 3.0f;

    [shape addShape:circle1];
    [shape addShape:circle2];
    shape.shadow = shadow;

    [self assertShape:shape equalsImageName:@"shadow-group"];
}
*/

#pragma mark - Box Model Tests

- (void)testBoxModel
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(10, 10, 80, 80)];

    [box setBorderWidth:10.0f];
    [box setBorderStyle:PXBorderStyleSolid];

    box.borderTopPaint = [PXSolidPaint paintWithColor:[UIColor orangeColor]];
    box.borderRightPaint = [PXSolidPaint paintWithColor:[UIColor blueColor]];
    box.borderBottomPaint = [PXSolidPaint paintWithColor:[UIColor purpleColor]];
    box.borderLeftPaint = [PXSolidPaint paintWithColor:[UIColor greenColor]];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model"];
}

- (void)testBoxModelUneven
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(40, 10, 40, 60)];

    [box setBorderTopPaint:[PXSolidPaint paintWithColor:[UIColor orangeColor]] width:10.0f style:PXBorderStyleSolid];
    [box setBorderRightPaint:[PXSolidPaint paintWithColor:[UIColor blueColor]] width:20.0f style:PXBorderStyleSolid];
    [box setBorderBottomPaint:[PXSolidPaint paintWithColor:[UIColor purpleColor]] width:30.0f style:PXBorderStyleSolid];
    [box setBorderLeftPaint:[PXSolidPaint paintWithColor:[UIColor greenColor]] width:40.0f style:PXBorderStyleSolid];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-uneven"];
}

- (void)testBoxModelTriangle
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(50, 50, 0, 0)];

    [box setBorderTopPaint:[PXSolidPaint paintWithColor:[UIColor clearColor]] width:50.0f style:PXBorderStyleSolid];
    [box setBorderBottomPaint:[PXSolidPaint paintWithColor:[UIColor clearColor]] width:50.0f style:PXBorderStyleSolid];
    [box setBorderLeftPaint:[PXSolidPaint paintWithColor:[UIColor greenColor]] width:50.0f style:PXBorderStyleSolid];

    [self assertShape:box equalsImageName:@"box-model-triangle"];
}

- (void)testBoxModelDashedTop
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(0, 5, 100, 95)];

    [box setBorderTopPaint:[PXSolidPaint paintWithColor:[UIColor orangeColor]] width:5.0f style:PXBorderStyleDashed];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-dashed-top"];
}

- (void)testBoxModelDashedRight
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(0, 0, 95, 100)];

    [box setBorderRightPaint:[PXSolidPaint paintWithColor:[UIColor blueColor]] width:5.0f style:PXBorderStyleDashed];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-dashed-right"];
}

- (void)testBoxModelDashedBottom
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(0, 0, 100, 95)];

    [box setBorderBottomPaint:[PXSolidPaint paintWithColor:[UIColor purpleColor]] width:5.0f style:PXBorderStyleDashed];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-dashed-bottom"];
}

- (void)testBoxModelDashedLeft
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(5, 0, 95, 100)];

    [box setBorderLeftPaint:[PXSolidPaint paintWithColor:[UIColor greenColor]] width:5.0f style:PXBorderStyleDashed];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-dashed-left"];
}

- (void)testBoxModelDashedAll
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(5, 5, 90, 90)];

    [box setBorderTopPaint:[PXSolidPaint paintWithColor:[UIColor orangeColor]] width:5.0f style:PXBorderStyleDashed];
    [box setBorderRightPaint:[PXSolidPaint paintWithColor:[UIColor blueColor]] width:5.0f style:PXBorderStyleDashed];
    [box setBorderBottomPaint:[PXSolidPaint paintWithColor:[UIColor purpleColor]] width:5.0f style:PXBorderStyleDashed];
    [box setBorderLeftPaint:[PXSolidPaint paintWithColor:[UIColor greenColor]] width:5.0f style:PXBorderStyleDashed];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-dashed-all"];
}

- (void)testBoxModelDottedTop
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(0, 5, 100, 95)];

    [box setBorderTopPaint:[PXSolidPaint paintWithColor:[UIColor orangeColor]] width:5.0f style:PXBorderStyleDotted];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-dotted-top"];
}

- (void)testBoxModelDottedRight
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(0, 0, 95, 100)];

    [box setBorderRightPaint:[PXSolidPaint paintWithColor:[UIColor blueColor]] width:5.0f style:PXBorderStyleDotted];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-dotted-right"];
}

- (void)testBoxModelDottedBottom
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(0, 0, 100, 95)];

    [box setBorderBottomPaint:[PXSolidPaint paintWithColor:[UIColor purpleColor]] width:5.0f style:PXBorderStyleDotted];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-dotted-bottom"];
}

- (void)testBoxModelDottedLeft
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(5, 0, 95, 100)];

    [box setBorderLeftPaint:[PXSolidPaint paintWithColor:[UIColor greenColor]] width:5.0f style:PXBorderStyleDotted];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-dotted-left"];
}

- (void)testBoxModelDottedAll
{
    PXBoxModel *box = [[PXBoxModel alloc] initWithBounds:CGRectMake(5, 5, 90, 90)];

    [box setBorderTopPaint:[PXSolidPaint paintWithColor:[UIColor orangeColor]] width:5.0f style:PXBorderStyleDotted];
    [box setBorderRightPaint:[PXSolidPaint paintWithColor:[UIColor blueColor]] width:5.0f style:PXBorderStyleDotted];
    [box setBorderBottomPaint:[PXSolidPaint paintWithColor:[UIColor purpleColor]] width:5.0f style:PXBorderStyleDotted];
    [box setBorderLeftPaint:[PXSolidPaint paintWithColor:[UIColor greenColor]] width:5.0f style:PXBorderStyleDotted];

    box.fill = [PXSolidPaint paintWithColor:[UIColor redColor]];

    [self assertShape:box equalsImageName:@"box-model-dotted-all"];
}

#pragma mark - Paint Tests

- (void)testLightenSolidPaint
{
    PXSolidPaint *paint1 = [[PXSolidPaint alloc] initWithColor:[UIColor colorWithRed:0.25 green:0.5 blue:0.25 alpha:1.0]];
    PXSolidPaint *paint2 = [paint1 lightenByPercent:20];

    PXRectangle *rectangle1 = [[PXRectangle alloc] initWithRect:CGRectMake(10, 10, 80, 40)];
    PXRectangle *rectangle2 = [[PXRectangle alloc] initWithRect:CGRectMake(10, 55, 80, 40)];

    rectangle1.fill = paint1;
    rectangle2.fill = paint2;

    PXShapeGroup *group = [[PXShapeGroup alloc] init];
    [group addShape:rectangle1];
    [group addShape:rectangle2];

    [self assertShape:group equalsImageName:@"solid-paint-lighten"];
}

- (void)testDarkenSolidPaint
{
    PXSolidPaint *paint1 = [[PXSolidPaint alloc] initWithColor:[UIColor colorWithRed:0.25 green:0.5 blue:0.25 alpha:1.0]];
    PXSolidPaint *paint2 = [paint1 darkenByPercent:20];

    PXRectangle *rectangle1 = [[PXRectangle alloc] initWithRect:CGRectMake(10, 10, 80, 40)];
    PXRectangle *rectangle2 = [[PXRectangle alloc] initWithRect:CGRectMake(10, 55, 80, 40)];

    rectangle1.fill = paint1;
    rectangle2.fill = paint2;

    PXShapeGroup *group = [[PXShapeGroup alloc] init];
    [group addShape:rectangle1];
    [group addShape:rectangle2];

    [self assertShape:group equalsImageName:@"solid-paint-darken"];
}

- (void)testLightenLinearGradient
{
    PXLinearGradient *paint1 = [PXLinearGradient gradientFromStartColor:[UIColor colorWithRed:0.25 green:0.5 blue:0.25 alpha:1.0]
                                                               endColor:[UIColor colorWithRed:0.5 green:0.75 blue:0.5 alpha:1.0]];
    PXLinearGradient *paint2 = [paint1 lightenByPercent:20];

    PXRectangle *rectangle1 = [[PXRectangle alloc] initWithRect:CGRectMake(10, 10, 80, 40)];
    PXRectangle *rectangle2 = [[PXRectangle alloc] initWithRect:CGRectMake(10, 55, 80, 40)];

    rectangle1.fill = paint1;
    rectangle2.fill = paint2;

    PXShapeGroup *group = [[PXShapeGroup alloc] init];
    [group addShape:rectangle1];
    [group addShape:rectangle2];

    [self assertShape:group equalsImageName:@"linear-gradient-lighten"];
}

- (void)testDarkenLinearGradient
{
    PXLinearGradient *paint1 = [PXLinearGradient gradientFromStartColor:[UIColor colorWithRed:0.25 green:0.5 blue:0.25 alpha:1.0]
                                                               endColor:[UIColor colorWithRed:0.5 green:0.75 blue:0.5 alpha:1.0]];
    PXLinearGradient *paint2 = [paint1 darkenByPercent:20];

    PXRectangle *rectangle1 = [[PXRectangle alloc] initWithRect:CGRectMake(10, 10, 80, 40)];
    PXRectangle *rectangle2 = [[PXRectangle alloc] initWithRect:CGRectMake(10, 55, 80, 40)];

    rectangle1.fill = paint1;
    rectangle2.fill = paint2;

    PXShapeGroup *group = [[PXShapeGroup alloc] init];
    [group addShape:rectangle1];
    [group addShape:rectangle2];

    [self assertShape:group equalsImageName:@"linear-gradient-darken"];

}

- (void)testLightenRadialGradient
{
    // TODO:
}

- (void)testDarkenRadialGradient
{
    // TODO:
}

@end
