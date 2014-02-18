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
//  NSMutableDictionary+PXObject.h
//  Pixate
//
//  Created by Kevin Lindsey on 3/26/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (PXObject)

- (void)setNilableObject:(id)object forKey:(id<NSCopying>)key;
- (void)setRect:(CGRect)rect forKey:(id<NSCopying>)key;
- (void)setFloat:(CGFloat)floatValue forKey:(id<NSCopying>)key;
- (void)setColorRef:(CGColorRef)colorRef forKey:(id<NSCopying>)key;
- (void)setSize:(CGSize)size forKey:(id<NSCopying>)key;
- (void)setBoolean:(BOOL)booleanValue forKey:(id<NSCopying>)key;
- (void)setTransform:(CGAffineTransform)transform forKey:(id<NSCopying>)key;
- (void)setInsets:(UIEdgeInsets)insets forKey:(id<NSCopying>)key;
- (void)setLineBreakMode:(NSLineBreakMode)mode forKey:(id<NSCopying>)key;
- (void)setTextAlignment:(NSTextAlignment)alignment forKey:(id<NSCopying>)key;

@end
