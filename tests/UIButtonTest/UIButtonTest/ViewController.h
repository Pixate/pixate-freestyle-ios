//
//  ViewController.h
//  UIButtonTest
//
//  Created by Paul Colton on 3/8/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *button;


@property (weak, nonatomic) IBOutlet UIButton *filterButton;
- (IBAction)filter:(UIButton *)button selected:(BOOL)selected;


@end
