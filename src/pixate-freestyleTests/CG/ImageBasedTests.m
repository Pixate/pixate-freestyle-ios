//
//  ImageBasedTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/29/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "ImageBasedTests.h"

#define BYTES_PER_PIXEL 4
#define BITS_PER_CHANNEL 8

@interface ImageBasedTests ()
@end

@implementation ImageBasedTests

- (NSString *)rasterImageDirectoryName
{
    return @"Rendering";
}

- (void)assertImage:(UIImage *)image1 equalsImage:(UIImage *)image2
{
    if (CGSizeEqualToSize(image1.size, image2.size))
    {
        // get pointer to image1 data
        CGImageRef cgImage1 = image1.CGImage;
        CFDataRef data1 = CGDataProviderCopyData(CGImageGetDataProvider(cgImage1));
        const UInt8 *bytes1 = CFDataGetBytePtr(data1);
        size_t bytesPerRow1 = CGImageGetBytesPerRow(cgImage1);
        size_t offset1 = 0;

        // get pointer to image2 data
        CGImageRef cgImage2 = image2.CGImage;
        CFDataRef data2 = CGDataProviderCopyData(CGImageGetDataProvider(cgImage2));
        const UInt8 *bytes2 = CFDataGetBytePtr(data2);
        size_t bytesPerRow2 = CGImageGetBytesPerRow(cgImage2);
        size_t offset2 = 0;

        XCTAssertEqual(CGImageGetBitsPerPixel(cgImage1), CGImageGetBitsPerPixel(cgImage2), @"bits per pixel do no match");
        XCTAssertEqual(CGImageGetBitsPerComponent(cgImage1), CGImageGetBitsPerComponent(cgImage2), @"bits per component do not match");
        XCTAssertEqual(CGImageGetBitmapInfo(cgImage1), CGImageGetBitmapInfo(cgImage2), @"bitmap infos do not match");

        size_t bytesPerPixel = CGImageGetBitsPerPixel(cgImage1) / 8;

        for (size_t row = 0; row < CGImageGetHeight(cgImage1); row++)
        {
            BOOL exitTest = NO;

            for (size_t column = 0; column < CGImageGetWidth(cgImage1); column++)
            {
                size_t columnOffset = column * bytesPerPixel;
                size_t pixelOffset1 = offset1 + columnOffset;
                size_t pixelOffset2 = offset2 + columnOffset;

                for (size_t channel = 0; channel < bytesPerPixel; channel++)
                {
                    UInt8 byte1 = bytes1[pixelOffset1 + channel];
                    UInt8 byte2 = bytes2[pixelOffset2 + channel];

                    XCTAssertEqual(byte1, byte2, @"Bytes at (%ld,%ld), channel %ld do no match. %d != %d", column, row, channel, byte1, byte2);

                    if (byte1 != byte2)
                    {
                        // NOTE: yuck
                        exitTest = YES;
                        break;
                    }
                }

                // NOTE: yuck
                if (exitTest) break;
            }

            // NOTE: yuck
            if (exitTest) break;

            offset1 += bytesPerRow1;
            offset2 += bytesPerRow2;
        }
    }
    else
    {
        XCTFail(@"Image sizes do not match: (%f,%f) != (%f,%f)", image1.size.width, image1.size.height, image2.size.width, image2.size.height);
    }
}

- (NSString *)localPathForName:(NSString *)name
{
    static NSString *tempDirectory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tempDirectory = NSHomeDirectory();
    });

    return [NSString stringWithFormat:@"%@/%@.png", tempDirectory, name];
}

- (UIImage *)getImageForName:(NSString *)name
{
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.pixate.pixate-freestyleTests"] pathForResource:name ofType:@"png"];

    return [UIImage imageWithContentsOfFile:path];
}

- (void)writeImage:(UIImage *)image withName:(NSString *)name overwrite:(BOOL)overwrite
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *outputPath = [self localPathForName:name];

    // only create file if it doesn't exist already
    if (overwrite || ![fileManager fileExistsAtPath:outputPath])
    {
        NSData *myImageData = UIImagePNGRepresentation(image);
        [fileManager createFileAtPath:outputPath contents:myImageData attributes:nil];
    }
}

- (void)writeImage:(UIImage *)image withPath:(NSString *)outputPath overwrite:(BOOL)overwrite
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // only create file if it doesn't exist already
    if (overwrite || ![fileManager fileExistsAtPath:outputPath])
    {
        NSData *myImageData = UIImagePNGRepresentation(image);
        [fileManager createFileAtPath:outputPath contents:myImageData attributes:nil];
    }
}


@end
