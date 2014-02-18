//
//  PXAppDelegate.h
//  Playground
//
//  Created by Paul Colton on 10/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PXViewController;

@interface PXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PXViewController *viewController;

@end
