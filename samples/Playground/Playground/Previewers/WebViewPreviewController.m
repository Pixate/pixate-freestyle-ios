//
//  WebViewPreviewController.m
//  Playground
//
//  Created by Paul Colton on 11/19/12.
//  Copyright (c) 2012 ;, Inc. All rights reserved.
//

#import "WebViewPreviewController.h"

@implementation WebViewPreviewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.urlLocation setText:@"http://www.pixate.com/blog/"];
    [self textFieldShouldReturn:self.urlLocation];
    self.urlLocation.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlLocation.text]]];
    return YES;
}

-(IBAction)reloadButtonClicked:(id)sender
{
    [self.webView reload];
}

@end
