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

#import "PXFileWatcher.h"

@implementation PXFileWatcher

// Singleton getter
+ (PXFileWatcher *)sharedInstance
{
	static __strong PXFileWatcher *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[PXFileWatcher alloc] init];
	});
	return sharedInstance;
}

- (void) watchFile:(NSString *) filePath handler:(dispatch_block_t) handler
{
    int fildes = open([filePath fileSystemRepresentation], O_EVTONLY);
    
    if(fildes > 0)
    {
        // Set up a new watch
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,fildes,
                                                          DISPATCH_VNODE_DELETE
                                                          | DISPATCH_VNODE_WRITE
                                                          | DISPATCH_VNODE_EXTEND
//                                                          | DISPATCH_VNODE_ATTRIB
//                                                          | DISPATCH_VNODE_LINK
//                                                          | DISPATCH_VNODE_RENAME
//                                                          | DISPATCH_VNODE_REVOKE
                                                          ,
                                                          queue);

        __block BOOL pending = NO;

        dispatch_source_set_event_handler(source, ^
        {
            unsigned long flags = dispatch_source_get_data(source);

            if(flags)
            {
                // Send out the cancel msg
                dispatch_source_cancel(source);

                // If call to handler is not pending, then queue it up.
                // We do this to only fire handler once when getting lots of events.
                if(!pending)
                {
                    pending = YES;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC),
                                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        //NSLog(@"handler called");
                        handler();
                        pending = NO;
                    });
                }

                [[PXFileWatcher sharedInstance] watchFile:filePath handler:handler];
            }

        });
        
        dispatch_source_set_cancel_handler(source, ^
        {
            close(fildes);
        });

        dispatch_resume(source);
    }
}

@end
