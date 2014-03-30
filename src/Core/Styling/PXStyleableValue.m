//
//  PXStyleableValue.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 3/30/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXStyleableValue.h"
#import "PXStyleable.h"

@interface PXStyleableValue ()
@property (nonatomic, weak) id<PXStyleable> styleable;
@end
@implementation PXStyleableValue

- (id)initWithObject:(id<PXStyleable>)styleable
{
    if (self = [super initWithObject:self])
    {
        _styleable = styleable;
        [self addExports];
    }

    return self;
}

#pragma mark - PXStyleableExports Implementation

- (double)x
{
    return _styleable.frame.origin.x;
}

- (double)y
{
    return _styleable.frame.origin.y;
}

- (double)width
{
    return _styleable.frame.size.width;
}

- (double)height
{
    return _styleable.frame.size.height;
}

- (double)top
{
    return _styleable.frame.origin.y;
}

- (double)right
{
    return CGRectGetMaxX(_styleable.frame);
}

- (double)bottom
{
    return CGRectGetMaxY(_styleable.frame);
}

- (double)left
{
    return _styleable.frame.origin.x;
}

@end
