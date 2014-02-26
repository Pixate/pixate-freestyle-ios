//
//  StyleableView.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/30/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "StyleableView.h"
#import "PXStyleable.h"
#import "UIView+PXStyling.h"

@implementation StyleableView
{
    NSString *elementName;
}

- (id)initWithElementName:(NSString *)name
{
    if (self = [super init])
    {
        self->elementName = name;
    }
    return self;
}

- (NSString *)pxStyleElementName
{
    return self->elementName;
}

- (NSString *)description
{
    id parent = self.pxStyleParent;
    NSString *parentName = ([parent conformsToProtocol:@protocol(PXStyleable)]) ? ((id<PXStyleable>) parent).pxStyleElementName : @"nil";

    return [NSString stringWithFormat:@"<StyleableView parent='%@' name='%@'>", parentName, self.pxStyleElementName];
}

@end
