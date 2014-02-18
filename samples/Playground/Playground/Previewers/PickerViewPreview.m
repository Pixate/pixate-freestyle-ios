//
//  PickerPreview.m
//  Playground
//
//  Created by Paul Colton on 11/19/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PickerViewPreview.h"
#import "PickerPreviewController.h"

@implementation PickerViewPreview
{
    PickerPreviewController *previewController_;
}

- (void) initializeCustomController
{
    previewController_ = [[PickerPreviewController alloc] initWithNibName:@"PickerPreview" bundle:nil];
}

-(UIView *)previewView
{
    return previewController_.view;
}

@end
