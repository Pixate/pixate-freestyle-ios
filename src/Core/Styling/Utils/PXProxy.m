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
//  PXProxy.m
//  Pixate
//
//  Created by Paul Colton on 11/22/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//
//  Insipiration from https://github.com/hoteltonight/HTDelegateProxy
//  and https://github.com/DDany/iOS-super-delegate-proxy

#import "PXProxy.h"

@implementation PXProxy

#pragma mark - Initializer

- (id)initWithBaseOject:(id)base overridingObject:(id)overrider
{
    self.baseObject = base;
    self.overridingObject = overrider;
    return self;
}

#pragma mark - NSProxy methods

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *signature;
    
    signature = [self.overridingObject methodSignatureForSelector:sel];
    
    if (signature) return signature;
    
    signature = [self.baseObject methodSignatureForSelector:sel];
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    
    NSString *returnType = [NSString stringWithCString:invocation.methodSignature.methodReturnType
                                              encoding:NSUTF8StringEncoding];
    
    BOOL voidReturnType = [returnType isEqualToString:@"v"];
    
    if (self.overridingObject && [self.overridingObject respondsToSelector:[invocation selector]])
    {
        [invocation invokeWithTarget:self.overridingObject];
        
        // If the return type is NOT void, then we need to return first
        if (!voidReturnType)
        {
            return;
        }
    }
    
    if (self.baseObject && [self.baseObject respondsToSelector:[invocation selector]])
    {
        [invocation invokeWithTarget:self.baseObject];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self.overridingObject respondsToSelector:aSelector]) return YES;
    if ([self.baseObject respondsToSelector:aSelector]) return YES;
    return NO;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    if ([self.overridingObject conformsToProtocol:aProtocol]) return YES;
    if ([self.baseObject conformsToProtocol:aProtocol]) return YES;
    return NO;
}

#pragma mark - hash and equality

/// make sure we look like the original object

-(NSUInteger)hash
{
    return [self.baseObject hash];
}

-(BOOL)isEqual:(id)object
{
    return [self.baseObject isEqual:object];
}

@end
