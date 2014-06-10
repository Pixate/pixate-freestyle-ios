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
//  UIBarItem+PXStyling.m
//  Pixate
//
//  Created by Paul Colton on 10/7/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "UIBarItem+PXStyling.h"
#import <objc/runtime.h>
#import "PXStylingMacros.h"
#import "PXStyleUtils.h"
#import "PXUtils.h"
#import "PXVirtualStyleableControl.h"

static const char STYLE_CLASS_KEY;
static const char STYLE_CLASSES_KEY;
static const char STYLE_ID_KEY;
static const char STYLE_CHANGEABLE_KEY;
static const char STYLE_CSS_KEY;
static const char STYLE_PARENT_KEY;
static const char STYLE_BOUNDS_KEY;
static const char STYLE_FRAME_KEY;
static const char STYLE_MODE_KEY;
static const char STYLE_ELEMENT_NAME;

void PXForceLoadUIBarItemPXStyling() {}

@implementation UIBarItem (PXStyling)

@dynamic pxStyleElementName;
@dynamic pxStyleParent;
@dynamic pxStyleChildren;

+ (void)initialize
{
    if (self != UIBarItem.class)
        return;
    
    // Set default styling mode to 'normal' (i.e. stylable)
    [[UIBarItem appearance] setStyleMode:PXStylingNormal];
}

- (NSString *)styleClass
{
    return objc_getAssociatedObject(self, &STYLE_CLASS_KEY);
}

- (NSArray *)styleClasses
{
    return objc_getAssociatedObject(self, &STYLE_CLASSES_KEY);
}

- (NSString *)styleId
{
    return objc_getAssociatedObject(self, &STYLE_ID_KEY);
}

- (BOOL)styleChangeable
{
    return [objc_getAssociatedObject(self, &STYLE_CHANGEABLE_KEY) boolValue];
}

- (NSString *)styleCSS
{
    return objc_getAssociatedObject(self, &STYLE_CSS_KEY);
}

- (PXStylingMode)styleMode
{
    NSNumber *modeVal = objc_getAssociatedObject(self, &STYLE_MODE_KEY);
    
    if(modeVal)
    {
        return modeVal.intValue;
    }
    
    return PXStylingNormal; //PXStylingUndefined;
}

- (void)setStyleElementName:(NSString *)elementName
{
    objc_setAssociatedObject(self, &STYLE_ELEMENT_NAME, elementName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)styleElementName
{
    return objc_getAssociatedObject(self, &STYLE_ELEMENT_NAME);
}

- (id)pxStyleParent
{
    return objc_getAssociatedObject(self, &STYLE_PARENT_KEY);
}

- (NSString *)styleKey
{
    return [PXStyleUtils selectorFromStyleable:self];
}

- (CGRect)bounds
{
    NSValue *value = objc_getAssociatedObject(self, &STYLE_BOUNDS_KEY);
    
    return value ? value.CGRectValue : CGRectZero;
}

- (CGRect)frame
{
    NSValue *value = objc_getAssociatedObject(self, &STYLE_FRAME_KEY);
    
    return value ? value.CGRectValue : CGRectZero;
}

- (BOOL)isVirtualControl
{
    return YES;
}

- (void)setStyleClass:(NSString *)aClass
{
    // make sure we have a string - needed to filter bad input from IB
    aClass = [aClass description];

    // trim leading and trailing whitespace
    aClass = [aClass stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    objc_setAssociatedObject(self, &STYLE_CLASS_KEY, aClass, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    
    //Precalculate classes array for performance gain
    NSArray *classes = [aClass componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    classes = [classes sortedArrayUsingComparator:^NSComparisonResult(NSString *class1, NSString *class2) {
        return [class1 compare:class2];
    }];
    objc_setAssociatedObject(self, &STYLE_CLASSES_KEY, classes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self updateStylesNonRecursively];
}

- (void)setStyleId:(NSString *)anId
{
    // make sure we have a string - needed to filter bad input from IB
    anId = [anId description];

    // trim leading and trailing whitespace
    anId = [anId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    objc_setAssociatedObject(self, &STYLE_ID_KEY, anId, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self updateStylesNonRecursively];
}

- (void)setStyleChangeable:(BOOL)changeable
{
    objc_setAssociatedObject(self, &STYLE_CHANGEABLE_KEY, [NSNumber numberWithBool:changeable], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setStyleCSS:(NSString *)aCSS
{
    // make sure we have a string - needed to filter bad input from IB
    aCSS = [aCSS description];

    objc_setAssociatedObject(self, &STYLE_CSS_KEY, aCSS, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self updateStylesNonRecursively];
}

- (void)setStyleMode:(PXStylingMode) mode
{
    //
    // Set the styling mode value on the object
    //
    objc_setAssociatedObject(self, &STYLE_MODE_KEY, [NSNumber numberWithInt:mode], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPxStyleParent:(id)parent
{
    objc_setAssociatedObject(self, &STYLE_PARENT_KEY, parent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setBounds:(CGRect)bounds
{
    NSValue *value = [NSValue valueWithCGRect:bounds];
    
    objc_setAssociatedObject(self, &STYLE_BOUNDS_KEY, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setFrame:(CGRect)frame
{
    NSValue *value = [NSValue valueWithCGRect:frame];
    
    objc_setAssociatedObject(self, &STYLE_FRAME_KEY, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)updateStyles
{
    [UIView updateStyles:self recursively:YES];
}

- (void)updateStylesNonRecursively
{
    [UIView updateStyles:self recursively:NO];
}

- (void)updateStylesAsync
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStyles];
    });
}

-(void)updateStylesNonRecursivelyAsync
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStylesNonRecursively];
    });
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

@end
