//
//  MapViewPreview.m
//  Playground
//
//  Created by Paul Colton on 11/29/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "MapViewPreview.h"
#import "MapViewPreviewController.h"

@implementation MapViewPreview
{
MapViewPreviewController *mapViewPreviewController_;
}

- (void) initializeCustomController
{
    mapViewPreviewController_ = [[MapViewPreviewController alloc] initWithNibName:@"MapViewPreviewController" bundle:nil];
}

-(UIView *)previewView
{
    return mapViewPreviewController_.view;
}

- (BOOL) reloadPreviewOnEdit
{
    return NO;
}

@end
