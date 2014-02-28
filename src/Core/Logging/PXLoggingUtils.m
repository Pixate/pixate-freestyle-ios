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
//  PXLoggingUtils.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/4/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#ifdef PX_LOGGING
#import "PXLoggingUtils.h"
#import "DDFileLogger.h"
#import "DDTTYLogger.h"
#import "PXFileFunctionLogFormatter.h"
#import "PXDelegateLogger.h"

@implementation PXLoggingUtils

+ (void)enableLogging
{
    // create a custom formatter
    PXFileFunctionLogFormatter *formatter = [[PXFileFunctionLogFormatter alloc] init];

    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];

    // turn on colorized output and set info and verbose colors as well
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:LOG_FLAG_INFO];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor yellowColor] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];

    // connect logger
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

+ (void)enableLoggingToDirectoryPath:(NSString *)path
{
    // create a custom formatter
    PXFileFunctionLogFormatter *formatter = [[PXFileFunctionLogFormatter alloc] init];

    if (path.length > 0)
    {
        DDLogFileManagerDefault *manager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:path];
        DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:manager];
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;

        [DDLog addLogger:fileLogger];
    }
    else
    {
        [[DDTTYLogger sharedInstance] setLogFormatter:formatter];

        // turn on colorized output and set info and verbose colors as well
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:LOG_FLAG_INFO];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor yellowColor] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];

        // connect logger
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
}

+ (void)setGlobalLoggingLevel:(int)logLevel
{
    // set default logging levels
    for (id c in [DDLog registeredClasses])
    {
        [DDLog setLogLevel:logLevel forClass:c];
    }
}

+ (void)addLoggingDelegate:(id <PXLoggingDelegate>)delegate
{
    [DDLog addLogger:[[PXDelegateLogger alloc] initWithDelegate:delegate]];
}

@end
#endif
