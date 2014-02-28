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
//  PXFileWatcher
//  Pixate
//
//  Created by Paul Colton on 9/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  PXFileWatcher can be used to monitor changes to a file in the file system.
 */
@interface PXFileWatcher : NSObject

/**
 *  The singleton instance of PXFileWatcher
 */
+ (PXFileWatcher *)sharedInstance;

/**
 *  Turn on file monitoring and report changes to the specified handler
 *
 *  @param filePath The local file to monitor
 *  @param handler The callback to invoke when changes are detected
 */
- (void) watchFile:(NSString *)filePath handler:(dispatch_block_t)handler;

@end
