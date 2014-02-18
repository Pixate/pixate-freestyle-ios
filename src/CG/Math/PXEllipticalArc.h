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
//  PXEllipticalArc.h
//  Pixate
//
//  Created by Kevin Lindsey on 3/27/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

void CGPathAddEllipticalArc(CGMutablePathRef path, const CGAffineTransform *m, CGFloat x, CGFloat y, CGFloat radiusX, CGFloat radiusY, CGFloat startAngle, CGFloat endAngle);

@interface PXEllipticalArc : NSObject

- (id)initWithCx:(CGFloat)cx cy:(CGFloat)cy radiusX:(CGFloat)a radiusY:(CGFloat)b startingAngle:(CGFloat)lambda1 endingAngle:(CGFloat)lambda2;

- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform)transform;

@end
