//
//  main.m
//  Playground
//
//  Created by Paul Colton on 10/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PXAppDelegate.h"
#import <PixateFreestyle/PixateFreestyle.h>

int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        [PixateFreestyle initializePixateFreestyle];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PXAppDelegate class]));
    }
}
