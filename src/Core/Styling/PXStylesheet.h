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
//  PXStylesheet.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString *const PXStylesheetDidChangeNotification;

/**
 *  A PXStylesheetOrigin enumeration captures the various stylesheet origins (application, user, and view) which are
 *  used when determining cascading and weights of declarations.
 */
typedef enum
{
    PXStylesheetOriginApplication,
    PXStylesheetOriginUser,
    PXStylesheetOriginView,
    PXStylesheetOriginInline
} PXStylesheetOrigin;

/**
 *  A PXStylesheet typically corresponds to a single CSS file. Each stylesheet contains a list of rule sets defined
 *  within it.
 */
@interface PXStylesheet : NSObject

/**
 *  A PXStylesheetOrigin enumeration value indicating the origin of this stylesheet. Origin values are used in
 *  specificity calculations.
 */
@property (readonly, nonatomic) PXStylesheetOrigin origin;

/**
 *  A nonmutable array of error strings that were encountered when parsing the source of this stylesheet
 */
@property (nonatomic, strong) NSArray *errors;

/**
 *  The string path to the file containing the source of this stylesheet
 */
@property (nonatomic, strong) NSString *filePath;

/**
 *  A flag to watch the file for changes. If file changes, then a call to sendChangeNotifation is made.
 */
@property (nonatomic, assign) BOOL monitorChanges;

+ (void)clearCache;

@end
