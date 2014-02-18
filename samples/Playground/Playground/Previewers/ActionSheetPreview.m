//
//  ActionSheetPreview.m
//  Playground
//
//  Created by Paul Colton on 12/12/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "ActionSheetPreview.h"
#import "ActionSheetPreviewController.h"

@implementation ActionSheetPreview
{
    ActionSheetPreviewController *previewController_;
}

- (void) initializeCustomController
{
    previewController_ = [[ActionSheetPreviewController alloc] initWithNibName:@"ActionSheetPreview" bundle:nil];
}

-(UIView *)previewView
{
    return previewController_.view;
}

@end
