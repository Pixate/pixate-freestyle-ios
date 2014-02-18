//
//  main.m
//  HelloWorld
//
//  Created by Paul Colton on 2/14/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <PixateFreestyle/PixateFreestyle.h>
#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [PixateFreestyle initializePixateFreestyle];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
