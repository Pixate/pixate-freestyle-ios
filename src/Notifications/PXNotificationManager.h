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
//  PXNotificationManager.h
//  Pixate
//
//  Created by Paul Colton on 2/28/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXNotificationManager : NSObject

+ (PXNotificationManager *)sharedInstance;

- (void)registerObserver:(id)observer forNotification:(NSString *)notification withBlock:(void(^)())block;
- (void)unregisterObserver:(id)observer forNotification:(NSString *)notification;

@end
