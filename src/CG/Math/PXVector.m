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
//  PXVector.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXVector.h"
#import "PXMath.h"

@implementation PXVector

@synthesize x, y;

#pragma mark - Static Initializers

+ (id)vectorWithX:(CGFloat)x Y:(CGFloat)y
{
    return [[PXVector alloc] initWithX:x Y:y];
}

+ (id)vectorWithStartPoint:(CGPoint)p1 EndPoint:(CGPoint)p2
{
    return [PXVector vectorWithX:p2.x - p1.x Y:p2.y - p1.y];
}

#pragma mark - Initializers

- (id)init
{
    return [self initWithX:0 Y:0];
}

- (id)initWithX:(CGFloat)anX Y:(CGFloat)aY
{
    if (self = [super init])
    {
        self->x = anX;
        self->y = aY;
    }

    return self;
}

#pragma mark - Getters

- (CGFloat)angle
{
    CGFloat result = ATAN2(self.y, self.x);

    return (result >= 0) ? result : result + 2 * M_PI;
}

- (CGFloat)length
{
    return SQRT(self.magnitude);
}

- (CGFloat)magnitude
{
    return x*x + y*y;
}

- (PXVector *)perp
{
    return [PXVector vectorWithX:-y Y:x];
}

- (PXVector *)unit
{
    return [self divide:self.length];
}

#pragma mark - Methods

- (CGFloat)angleBetweenVector:(PXVector *)that
{
    //CGFloat cosTheta = [self dot:that] / (self.magnitude * that.magnitude);
    //
    //return acosf(cosTheta);
    return ATAN2(that.y, that.x) - ATAN2(self.y, self.x);
}

- (CGFloat)dot:(PXVector *)that
{
    return self->x*that->x + self->y*that->y;
}

- (CGFloat)cross:(PXVector *)that
{
    return self->x*that->y - self->y*that->x;
}

- (PXVector *)add:(PXVector *)that
{
    return [PXVector vectorWithX:self->x + that->x Y:self->y + that->y];
}

- (PXVector *)subtract:(PXVector *)that
{
    return [PXVector vectorWithX:self->x - that->x Y:self->y - that->y];
}

- (PXVector *)divide:(CGFloat)scalar
{
    return [PXVector vectorWithX:self->x / scalar Y:self->y / scalar];
}

- (PXVector *)multiply:(CGFloat)scalar
{
    return [PXVector vectorWithX:self->x * scalar Y:self->y * scalar];
}

- (PXVector *)perpendicular:(PXVector *)that
{
    return [self subtract:[self projectOnto:that]];
}

- (PXVector *)projectOnto:(PXVector *)that
{
    CGFloat percent = [self dot:that] / that.magnitude;

    return [that multiply:percent];
}

#pragma mark - Overrides

-(NSString *)description
{
    return [NSString stringWithFormat:@"Vector(x=%f,y=%f)", x, y];
}

@end
