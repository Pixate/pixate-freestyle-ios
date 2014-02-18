//
//  WebViewPreview.m
//  Playground
//
//  Created by Paul Colton on 11/19/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "WebViewPreview.h"
#import "WebViewPreviewController.h"

@implementation WebViewPreview
{
    WebViewPreviewController *previewController_;
}

- (void) initializeCustomController
{
    previewController_ = [[WebViewPreviewController alloc] initWithNibName:@"WebViewPreview" bundle:nil];
}

-(UIView *)previewView
{
    return previewController_.view;
}

- (BOOL) reloadPreviewOnEdit
{
    return NO;
}

@end
