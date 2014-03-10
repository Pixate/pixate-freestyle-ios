//
//  CustomButtonViewController.m
//  UINavigationBar
//
//  Created by Paul Colton on 3/10/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "CustomButtonViewController.h"
#import "PixateFreestyle.h"

@interface CustomButtonViewController ()
{
    UIButton *myButton;
}
@end

@implementation CustomButtonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    myButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, 100, 35);
    [myButton setTitle:@"Cancel" forState:UIControlStateNormal];
    myButton.styleClass = @"cancelButton";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
