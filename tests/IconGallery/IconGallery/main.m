//
//  main.m
//  IconGallery
//
//  Created by Paul Colton on 11/12/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import <PixateFreestyle/PixateFreestyle.h>

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [PixateFreestyle initializePixateFreestyle];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
