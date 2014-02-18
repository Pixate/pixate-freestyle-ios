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
//  PXPaintStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXPaintStyler.h"
#import "PXRectangle.h"
#import "PXSolidPaint.h"
#import "PXUtils.h"

@implementation PXPaintStyler

+ (PXPaintStyler *)sharedInstanceForTintColor
{
	static __strong PXPaintStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;
    
	dispatch_once(&onceToken, ^{
		sharedInstance = [[PXPaintStyler alloc] initWithCompletionBlock:[PXPaintStyler SetTintColorCompletionBlock]];
	});
    
	return sharedInstance;
}

+ (PXStylerCompletionBlock)SetTintColorCompletionBlock
{
    return ^(id<PXStyleable> view, PXPaintStyler *styler, PXStylerContext *context)
    {
        UIColor *color = (UIColor *)[context propertyValueForName:@"-ios-tint-color"];
        
        if(color && [view respondsToSelector:@selector(setTintColor:)])
        {
            [view performSelector:@selector(setTintColor:) withObject:color];
        }
    };
}

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        
        PXDeclarationHandlerBlock colorHandlerBlock = ^(PXDeclaration *declaration, PXStylerContext *context) {
            
            id<PXPaint> paint = declaration.paintValue;
            
            [context setPropertyValue:paint forName:@"paint"];
            
            if ([paint isKindOfClass:[PXSolidPaint class]])
            {
                [context setPropertyValue:((PXSolidPaint *)paint).color forName:@"color"];
            }
            else
            {
                CGRect bounds = context.styleable.bounds;
                PXRectangle *rect = [[PXRectangle alloc] initWithRect:bounds];
                rect.fill = paint;
                [context setPropertyValue:[UIColor colorWithPatternImage:[rect renderToImageWithBounds:bounds withOpacity:NO]] forName:@"color"];
            }
        };
        
        
        PXDeclarationHandlerBlock tintColorHandlerBlock = ^(PXDeclaration *declaration, PXStylerContext *context) {
            
            id<PXPaint> paint = declaration.paintValue;
            
            [context setPropertyValue:paint forName:@"paint"];
            
            if ([paint isKindOfClass:[PXSolidPaint class]])
            {
                [context setPropertyValue:((PXSolidPaint *)paint).color forName:@"-ios-tint-color"];
            }
            else
            {
                CGRect bounds = context.styleable.bounds;
                PXRectangle *rect = [[PXRectangle alloc] initWithRect:bounds];
                rect.fill = paint;
                [context setPropertyValue:[UIColor colorWithPatternImage:[rect renderToImageWithBounds:bounds withOpacity:NO]] forName:@"-ios-tint-color"];
            }
        };
        
        handlers = @{
            @"color"            : colorHandlerBlock,
            @"-ios-tint-color"  : tintColorHandlerBlock,
        };
    });

    return handlers;
}

@end
