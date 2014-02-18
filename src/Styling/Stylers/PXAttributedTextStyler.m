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
//  PXAttributedTextStyler.m
//  Pixate
//
//  Created by Robin Debreuil on 1/9/2014.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXAttributedTextStyler.h"

@implementation PXAttributedTextStyler

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        handlers = @{
                     // text                     
                     @"text" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                         context.text = declaration.stringValue;
                     },
                     
                     // color
                     @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                         [context setPropertyValue:declaration.colorValue forName:@"color"];
                     },
                     
                     // fonts
                     @"font-family" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                         context.fontName = declaration.stringValue;
                     },
                     @"font-size" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                         context.fontSize = declaration.floatValue;
                     },
                     @"font-style" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                         context.fontStyle = declaration.stringValue;
                     },
                     @"font-weight" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                         context.fontWeight = [declaration.stringValue lowercaseString];
                     },
                     @"font-stretch" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                         context.fontStretch = [declaration.stringValue lowercaseString];
                     },
                     
                     // kerning
                     @"letter-spacing" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                         context.letterSpacing = declaration.letterSpacingValue;
                     },
                     
                     // special text
                     @"text-transform" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                         context.textTransform = [declaration.stringValue lowercaseString];
                     },
                     @"text-decoration" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                         context.textDecoration = [declaration.stringValue lowercaseString];
                     }
                     
                     };
    });
    
    return handlers;
}

@end
