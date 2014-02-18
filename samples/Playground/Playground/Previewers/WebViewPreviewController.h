//
//  WebViewPreviewController.h
//  Playground
//
//  Created by Paul Colton on 11/19/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewPreviewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIButton *reloadButton;
@property (nonatomic, strong) IBOutlet UITextField *urlLocation;

-(IBAction)reloadButtonClicked:(id)sender;

@end
