//
//  PXStyleableValue.h
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 3/30/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXObjectValueWrapper.h"
#import "PXExpressionExports.h"

@protocol PXStyleableExports <PXExpressionExports>
@property (nonatomic, readonly) double x;
@property (nonatomic, readonly) double y;
@property (nonatomic, readonly) double width;
@property (nonatomic, readonly) double height;
@property (nonatomic, readonly) double top;
@property (nonatomic, readonly) double right;
@property (nonatomic, readonly) double bottom;
@property (nonatomic, readonly) double left;
@end

@interface PXStyleableValue : PXObjectValueWrapper <PXStyleableExports>

@end
