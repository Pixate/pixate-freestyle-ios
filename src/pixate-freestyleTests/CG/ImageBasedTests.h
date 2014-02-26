//
//  ImageBasedTests.h
//  Pixate
//
//  Created by Kevin Lindsey on 10/29/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ImageBasedTests : XCTestCase

- (NSString *)rasterImageDirectoryName;

- (void)assertImage:(UIImage *)image1 equalsImage:(UIImage *)image2;
- (NSString *)localPathForName:(NSString *)name;
- (void)writeImage:(UIImage *)image withName:(NSString *)name overwrite:(BOOL)overwrite;
- (void)writeImage:(UIImage *)image withPath:(NSString *)outputPath overwrite:(BOOL)overwrite;
- (UIImage *)getImageForName:(NSString *)name;

@end
