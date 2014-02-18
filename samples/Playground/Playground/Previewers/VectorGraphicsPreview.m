//
//  VectorGraphicsPreview.m
//  Playground
//
//  Created by Paul Colton on 12/17/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "VectorGraphicsPreview.h"
#import "VectorGraphicsController.h"
#import <PixateFreestyle/PixateFreestyle.h>

@implementation VectorGraphicsPreview
{
    VectorGraphicsController *previewController_;
}

- (void) initializeCustomController
{
    previewController_ = [[VectorGraphicsController alloc] initWithNibName:@"VectorGraphicsPreview" bundle:nil];
}

-(UIView *)previewView
{
    return previewController_.view;
}

@end
