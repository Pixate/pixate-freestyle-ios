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
//  PXInsetStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/20/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXInsetStyler.h"

@implementation PXInsetStyler
{
    NSString *_shortcutName;
    NSString *_topName;
    NSString *_rightName;
    NSString *_bottomName;
    NSString *_leftName;
}

- (id)initWithBaseName:(NSString *)baseName completionBlock:(PXStylerCompletionBlock)block
{
    if (self = [super initWithCompletionBlock:block])
    {
        [self setBaseName:baseName];
    }

    return self;
}

- (NSDictionary *)declarationHandlers
{
    static __strong NSMutableDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{ handlers = [[NSMutableDictionary alloc] init]; });

    // see if we have a handler dictionary for our prefix
    NSDictionary *result = [handlers objectForKey:_shortcutName];

    // if not, then create it and store it for later
    if (!result)
    {
        result = @{
            _shortcutName : ^(PXDeclaration *declaration, PXStylerContext *context) {
                self.insets = declaration.insetsValue;
            },
            _topName : ^(PXDeclaration *declaration, PXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                self.insets = UIEdgeInsetsMake(value, insets.left, insets.bottom, insets.right);
            },
            _rightName: ^(PXDeclaration *declaration, PXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                self.insets = UIEdgeInsetsMake(insets.top, insets.left, insets.bottom, value);
            },
            _bottomName: ^(PXDeclaration *declaration, PXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                self.insets = UIEdgeInsetsMake(insets.top, insets.left, value, insets.right);
            },
            _leftName : ^(PXDeclaration *declaration, PXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                self.insets = UIEdgeInsetsMake(insets.top, value, insets.bottom, insets.right);
            }
        };

        [handlers setObject:result forKey:_shortcutName];
    }

    return result;
}

- (void)setBaseName:(NSString *)baseName
{
    _shortcutName = [NSString stringWithFormat:@"%@-inset", baseName];
    _topName = [NSString stringWithFormat:@"%@-top-inset", baseName];
    _rightName = [NSString stringWithFormat:@"%@-right-inset", baseName];
    _bottomName = [NSString stringWithFormat:@"%@-bottom-inset", baseName];
    _leftName = [NSString stringWithFormat:@"%@-left-inset", baseName];
}

@end
