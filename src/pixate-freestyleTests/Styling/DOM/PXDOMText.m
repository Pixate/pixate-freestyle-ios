//
//  PXDOMText.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXDOMText.h"
#import "PXStyleUtils.h"

@implementation PXDOMText
{
    id<PXDOMNode> parent_;
}

@synthesize textValue = text_;
@synthesize styleMode;

#pragma mark - Initializers

- initWithText:(NSString *)text
{
    if (self = [super init])
    {
        text_ = text;
    }

    return self;
}

#pragma mark - Getters and Setters

- (NSString *)namespacePrefix
{
    return nil;
}

- (NSString *)name
{
    return @"#text";
}

- (NSArray *)children
{
    return nil;
}

- (id<PXDOMNode>)parent
{
    return parent_;
}

- (void)setParent:(id<PXDOMNode>)parent
{
    parent_ = parent;
}

#pragma mark - PXStyleable

- (NSString *)styleId
{
    return @"";
}

- (void)setStyleId:(NSString *)styleId
{
    // no-op
}

- (NSString *)styleClass
{
    return @"";
}

- (void)setStyleClass:(NSString *)styleClass
{
    // no-op
}

- (NSArray *)pxStyleChildren
{
    return @[];
}

- (NSString *)pxStyleElementName
{
    return @"#text";
}

- (id)pxStyleParent
{
    return self.parent;
}

- (CGRect)bounds
{
    return CGRectZero;
}

- (void)setBounds:(CGRect)bounds
{
    // no-op
}

- (CGRect)frame
{
    return CGRectZero;
}

- (void)setFrame:(CGRect)frame
{
    // no-op
}

- (NSString *)styleKey
{
    return [PXStyleUtils selectorFromStyleable:self];
}

#pragma mark - Overrides

- (NSString *)description
{
    return self.textValue;
}

@end
