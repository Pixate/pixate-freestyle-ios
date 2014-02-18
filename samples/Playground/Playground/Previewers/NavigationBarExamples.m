//
//  NavigationBarExamples.m
//  Playground
//
//  Created by Paul Colton on 11/16/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "NavigationBarExamples.h"
#import <PixateFreestyle/PixateFreestyle.h>

static int count_;

@interface NavigationBarExamples ()
    - (void) backButtonClicked;
@end

@implementation NavigationBarExamples
{
    NavigationBarExamples *examples_;
}

-(id)initWithIndex:(int)number
{
    self = [super initWithNibName:@"NavigationBarExamples" bundle:nil];
    if (self)
    {
        self.index = number;
        
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"Navigation Bar %d", self.index];
    
    return;
    
    if(self.index > 1 && self.index < 5)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.styleId = [NSString stringWithFormat:@"myLeftNavButton%d", self.index];
        
        button.styleClass = @"myLeftNavButtons";
        button.frame = CGRectMake(0,0,100,25);
        [button addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];

        NSString *title = self.navigationController.navigationBar.topItem.title;
        title = [title length] == 0 ? @"Back" : title;

        [button setTitle:title forState:UIControlStateNormal];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
}

-(void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreButtonClicked:(id)sender
{
    examples_ = [[NavigationBarExamples alloc] initWithIndex:self.index+1];

    [[self navigationController] pushViewController:examples_ animated:YES];
}

-(void)setCount:(int)count
{
    count_ = count;
}

@end
