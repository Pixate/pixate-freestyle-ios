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
//  PXFontRegistry.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/21/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  PXFontRegistry is a singleton reponsible for mapping a font family, style, and weight to a specific instance of a
 *  UIFont. Fallback mechnanisms are used when a specific configuration is not available. All lookups are cached, so
 *  future lookups are quite fast.
 */
@interface PXFontRegistry : NSObject

/**
 *  Clear the font registry cache.
 *
 *  This method is mostly used for testing, but it may be used to reduce memory footprint during low memory conditions
 */
+ (void)clearRegistry;

/**
 *  Return a UIFont instance for the specified font family, style, weight, and size.
 *
 *  @param family The font family name. If this parameter is nil, then the system font family will be used
 *  @param stretch The stretch of the font.
 *  @param weight The weight of the font.
 *  @param style The style of the font. If this parameter is nil, then the "normal" style will be used
 *  @param size The point size of the font.
 */
+ (UIFont *)fontWithFamily:(NSString *)family
               fontStretch:(NSString *)stretch
                fontWeight:(NSString *)weight
                 fontStyle:(NSString *)style
                      size:(CGFloat)size;


+ (void)loadFontFromURL:(NSURL *)URL;

@end
