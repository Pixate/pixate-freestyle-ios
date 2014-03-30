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
@end

@interface PXStyleableValue : PXObjectValueWrapper <PXStyleableExports>

@end
