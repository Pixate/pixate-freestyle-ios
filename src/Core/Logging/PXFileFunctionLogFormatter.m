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
//  PXFileFunctionLogFormatter.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/4/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#ifdef PX_LOGGING
#import "PXFileFunctionLogFormatter.h"

@implementation PXFileFunctionLogFormatter
{
    NSDateFormatter *dateFormatter_;    // NOTE: not thread-safe
}

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        dateFormatter_ = [[NSDateFormatter alloc] init];
        [dateFormatter_ setFormatterBehavior:NSDateFormatterBehavior10_4];
        [dateFormatter_ setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
    }

    return self;
}

#pragma mark - DDLogFormatter Implementation

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    // build date/time string
    NSString *dateAndTime = [dateFormatter_ stringFromDate:(logMessage->timestamp)];

#ifdef DEBUG
    // get full path to file and convert to NSString
    NSString *file = [NSString stringWithCString:logMessage->file encoding:NSUTF8StringEncoding];

    // grab the last segment in the path
    file = [file lastPathComponent];

    // chop of .m
    file = [file substringWithRange:NSMakeRange(0, file.length - 2)];

    // grab function name
    NSString *function = [NSString stringWithCString:logMessage->function encoding:NSUTF8StringEncoding];

    return [NSString stringWithFormat:@"%@ [%@ %@]@%d: %@", dateAndTime, file, function, logMessage->lineNumber, logMessage->logMsg];
#else
    return [NSString stringWithFormat:@"%@: %@", dateAndTime, logMessage->logMsg];
#endif
}

@end
#endif
