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
//  PXLayoutStyler.m
//  Pixate
//
//  Created by Paul Colton on 11/15/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXLayoutStyler.h"
#import "PixateFreestyle.h"

@implementation PXLayoutStyler

#pragma mark - Static Methods

+ (PXLayoutStyler *)sharedInstance
{
	static __strong PXLayoutStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedInstance = [[PXLayoutStyler alloc] init];
	});

	return sharedInstance;
}

#pragma mark - Overrides

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
            @"top" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.top = declaration.floatValue;
            },
            @"left" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.left = declaration.floatValue;
            },
            @"width" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.width = declaration.floatValue;
            },
            @"height" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.height = declaration.floatValue;
            },
            @"size" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.width = declaration.sizeValue.width;
                context.height = declaration.sizeValue.height;
            },
            @"position" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.left = declaration.sizeValue.width;
                context.top = declaration.sizeValue.height;
            },
        };
    });

    return handlers;
}

- (BOOL)isTitaniumClass:(UIView *)view
{
    UIView *parent = view;
    
    while(parent != nil)
    {
        if([[[parent class] description] hasPrefix:@"TiUI"])
        {
            return true;
        }
        
        parent = parent.superview;
    }
    
    return false;
}

- (id)getTitaniumClass:(UIView *)view
{
    UIView *parent = view;
    
    while(parent != nil)
    {
        if([[[parent class] description] hasPrefix:@"TiUI"])
        {
            return parent;
        }
        
        parent = parent.superview;
    }
    
    return nil;
}


- (void)applyStylesWithContext:(PXStylerContext *)context
{
    id<PXStyleable> styleable = context.styleable;

    //NSLog(@"IS_TITANIUM_CLASS: %@ %@", [styleable description], [self isTitaniumClass:(UIView *)styleable]? @"YES" : @"NO");
    
    if(PixateFreestyle.titaniumMode && [styleable isKindOfClass:[UIView class]] && [self isTitaniumClass:(UIView *)styleable])
    {
        id view = styleable;
        
        //NSLog(@"VIEW: %@", styleable);

        view = [self getTitaniumClass:view];
        
        // Get the superview only if it's not already a TiUIView (which _is_ a UIView)
//        if(![[[view class] description] hasPrefix:@"TiUIView"])
//        {
//            view = ((UIView *)styleable).superview;
//            //NSLog(@"SUPERVIEW: %@", view);
//        }
//        
        if ([view respondsToSelector:NSSelectorFromString(@"px_setLayoutInfo:transform:")])
        {
            CGRect frame = CGRectMake(context.left, context.top, context.width, context.height);
            NSValue *frameValue = [NSValue valueWithCGRect:frame];
            NSValue *transformValue = [NSValue valueWithCGAffineTransform:context.transform];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [view performSelector:NSSelectorFromString(@"px_setLayoutInfo:transform:") withObject:frameValue withObject:transformValue];
#pragma clang diagnostic popk
        }
    }
    else
    {
        if(CGAffineTransformIsIdentity(context.transform) == NO && [styleable isKindOfClass:[UIView class]])
        {
            ((UIView *)styleable).transform = CGAffineTransformIdentity;
        }

        CGRect frame = styleable.frame;
        //CGRect bounds = styleable.bounds;

        context.top = (context.top == MAXFLOAT) ? context.top = frame.origin.y : context.top;
        context.left = (context.left == MAXFLOAT) ? context.left = frame.origin.x : context.left;

        context.width = (context.width == 0.0f) ? context.width = frame.size.width : context.width;
        context.height = (context.height == 0.0f) ? context.height = frame.size.height : context.height;

        CGRect frameRect = CGRectMake(context.left, context.top, context.width, context.height);
        //CGRect boundsRect = CGRectMake(0, 0, context.width, context.height);

        // NOT USED YET: Store in case they need to be used down the line
        [context setPropertyValue:[NSValue valueWithCGRect:frameRect] forName:@"frame"];
        //[context setPropertyValue:[NSValue valueWithCGRect:boundsRect] forName:@"bounds"];

        // TODO: move this out of here
        styleable.frame = frameRect;
        //styleable.bounds = boundsRect;

        //NSLog(@"BOUNDS SET ON: %@ (%f,%f,%f,%f)", [styleable description], styleable.frame.origin.x, styleable.frame.origin.y, styleable.frame.size.width, styleable.frame.size.height);

        // TODO: does this depend on being right after frame is set?
        if(CGAffineTransformIsIdentity(context.transform) == NO && [styleable isKindOfClass:[UIView class]])
        {
            ((UIView *)styleable).transform = context.transform;
        }
    }

    [super applyStylesWithContext:context];
}


@end
