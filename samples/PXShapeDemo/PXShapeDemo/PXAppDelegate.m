//
//  PXAppDelegate.m
//  Shapes
//
//  Created by Kevin Lindsey on 5/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXAppDelegate.h"
#import "PXShapeViewController.h"
#import <PixateFreestyle/PixateFreestyle.h>

@implementation PXAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    PXShapeViewController *controller = [[PXShapeViewController alloc] init];
    self.window.rootViewController = controller;

    [self.window makeKeyAndVisible];
    return YES;
}

@end
