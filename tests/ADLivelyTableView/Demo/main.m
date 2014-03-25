//
//  main.m
//  LivelyDemo
//
//  Created by Romain Goyet on 24/04/12.
//  Copyright (c) 2012 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LDAppDelegate.h"
#import "PixateFreestyle.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [PixateFreestyle initializePixateFreestyle];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([LDAppDelegate class]));
    }
}
