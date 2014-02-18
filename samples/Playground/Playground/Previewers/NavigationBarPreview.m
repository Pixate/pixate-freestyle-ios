//
//  NavigationBarPreview.m
//  Playground
//
//  Created by Paul Colton on 11/16/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "NavigationBarPreview.h"
#import "NavigationBarExamples.h"
#import <PixateFreestyle/PixateFreestyle.h>

@implementation NavigationBarPreview
{
    UINavigationController *navigationController_;
    NavigationBarExamples *examples_;
}

- (void) initializeCustomController
{
    self.view.frame = CGRectMake(0,0,500,335);
    
    examples_ = [[NavigationBarExamples alloc] initWithIndex:1];
    
    navigationController_ = [[UINavigationController alloc] initWithRootViewController:examples_];
    navigationController_.navigationBar.styleId = @"bar1";
    navigationController_.view.frame = self.view.bounds;

    [self.view addSubview:navigationController_.view];
}

-(UIView *)previewView
{
    return self.view;
}

-(void)dealloc
{
    examples_ = nil;
    navigationController_ = nil;
}

@end
