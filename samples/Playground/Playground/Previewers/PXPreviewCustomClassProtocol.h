//
//  PXPreviewCustomClassProtocol.h
//  Playground
//
//  Created by Paul Colton on 11/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PXPreviewCustomClassProtocol <NSObject>

@required

@property (nonatomic, weak) UIView *previewView;

@optional

- (void) initializeCustomController;
- (BOOL) reloadPreviewOnEdit;

@end
