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
//  UIView+PXStyling-Private.h
//
//  Created by Paul Colton on 12/13/12
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PXStylingPrivate)

+ (void)setElementName:(NSString *)elementName forClass:(Class)class;
+ (NSString *)elementNameForClassName:(NSString *)className;
+ (void)removeElementNameForClassName:(NSString *)className;
+ (void)addStylingSubclass:(NSString *)className;
+ (BOOL)hasStylingSubclass:(NSString *)className;
+ (void)removeStylingSubclass:(NSString *)className;
+ (void)registerDynamicSubclass:(Class)subclass withElementName:(NSString *)elementName;
+ (void)registerDynamicSubclass:(Class)subclass forClass:(Class)superClass withElementName:(NSString *)elementName;

+ (BOOL)subclassIfNeeded:(Class)superClass object:(NSObject *)object;

+ (BOOL)pxHasAncestor:(Class)acenstorClass forView:(UIView *)view;

//- (void)applyStyleMode:(PXStylingMode)mode;
- (BOOL)isSubclassable;

@end
