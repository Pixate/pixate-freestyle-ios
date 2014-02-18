//
//  NavigationBarExamples.h
//  Playground
//
//  Created by Paul Colton on 11/16/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationBarExamples : UIViewController

- (id)initWithIndex:(int)number;
- (IBAction)moreButtonClicked:(id)sender;

@property (nonatomic) int index;

@end
