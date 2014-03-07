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
//  PXVirtualControlBase.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/16/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXVirtualStyleableControl.h"
#import "PXStyleUtils.h"

@implementation PXVirtualStyleableControl
{
    PXViewStyleUpdaterBlock _block;
    NSString *_styleClass;
    NSArray *_styleClasses;
}

// synthesize properties coming from PXStyleable protocol

@synthesize styleId;
@synthesize styleCSS;
@synthesize styleChangeable;
@synthesize styleMode = _styleMode;
@synthesize pxStyleElementName = _name;
@synthesize pxStyleParent = _parent;
@synthesize bounds = _bounds;
@synthesize frame = _frame;

#pragma mark - Initializers

- (id)init
{
    return [self initWithParent:nil elementName:@"" viewStyleUpdaterBlock:nil];
}

- (id)initWithParent:(id<PXStyleable>)parent elementName:(NSString *)elementName
{
    return [self initWithParent:parent elementName:elementName viewStyleUpdaterBlock:nil];
}

- (id)initWithParent:(id<PXStyleable>)parent elementName:(NSString *)elementName viewStyleUpdaterBlock:(PXViewStyleUpdaterBlock)block
{
    if (self = [super init])
    {
        _parent = parent;
        _name = elementName;
        _block = block;
        _bounds = CGRectZero;
        _frame = CGRectZero;
        _styleMode = PXStylingNormal;
    }

    return self;
}

#pragma mark - Getters

- (BOOL)isVirtualControl
{
    return YES;
}

- (CGRect)bounds
{
    if(CGRectEqualToRect(_bounds, CGRectZero))
    {
        return ((id<PXStyleable>)_parent).bounds;
    }
    else
    {
        return _bounds;
    }
}

- (CGRect)frame
{
    if(CGRectEqualToRect(_frame, CGRectZero))
    {
        return ((id<PXStyleable>)_parent).frame;
    }
    else
    {
        return _frame;
    }
}

- (NSString *)styleKey
{
    return [PXStyleUtils selectorFromStyleable:self];
}

- (NSDictionary *)viewStylersByProperty
{
    // Cannot cache this since virtual-styleable-controls wraps different types. We would get only one
    // cache but it would apply to all types, which is incorrect
    return [PXStyleUtils viewStylerPropertyMapForStyleable:self];
}

#pragma mark - Properties

-(void)setStyleClass:(NSString *)styleClass {
    _styleClass = styleClass;
    
    //Precalculate classes array for performance gain
    NSArray *classes = [styleClass componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    classes = [classes sortedArrayUsingComparator:^NSComparisonResult(NSString *class1, NSString *class2) {
        return [class1 compare:class2];
    }];
    _styleClasses = classes;
}

- (NSString *)styleClass {
    return _styleClass;
}

- (NSArray *)styleClasses {
    return _styleClasses;
}

#pragma mark - Overrides

- (void)updateStyleWithRuleSet:(PXRuleSet *)ruleSet context:(PXStylerContext *)context
{
    if (_block)
    {
        _block(ruleSet, context);
    }
}

- (BOOL)preventStyling
{
    return ([_parent respondsToSelector:@selector(preventStyling)] && [_parent preventStyling]);
}

@end
