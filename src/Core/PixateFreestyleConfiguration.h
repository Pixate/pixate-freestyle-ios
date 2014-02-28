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
//  PixateConfiguration.h
//  Pixate
//
//  Created by Kevin Lindsey on 1/23/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStyleable.h"

/**
 *  A PXParseErrorDestination enumeration captures the various parse error logging destinations. These are set using the
 *  parse-error-destination property for the pixate-config element.
 */
typedef enum {
    PXParseErrorDestinationNone,
    PXParseErrorDestinationConsole,
#ifdef PX_LOGGING
    PXParseErrorDestination_Logger
#endif
} PXParseErrorDestination;

/**
 *  A PXCacheStylesType enumeration determines if Pixate will try to cache styling.
 */
typedef enum {
    PXCacheStylesTypeNone = 0,      // Do not perform any type of style caching
    PXCacheStylesTypeStyleOnce = 1, // Do not style a styleable unless styling has changed
    PXCacheStylesTypeSave = 2,      // Save styling info for a styleable and it descendants and style those items directly
    PXCacheStylesTypeImages = 4     // Cache background images
} PXCacheStylesType;

/**
 *  The PixateConfiguration class is used to set and retrieve global settings for Pixate.
 */
@interface PixateFreestyleConfiguration : NSObject <PXStyleable>

/**
 *  Allow a style id to be associated with this object
 */
@property (nonatomic, copy) NSString *styleId;

/**
 *  Allow a style class to be associated with this object
 */
@property (nonatomic, copy) NSString *styleClass;

/**
 *  Set the styling mode of this object
 */
@property (nonatomic) PXStylingMode styleMode;

/**
 *  Determine where parse errors will be emitted
 */
@property (nonatomic) PXParseErrorDestination parseErrorDestination;

/**
 *  Determine if view styling is cached
 */
@property (nonatomic) PXCacheStylesType cacheStylesType;

// These are convenience methods for checking the PXCacheStylesType flags in the cachStylesType property
- (BOOL)cacheImages;
- (BOOL)cacheStyles;
- (BOOL)preventRedundantStyling;

/**
 *  Set the number of images allowed in the image cache
 */
@property (nonatomic) NSUInteger imageCacheCount;

/**
 *  Set the number of bytes allowed in teh image cache
 */
@property (nonatomic) NSUInteger imageCacheSize;

/**
 *  Set the number of cache styleables allowed in the image cache
 */
@property (nonatomic) NSUInteger styleCacheCount;

/*
 *  Return the property value for the specifified property name
 *
 *  @param name The name of the property
 */
- (id)propertyValueForName:(NSString *)name;

/*
 *  Set the property value for the specified property name
 *
 *  @param value The new value
 *  @param name The property name
 */
- (void)setPropertyValue:(id)value forName:(NSString *)name;

/**
 *  Log the specified message to the target indicated by the loggingType property
 *
 *  @param message The message to emit
 */
- (void)sendParseMessage:(NSString *)message;

@end
