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
//  PXUIPickerView.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUIPickerView.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"

#import "PXOpacityStyler.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXAnimationStyler.h"
#import "PXProxy.h"

#import "PXUIPickerViewDelegate.h"

//static const char PX_DELEGATE; // the new delegate (and datasource)
//static const char PX_DELEGATE_PROXY; // the proxy for the old delegate
//static const char PX_DATASOURCE_PROXY; // the proxy for the old datasource

@implementation PXUIPickerView

+ (void)initialize
{
    if (self != PXUIPickerView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"picker-view"];
}

#pragma mark - Delegate and DataSource proxy methods

/** DO NOT USE FOR NOW, DOESN'T PLAY WELL WITH UIDatePicker
 
//
// Overrides for delegate and datasource
//

-(void)setDelegate:(id<UIPickerViewDelegate>)delegate
{
    id delegateProxy = [self pxDelegateProxy];
    [delegateProxy setBaseObject:delegate];
    callSuper1(SUPER_PREFIX, @selector(setDelegate:), delegateProxy);
}

-(void)setDataSource:(id<UIPickerViewDataSource>)dataSource
{
    id datasourceProxy = [self pxDatasourceProxy];
    [datasourceProxy setBaseObject:dataSource];
    callSuper1(SUPER_PREFIX, @selector(setDataSource:), datasourceProxy);
}

//
// Internal methods for proxys
//

- (PXUIPickerViewDelegate *)pxDelegate
{
    id delegate = objc_getAssociatedObject(self, &PX_DELEGATE);
    
    if(delegate == nil)
    {
        delegate = [[PXUIPickerViewDelegate alloc] init];
        objc_setAssociatedObject(self, &PX_DELEGATE, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return delegate;
}

- (id<UIPickerViewDelegate>)pxDelegateProxy
{
    id proxy = objc_getAssociatedObject(self, &PX_DELEGATE_PROXY);
    
    if(proxy == nil)
    {
        proxy = [[PXProxy alloc] initWithBaseOject:nil overridingObject:[self pxDelegate]];
        objc_setAssociatedObject(self, &PX_DELEGATE_PROXY, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return proxy;
}

- (id<UIPickerViewDataSource>)pxDatasourceProxy
{
    id proxy = objc_getAssociatedObject(self, &PX_DATASOURCE_PROXY);
    
    if(proxy == nil)
    {
        proxy = [[PXProxy alloc] initWithBaseOject:nil overridingObject:[self pxDelegate]];
        objc_setAssociatedObject(self, &PX_DATASOURCE_PROXY, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return proxy;
}
**/

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        
        stylers = @[
            PXTransformStyler.sharedInstance,
            PXLayoutStyler.sharedInstance,
            PXOpacityStyler.sharedInstance,
            PXAnimationStyler.sharedInstance,
        ];
    });

	return stylers;
}

- (NSDictionary *)viewStylersByProperty
{
    static NSDictionary *map = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        map = [PXStyleUtils viewStylerPropertyMapForStyleable:self];
    });

    return map;
}

PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
