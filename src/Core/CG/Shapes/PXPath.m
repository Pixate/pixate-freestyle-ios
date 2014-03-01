/*
 * Copyright 2012-present Pixate, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  PXPath.m
//  Pixate
//
//  Created by Kevin Lindsey on 5/31/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXPath.h"
#import "PXEllipticalArc.h"
#import "NSScanner+PXFloat.h"
#import "PixateFreestyle.h"
#import "PXMath.h"
#import "PXVector.h"

@implementation PXPath
{
    CGMutablePathRef pathPath;
}

#pragma mark - Static Methods

+ (PXPath *)createPathFromPathData:(NSString *)data
{
    PXPath *path = [[PXPath alloc] init];

    NSScanner *scanner = [NSScanner scannerWithString:data];
    NSCharacterSet *skipSet = [NSCharacterSet characterSetWithCharactersInString:@" \r\n,"];
    [scanner setCharactersToBeSkipped:skipSet];

    NSCharacterSet *commandSet = [NSCharacterSet characterSetWithCharactersInString:@"MmLlCcHhVvQqAaSsTtZz"];
    NSString *command;
    unichar lastCommand = '\0';
    CGFloat firstX, firstY;
    CGFloat lastX, lastY;
    CGFloat lastHandleX, lastHandleY;
    CGFloat x1, y1, x2, y2, x3, y3;

    while ([scanner isAtEnd] == NO)
    {
        unichar ch;

        if ([scanner scanCharactersFromSet:commandSet intoString:&command] == YES)
        {
            ch = [command characterAtIndex:0];

            if (command.length > 1)
            {
                scanner.scanLocation = scanner.scanLocation - (command.length - 1);
            }
        }
        else
        {
            ch = lastCommand;
        }

        switch (ch)
        {
            case 'A':
            {
                CGFloat rx, ry, xAxisRotation, largeArcFlag, sweepFlag;

                [scanner scanCGFloat:&rx];
                [scanner scanCGFloat:&ry];
                [scanner scanCGFloat:&xAxisRotation];
                [scanner scanCGFloat:&largeArcFlag];
                [scanner scanCGFloat:&sweepFlag];
                [scanner scanCGFloat:&x1];
                [scanner scanCGFloat:&y1];

                [path ellipticalArcRadiusX:rx radiusY:ry xAxisRotation:xAxisRotation largeArcFlag:(largeArcFlag > 0.0) sweepFlag:(sweepFlag > 0.0) x:x1 y:y1];

                lastCommand = ch;
                lastX = x1;
                lastY = y1;
                break;
            }

            case 'a':
            {
                CGFloat rx, ry, xAxisRotation, largeArcFlag, sweepFlag;

                [scanner scanCGFloat:&rx];
                [scanner scanCGFloat:&ry];
                [scanner scanCGFloat:&xAxisRotation];
                [scanner scanCGFloat:&largeArcFlag];
                [scanner scanCGFloat:&sweepFlag];
                [scanner scanCGFloat:&x1];
                [scanner scanCGFloat:&y1];

                x1 += lastX;
                y1 += lastY;

                [path ellipticalArcRadiusX:rx radiusY:ry xAxisRotation:xAxisRotation largeArcFlag:(largeArcFlag > 0.0) sweepFlag:(sweepFlag > 0.0) x:x1 y:y1];

                lastCommand = ch;
                lastX = x1;
                lastY = y1;
                break;
            }

            case 'C':
                [scanner scanCGFloat:&x1];
                [scanner scanCGFloat:&y1];
                [scanner scanCGFloat:&x2];
                [scanner scanCGFloat:&y2];
                [scanner scanCGFloat:&x3];
                [scanner scanCGFloat:&y3];
                //NSLog(@"cubicto %f,%f,%f,%f,%f,%f", x1, y1, x2, y2, x3, y3);

                [path cubicBezierToX1:x1 y1:y1 x2:x2 y2:y2 x3:x3 y3:y3];

                lastCommand = ch;
                lastHandleX = x2;
                lastHandleY = y2;
                lastX = x3;
                lastY = y3;
                break;

            case 'c':
                [scanner scanCGFloat:&x1];
                [scanner scanCGFloat:&y1];
                [scanner scanCGFloat:&x2];
                [scanner scanCGFloat:&y2];
                [scanner scanCGFloat:&x3];
                [scanner scanCGFloat:&y3];
                //NSLog(@"rcubicto %f,%f,%f,%f,%f,%f", x1, y1, x2, y2, x3, y3);

                x1 += lastX;
                y1 += lastY;
                x2 += lastX;
                y2 += lastY;
                x3 += lastX;
                y3 += lastY;

                [path cubicBezierToX1:x1 y1:y1 x2:x2 y2:y2 x3:x3 y3:y3];

                lastCommand = ch;
                lastHandleX = x2;
                lastHandleY = y2;
                lastX = x3;
                lastY = y3;
                break;

            case 'H':
                [scanner scanCGFloat:&x1];
                //NSLog(@"horiz %f", x1);

                [path lineToX:x1 y:lastY];

                lastCommand = ch;
                lastX = x1;
                break;

            case 'h':
                [scanner scanCGFloat:&x1];
                //NSLog(@"rhoriz %f", x1);

                x1 += lastX;

                [path lineToX:x1 y:lastY];

                lastCommand = ch;
                lastX = x1;
                break;

            case 'L':
                [scanner scanCGFloat:&x1];
                [scanner scanCGFloat:&y1];
                //NSLog(@"lineto %f,%f", x1, y1);

                [path lineToX:x1 y:y1];

                lastCommand = ch;
                lastX = x1;
                lastY = y1;
                break;

            case 'l':
                [scanner scanCGFloat:&x1];
                [scanner scanCGFloat:&y1];
                //NSLog(@"rlineto %f,%f", x1, y1);

                x1 += lastX;
                y1 += lastY;

                [path lineToX:x1 y:y1];

                lastCommand = ch;
                lastX = x1;
                lastY = y1;
                break;

            case 'M':
                [scanner scanCGFloat:&x1];
                [scanner scanCGFloat:&y1];
                //NSLog(@"moveto %f,%f", x1, y1);

                [path moveToX:x1 y:y1];

                lastCommand = 'L';
                lastX = x1;
                lastY = y1;
                firstX = x1;
                firstY = y1;
                break;

            case 'm':
                [scanner scanCGFloat:&x1];
                [scanner scanCGFloat:&y1];
                //NSLog(@"rmoveto %f,%f", x1, y1);

                x1 += lastX;
                y1 += lastY;

                [path moveToX:x1 y:y1];

                lastCommand = 'l';
                lastX = x1;
                lastY = y1;
                firstX = x1;
                firstY = y1;
                break;

            case 'Q':
                [scanner scanCGFloat:&x1];
                [scanner scanCGFloat:&y1];
                [scanner scanCGFloat:&x2];
                [scanner scanCGFloat:&y2];
                //NSLog(@"quadto %f,%f,%f,%f", x1, y1, x2, y2);

                [path quadraticBezierToX1:x1 y1:y1 x2:x2 y2:y2];

                lastCommand = ch;
                lastHandleX = x1;
                lastHandleY = y1;
                lastX = x2;
                lastY = y2;
                break;

            case 'q':
                [scanner scanCGFloat:&x1];
                [scanner scanCGFloat:&y1];
                [scanner scanCGFloat:&x2];
                [scanner scanCGFloat:&y2];
                //NSLog(@"rquadto %f,%f,%f,%f", x1, y1, x2, y2);

                x1 += lastX;
                y1 += lastY;
                x2 += lastX;
                y2 += lastY;

                [path quadraticBezierToX1:x1 y1:y1 x2:x2 y2:y2];

                lastCommand = ch;
                lastHandleX = x1;
                lastHandleY = y1;
                lastX = x2;
                lastY = y2;
                break;

            case 'S':
                [scanner scanCGFloat:&x2];
                [scanner scanCGFloat:&y2];
                [scanner scanCGFloat:&x3];
                [scanner scanCGFloat:&y3];
                //NSLog(@"scubicto %f,%f,%f,%f", x2, y2, x3, y3);

                switch (lastCommand) {
                    case 'S':
                    case 's':
                    case 'C':
                    case 'c':
                        x1 = 2.0 * lastX - lastHandleX;
                        y1 = 2.0 * lastY - lastHandleY;
                        break;

                    default:
                        x1 = lastX;
                        y1 = lastY;
                        break;
                }

                [path cubicBezierToX1:x1 y1:y1 x2:x2 y2:y2 x3:x3 y3:y3];

                lastCommand = ch;
                lastHandleX = x2;
                lastHandleY = y2;
                lastX = x3;
                lastY = y3;
                break;

            case 's':
                [scanner scanCGFloat:&x2];
                [scanner scanCGFloat:&y2];
                [scanner scanCGFloat:&x3];
                [scanner scanCGFloat:&y3];
                //NSLog(@"rscubicto %f,%f,%f,%f", x2, y2, x3, y3);

                switch (lastCommand) {
                    case 'S':
                    case 's':
                    case 'C':
                    case 'c':
                        x1 = 2.0 * lastX - lastHandleX;
                        y1 = 2.0 * lastY - lastHandleY;
                        break;

                    default:
                        x1 = lastX;
                        y1 = lastY;
                }
                x2 += lastX;
                y2 += lastY;
                x3 += lastX;
                y3 += lastY;

                [path cubicBezierToX1:x1 y1:y1 x2:x2 y2:y2 x3:x3 y3:y3];

                lastCommand = ch;
                lastHandleX = x2;
                lastHandleY = y2;
                lastX = x3;
                lastY = y3;
                break;

            case 'T':
                [scanner scanCGFloat:&x2];
                [scanner scanCGFloat:&y2];
                //NSLog(@"squadto %f,%f", x2, y2);

                switch (lastCommand) {
                    case 'Q':
                    case 'q':
                    case 'T':
                    case 't':
                        x1 = 2.0 * lastX - lastHandleX;
                        y1 = 2.0 * lastY - lastHandleY;
                        break;

                    default:
                        x1 = lastX;
                        y1 = lastY;
                        break;
                }

                [path quadraticBezierToX1:x1 y1:y1 x2:x2 y2:y2];

                lastCommand = ch;
                lastHandleX = x1;
                lastHandleY = y1;
                lastX = x2;
                lastY = y2;
                break;

            case 't':
                [scanner scanCGFloat:&x2];
                [scanner scanCGFloat:&y2];
                //NSLog(@"rsquadto %f,%f", x2, y2);

                switch (lastCommand) {
                    case 'Q':
                    case 'q':
                    case 'T':
                    case 't':
                        x1 = 2.0 * lastX - lastHandleX;
                        y1 = 2.0 * lastY - lastHandleY;
                        break;

                    default:
                        x1 = lastX;
                        y1 = lastY;
                        break;
                }
                x2 += lastX;
                y2 += lastY;

                [path quadraticBezierToX1:x1 y1:y1 x2:x2 y2:y2];

                lastCommand = ch;
                lastHandleX = x1;
                lastHandleY = y1;
                lastX = x2;
                lastY = y2;
                break;

            case 'V':
                [scanner scanCGFloat:&y1];
                //NSLog(@"vert %f", x1);

                [path lineToX:lastX y:y1];

                lastCommand = ch;
                lastY = y1;
                break;

            case 'v':
                [scanner scanCGFloat:&y1];
                //NSLog(@"rvert %f", x1);

                y1 += lastY;

                [path lineToX:lastX y:y1];

                lastCommand = ch;
                lastY = y1;
                break;

            case 'Z':
                //NSLog(@"close");
                [path close];

                lastCommand = '\0';
                lastX = firstX;
                lastY = firstY;
                break;

            case 'z':
                //NSLog(@"close");
                [path close];

                lastCommand = '\0';
                lastX = firstX;
                lastY = firstY;
                break;

            default:
            {
                NSString *message = [NSString stringWithFormat:@"Unrecognized or missing path command at offset: %lu", (unsigned long)scanner.scanLocation];

                // report error
                [PixateFreestyle.configuration sendParseMessage:message];

                // stop scanning
                scanner.scanLocation = data.length;
                break;
            }
        }
    }

    return path;
}

#pragma mark - Initializers

- (id)init
{
    self = [super init];

    if (self)
    {
        pathPath = CGPathCreateMutable();
    }

    return self;
}

#pragma mark - Methods

- (void)close
{
    //NSLog(@"z");
    CGPathCloseSubpath(pathPath);
    [self clearPath];
}

- (void)ellipticalArcX:(CGFloat)x y:(CGFloat)y radiusX:(CGFloat)radiusX radiusY:(CGFloat)radiusY startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    CGPathAddEllipticalArc(pathPath, NULL, x, y, radiusX, radiusY, startAngle, endAngle);
    [self clearPath];
}

- (void)ellipticalArcRadiusX:(CGFloat)rx radiusY:(CGFloat)ry xAxisRotation:(CGFloat)xAxisRotation largeArcFlag:(BOOL)largeArcFlag sweepFlag:(BOOL)sweepFlag x:(CGFloat)x y:(CGFloat)y
{
    CGPoint lastPoint = CGPathGetCurrentPoint(pathPath);

    CGFloat cx, cy;
    CGFloat startAngle, sweepAngle, endAngle;

    if ( rx != 0.0 || ry != 0.0 )
    {
        CGFloat halfDx  = (lastPoint.x - x) * 0.5;
        CGFloat halfDy  = (lastPoint.y - y) * 0.5;
        CGFloat radians = DEGREES_TO_RADIANS(xAxisRotation);
        CGFloat cosine  = COS(radians);
        CGFloat sine    = SIN(radians);
        CGFloat x1p     = halfDx *  cosine + halfDy * sine;
        CGFloat y1p     = halfDx * -sine   + halfDy * cosine;
        CGFloat x1px1p  = x1p*x1p;
        CGFloat y1py1p  = y1p*y1p;
        CGFloat lambda  = (x1px1p/(rx*rx)) + (y1py1p/(ry*ry));

        // it may be impossible for the specified radii to describe
        // an ellipse passing through the previous point and end point.
        // Adjust radii, if necessary, so ellipse can pass through those
        // points.
        if ( lambda > 1.0 )
        {
            CGFloat factor = SQRT(lambda);

            rx *= factor;
            ry *= factor;
        }

        CGFloat rxrx = rx*rx;
        CGFloat ryry = ry*ry;
        CGFloat rxrxryry = rxrx*ryry;
        CGFloat rxrxy1py1p = rxrx*y1py1p;
        CGFloat ryryx1px1p = ryry*x1px1p;
        CGFloat numerator = rxrxryry - rxrxy1py1p - ryryx1px1p;
        CGFloat s;

        if ( numerator < 1e-6 )
        {
            s = 0.0;
        }
        else
        {
            s = SQRT(numerator / (rxrxy1py1p + ryryx1px1p));
        }
        if ( largeArcFlag == sweepFlag )
        {
            s = -s;
        }
        CGFloat cxp = s *  rx*y1p / ry;
        CGFloat cyp = s * -ry*x1p / rx;
        cx  = cxp * cosine - cyp * sine   + (lastPoint.x + x) * 0.5;
        cy  = cxp * sine   + cyp * cosine + (lastPoint.y + y) * 0.5;

        PXVector *u = [PXVector vectorWithX:1.0 Y:0.0];
        // NOTE: SVG spec divides x-component by rx and y-component by ry
        PXVector *v = [PXVector vectorWithX:(x1p - cxp) Y:(y1p - cyp)];
        PXVector *w = [PXVector vectorWithX:(-x1p - cxp) Y:(-y1p - cyp)];

        startAngle = [u angleBetweenVector:v];
        sweepAngle = [v angleBetweenVector:w];

        if ( !sweepFlag && sweepAngle > 0.0 )
        {
            sweepAngle -= TWO_PI;
        }
        else if ( sweepFlag && sweepAngle < 0.0 )
        {
            sweepAngle += TWO_PI;
        }

        endAngle = startAngle + sweepAngle;

        [self ellipticalArcX:cx y:cy radiusX:rx radiusY:ry startAngle:startAngle endAngle:endAngle];
    }
}

- (void)cubicBezierToX1:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2 x3:(CGFloat)x3 y3:(CGFloat)y3
{
    //NSLog(@"C%f,%f %f,%f %f,%f", x1, y1, x2, y2, x3, y3);
    CGPathAddCurveToPoint(pathPath, NULL, x1, y1, x2, y2, x3, y3);
    [self clearPath];
}

- (void)lineToX:(CGFloat)x y:(CGFloat)y;
{
    //NSLog(@"L%f,%f ", x, y);
    CGPathAddLineToPoint(pathPath, NULL, x, y);
    [self clearPath];
}

- (void)moveToX:(CGFloat)x y:(CGFloat)y;
{
    //NSLog(@"M%f,%f ", x, y);
    CGPathMoveToPoint(pathPath, NULL, x, y);
    [self clearPath];
}

- (void)quadraticBezierToX1:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2
{
    //NSLog(@"Q%f,%f %f,%f ", x1, y1, x2, y2);
    CGPathAddQuadCurveToPoint(pathPath, NULL, x1, y1, x2, y2);
    [self clearPath];
}

#pragma mark - Overrides

- (CGPathRef)newPath
{
    return CGPathCreateCopy(pathPath);
}

- (void)dealloc
{
    if (pathPath)
    {
        CGPathRelease(pathPath);
        pathPath = nil;
    }
}

@end
