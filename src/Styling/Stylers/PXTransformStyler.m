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
//  PXTransformStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/17/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXTransformStyler.h"
#import "PixateFreestyle.h"

#define IS_TITANIUM_CLASS(X) \
PixateFreestyle.titaniumMode && \
[X isKindOfClass:[UIView class]] && \
([[[X class] description] hasPrefix:@"TiUIView"] || \
[[[((UIView *)X).superview class] description] hasPrefix:@"TiUI"])

@implementation PXTransformStyler

#pragma mark - Static Methods

+ (PXTransformStyler *)sharedInstance
{
	static __strong PXTransformStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;
    
	dispatch_once(&onceToken, ^{
		sharedInstance = [[PXTransformStyler alloc] initWithCompletionBlock:[PXTransformStyler AssignTransformCompletionBlock]];
	});
    
	return sharedInstance;
}

+ (PXStylerCompletionBlock)AssignTransformCompletionBlock
{
    return ^(id<PXStyleable> view, PXTransformStyler *styler, PXStylerContext *context)
    {
        if(IS_TITANIUM_CLASS(view))
        {
            // Get the superview only if it's not already a TiUIView (which _is_ a UIView)
            if(![[[view class] description] hasPrefix:@"TiUIView"])
            {
                view = ((UIView *)view).superview;
                //NSLog(@"SUPERVIEW: %@", view);
            }
            
            if ([view respondsToSelector:NSSelectorFromString(@"px_set2DTransform:")])
            {
                NSValue *transformValue = [NSValue valueWithCGAffineTransform:context.transform];
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [view performSelector:NSSelectorFromString(@"px_set2DTransform:") withObject:transformValue];
#pragma clang diagnostic popk
            }
        }
        else
        {
            if([view isKindOfClass:NSClassFromString(@"UIView")])
            {
                ((UIView *)view).transform = context.transform;
            }
        }
    };
}

#pragma mark - Methods

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
            @"transform" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.transform = declaration.affineTransformValue;
            },
        };
    });

    return handlers;
}

@end
