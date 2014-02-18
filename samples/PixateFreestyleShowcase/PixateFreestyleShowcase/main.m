//
//  main.m
//  PixateFreestyleShowcase
//
//  Copyright 2013 Pixate, Inc.
//  Licensed under the MIT License
//

#import <UIKit/UIKit.h>
#import <PixateFreestyle/PixateFreestyle.h>
#import "PixateFreestyleAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [PixateFreestyle initializePixateFreestyle];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PixateFreestyleAppDelegate class]));
    }
}
