//
//  ViewController.m
//  Calc7Demo
//
//  Created by Paul Colton on 6/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}

-(void)viewWillAppear:(BOOL)animated
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
        for (UIView *view in self.view.subviews)
        {
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y+20,
                                    view.frame.size.width, view.frame.size.height);
        }
    }
}

@end
