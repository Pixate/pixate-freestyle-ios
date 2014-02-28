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
//  PXNonScalingStroke.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/26/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXNonScalingStroke.h"
#import "PXMath.h"

@implementation PXNonScalingStroke

#pragma mark - Overrides

-(void)applyStrokeToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    if (self.color && self.width > 0.0)
    {
        //
        // | a  b  0 |
        // | c  d  0 |
        // | tx ty 1 |
        //
        CGAffineTransform transform = CGContextGetCTM(context);

        //       ___________
        // sx = √ a^2 + c^2
        //       ___________
        // sy = √ b^2 + d^2
        //
        CGFloat sx = SQRT(transform.a*transform.a + transform.c*transform.c);
        CGFloat sy = SQRT(transform.b*transform.b + transform.d*transform.d);

        // uses the largest scale, in case the scale is non-homogeneous
        CGFloat maxScale = MAX(sx, sy);

        // save scale so we can restore it
        CGFloat originalWidth = self.width;

        // scale stroke width based on max scale we calculated above
        self.width /= maxScale;

        // render
        [super applyStrokeToPath:path withContext:context];

        // restore original stroke width
        self.width = originalWidth;
    }
}

@end
