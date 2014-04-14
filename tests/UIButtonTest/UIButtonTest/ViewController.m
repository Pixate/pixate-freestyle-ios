//
//  ViewController.m
//  UIButtonTest
//
//  Created by Paul Colton on 3/8/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PixateFreestyle.h"

@interface ViewController ()
{
    UIImageView *icon;
}
@end

@implementation ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    icon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 10, 15)];
    icon.styleId = @"check-icon";
    [self.filterButton addSubview:icon];
}

- (void)filter:(UIButton *)button selected:(BOOL)selected
{
    button.selected = !button.selected;
    button.styleClass = button.selected ? @"selected" : @"normal";
}

@end
