//
//  main.m
//  ListFonts
//
//  Created by Kevin Lindsey on 1/13/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "PixateFreestyle.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [PixateFreestyle initializePixateFreestyle];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
