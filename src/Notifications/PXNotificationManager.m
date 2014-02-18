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
//  PXNotificationManager.m
//  Pixate
//
//  Created by Paul Colton on 2/28/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXNotificationManager.h"
#import "PXNotificationInfo.h"

@implementation PXNotificationManager
{
    NSMutableDictionary *observersByNotification_;
}

+ (PXNotificationManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static PXNotificationManager *manager;
    
    dispatch_once(&onceToken, ^{
        manager = [[PXNotificationManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    if (self = [super init])
    {
        observersByNotification_ = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)registerObserver:(id)observer forNotification:(NSString *)notification withBlock:(void(^)())block
{
    if (observer != nil && notification.length > 0)
    {
        NSMutableArray *observers = [observersByNotification_ objectForKey:notification];
        
        if (observers == nil)
        {
            observers = [[NSMutableArray alloc] init];
            
            [observersByNotification_ setObject:observers forKey:notification];
        }
        
        __block BOOL isObserving = NO;
        
        [observers enumerateObjectsUsingBlock:^(PXNotificationInfo *info, NSUInteger idx, BOOL *stop) {
            if (info.object == observer)
            {
                isObserving = YES;
                *stop = YES;
            }
        }];
        
        if (isObserving == NO)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:notification object:observer];
        }
        
        PXNotificationInfo *info = [[PXNotificationInfo alloc] initWithObject:observer withBlock:block];
        
        [observers addObject:info];
    }
}

- (void)unregisterObserver:(id)observer forNotification:(NSString *)notification
{
    if (observer != nil && notification.length > 0)
    {
        NSMutableArray *observers = [observersByNotification_ objectForKey:notification];
        NSMutableArray *toDelete = [[NSMutableArray alloc] init];
        
        [observers enumerateObjectsUsingBlock:^(PXNotificationInfo *info, NSUInteger idx, BOOL *stop) {
            if (!info.object || info.object == observer)
            {
                [toDelete addObject:observer];
            }
        }];
        
        [observers removeObjectsInArray:toDelete];
        
        __block BOOL isObserving = NO;
        
        [observers enumerateObjectsUsingBlock:^(PXNotificationInfo *info, NSUInteger idx, BOOL *stop) {
            if (info.object == observer)
            {
                isObserving = YES;
                *stop = YES;
            }
        }];
        
        if (isObserving == NO)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:observer];
        }
        
        if (observers.count == 0)
        {
            [observersByNotification_ removeObjectForKey:notification];
        }
    }
}

- (void)handleNotification:(NSNotification *)notification
{
    id observer = notification.object;
    
    if (observer != nil)
    {
        NSMutableArray *observers = [observersByNotification_ objectForKey:notification.name];
        // TODO: should we remove nil references in here too?
        
        [observers enumerateObjectsUsingBlock:^(PXNotificationInfo *info, NSUInteger idx, BOOL *stop) {
            if (info.object == observer)
            {
                [info invokeBlock];
            }
        }];
    }
}

@end
