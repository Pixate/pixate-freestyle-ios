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
//  PXMKAnnotationContainerView.m
//  Pixate
//
//  Created by Paul Colton on 11/29/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXMKAnnotationContainerView.h"
#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXUtils.h"
#import "objc.h"

@implementation PXMKAnnotationContainerView

/* DISABLED
+ (void)initialize
{
    if (self != PXMKAnnotationContainerView.class)
        return;
 
    [UIView registerDynamicSubclass:self
                           forClass:[PXMKAnnotationContainerView targetSuperclass]
                    withElementName:@"annotation-container-view"];
}

+ (Class)targetSuperclass
{
	static Class targetSuperclass = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		targetSuperclass = NSClassFromString([[self description] substringFromIndex:2]);
	});
	return targetSuperclass;
}

- (void)layoutSubviews
{
	callSuper0(self, [self pxClass], _cmd);
    [self updateStyles];
}
*/

@end
