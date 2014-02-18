//
//  MapViewPreviewLocation.m
//  Playground
//
//  Created by Paul Colton on 11/29/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "MapViewPreviewLocation.h"

@implementation MapViewPreviewLocation
{
    NSString *name_;
    NSString *address_;
    CLLocationCoordinate2D coordinate_;
}

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate
{
    if ((self = [super init]))
    {
        name_ = name;
        address_ = address;
        coordinate_ = coordinate;
    }
    
    return self;
}

- (NSString *)title
{
    return name_;
}

- (NSString *)subtitle
{
    return address_;
}

- (CLLocationCoordinate2D)coordinate
{
    return coordinate_;
}

@end
