//
//  ViewController.m
//  UILabelTest
//
//  Created by Paul Colton on 3/8/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PixateFreestyle.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClick:(id)sender {
    
    self.letterpress.text = @"Hello World";
}




@end
