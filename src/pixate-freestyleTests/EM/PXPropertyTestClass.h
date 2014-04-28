//
//  PXPropertyTestClass.h
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/18/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXExpressionColor.h"
#import "PXExpressionExports.h"

@protocol PXPropertyTestsExports <PXExpressionExports>
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) id<PXExpressionColor> pxColor;
@end

@interface PXPropertyTestClass : NSObject <PXPropertyTestsExports>

@end
