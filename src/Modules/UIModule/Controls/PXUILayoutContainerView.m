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
//  PXUILayoutContainerView.m
//  Pixate
//
//  Created by Paul Colton on 2/21/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXUILayoutContainerView.h"
#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXUtils.h"
#import "objc.h"
#import "PXViewUtils.h"

@implementation PXUILayoutContainerView

/* DISABLED
 + (void)initialize
{
    if (self != PXUILayoutContainerView.class)
        return;
 
    [UIView registerDynamicSubclass:self
                           forClass:[PXUILayoutContainerView targetSuperclass]
                    withElementName:@"layout-container-view"];
}

+ (Class)targetSuperclass
{
	static Class targetSuperclass = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		targetSuperclass = //[PXUtils isIOS6OrGreater] ?
        NSClassFromString([[self description] substringFromIndex:2])
        //: nil
        ;
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
