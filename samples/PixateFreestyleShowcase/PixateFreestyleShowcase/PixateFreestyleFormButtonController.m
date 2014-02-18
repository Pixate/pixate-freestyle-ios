//
//  PixateFreestyleFormButtonController.m
//  PixateFreestyle
//
//  Copyright 2013 Pixate, Inc.
//  Licensed under the MIT License
//

#import "PixateFreestyleFormButtonController.h"

@interface PixateFreestyleFormButtonController ()

@end

@implementation PixateFreestyleFormButtonController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // enable scrolling in the scrollView
    [self.scrollView layoutIfNeeded];
    self.scrollView.contentSize = self.contentView.bounds.size ;
    
    // place the scrollView in the proper position
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat width = screenBound.size.width;
    CGFloat tabBarHeight = [[self.tabBarController tabBar] frame].size.height;
    CGFloat navBarHeight = [[self.navigationController navigationBar] frame].size.height;
    CGFloat height = screenBound.size.height - tabBarHeight - navBarHeight;
    self.scrollView.frame = CGRectMake(0, 0, width, height);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

@end
