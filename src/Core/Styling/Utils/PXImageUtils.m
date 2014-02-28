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
//  PXImageUtils.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/14/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXImageUtils.h"

@implementation PXImageUtils

+ (UIImage *)clearPixel
{
    static UIImage *image;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        // create 1 by 1 graphics context
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0);

        // render 1x1 clear rectangle
        [[UIColor clearColor] setFill];
        UIRectFill(CGRectMake(0, 0, 1, 1));

        // grab resulting image
        image = UIGraphicsGetImageFromCurrentImageContext();

        // dispose of the context
        UIGraphicsEndImageContext();
    });

    return image;
}

+ (void)writeImage:(UIImage *)image withPath:(NSString *)path overwrite:(BOOL)overwrite
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (overwrite || ![fileManager fileExistsAtPath:path])
    {
        [fileManager createFileAtPath:path contents:UIImagePNGRepresentation(image) attributes:nil];
    }
}

@end
