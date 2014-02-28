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
//  PXShadowPaint.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The PXShadowPaint protocol specifies the properties and methods required for a class to be used for shadowing of a
 *  contour
 */
@protocol PXShadowPaint <NSObject>

/**
 *  Apply an outer shadow to the specified path
 *
 *  @param path A path used to generate a shadow
 *  @param context The context into which to render the shadow
 */
- (void)applyOutsetToPath:(CGPathRef)path withContext:(CGContextRef)context;

/**
 *  Apply an inner shadow to the specified path
 *
 *  @param path A path used to generate a shadow
 *  @param context The context into which to render the shadow
 */
- (void)applyInsetToPath:(CGPathRef)path withContext:(CGContextRef)context;

@end
