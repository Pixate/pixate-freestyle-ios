//
//  PXDOMElement.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXDOMElement.h"
#import "PXDOMAttribute.h"
#import "PXSourceWriter.h"
#import "PXRuleSet.h"
#import "PXDeclaration.h"
#import "PXStylerContext.h"
#import "PXStyleUtils.h"

@implementation PXDOMElement
{
    NSMutableArray *children_;
    NSMutableDictionary *attributes_;
    NSMutableArray *attributeNames_;
    NSMutableDictionary *prefixes_;
    NSMutableArray *prefixNames_;
}

@synthesize namespacePrefix = namespacePrefix_;
@synthesize name = name_;
@synthesize parent = parent_;
@synthesize styleMode;
@synthesize styleClasses;
@synthesize styleChangeable;

#pragma mark - Initializers

- (id)initWithName:(NSString *)name
{
    if (self = [super init])
    {
        NSArray *parts = [name componentsSeparatedByString:@":"];

        if (parts.count == 2)
        {
            namespacePrefix_ = [parts objectAtIndex:0];
            name_ = [parts lastObject];
        }
        else
        {
            namespacePrefix_ = @"";
            name_ = name;
        }
    }

    return self;
}

#pragma mark - Getters and Setters

- (NSArray *)children
{
    return children_;
}

- (id)attributeValueForName:(NSString *)name withNamespace:(NSString *)namespace
{
    id result = nil;

    NSMutableArray *attributes = [attributes_ objectForKey:name];

    for (PXDOMAttribute *attribute in attributes)
    {
        if (attribute)
        {
            NSString *prefix = attribute.namespacePrefix;

            if ([@"*" isEqualToString:namespace])
            {
                result = attribute.value;
            }
            else if (prefix.length > 0)
            {
                NSString *namespaceURI = [self namespaceURIForPrefix:prefix];

                if ([namespaceURI isEqualToString:namespace])
                {
                    result = attribute.value;
                }
            }
            else if (namespace.length == 0)
            {
                result = attribute.value;
            }
        }

        if (result)
        {
            break;
        }
    }

    return result;
}

- (void)setAttributeValue:(id)value forName:(NSString *)name
{
    if (name && value)
    {
        PXDOMAttribute *attribute = [[PXDOMAttribute alloc] initWithName:name value:value];

        if ([attribute.namespacePrefix isEqualToString:@"xmlns"])
        {
            [self addNamespaceURI:value forPrefix:attribute.name];
        }
        else if ([attribute.name isEqualToString:@"xmlns"])
        {
            [self addNamespaceURI:value forPrefix:@""];
        }
        else
        {
            if (attributes_ == nil)
            {
                attributes_ = [[NSMutableDictionary alloc] init];
                attributeNames_ = [[NSMutableArray alloc] init];
            }

            if (![attributeNames_ containsObject:attribute.name])
            {
                NSMutableArray *attributes = [[NSMutableArray alloc] init];

                [attributes addObject:attribute];
                [attributeNames_ addObject:attribute.name];
                [attributes_ setObject:attributes forKey:attribute.name];
            }
            else
            {
                NSMutableArray *attributes = [attributes_ objectForKey:name];

                [attributes addObject:attribute];
            }
        }
    }
}

- (NSString *)innerXML
{
    NSMutableArray *textParts = [[NSMutableArray alloc] init];

    // grab XML from each child
    for (id<PXDOMNode> child in self.children)
    {
        [textParts addObject:child.description];
    }

    return [textParts componentsJoinedByString:@""];
}

#pragma mark - Methods

- (void)addNamespaceURI:(NSString *)URI forPrefix:(NSString *)prefix
{
    if (prefixes_ == nil)
    {
        prefixes_ = [[NSMutableDictionary alloc] init];
        prefixNames_ = [[NSMutableArray alloc] init];
    }

    if (![prefixNames_ containsObject:prefix])
    {
        [prefixNames_ addObject:prefix];
        [prefixes_ setObject:URI forKey:prefix];
    }
}

- (void)addChild:(id<PXDOMNode>)child
{
    if (child)
    {
        if (children_ == nil)
        {
            children_ = [[NSMutableArray alloc] init];
        }

        [children_ addObject:child];

        child.parent = self;
    }
}

- (NSString *)namespaceURIForPrefix:(NSString *)prefix
{
    NSString *result = nil;
    PXDOMElement *currentElement = self;

    while (currentElement)
    {
        NSString *candidate = [currentElement->prefixes_ objectForKey:prefix];

        if (candidate)
        {
            result = candidate;
            break;
        }
        else
        {
            currentElement = currentElement.parent;
        }
    }

    return result;
}

- (NSString *)prefixForNamespaceURI:(NSString *)namespaceURI
{
    NSString *result = nil;

    for (NSString *prefix in [prefixNames_ reverseObjectEnumerator])
    {
        if ([namespaceURI isEqualToString:[prefixes_ objectForKey:prefix]])
        {
            result = prefix;
            break;
        }
    }

    return result;
}

#pragma mark - Overrides

- (NSString *)description
{
    // string builder array
    NSMutableArray *parts = [[NSMutableArray alloc] init];

    // emit name, with possible prefix
    if (namespacePrefix_.length > 0)
    {
        [parts addObject:[NSString stringWithFormat:@"<%@:%@", namespacePrefix_, name_]];
    }
    else
    {
        [parts addObject:[NSString stringWithFormat:@"<%@", name_]];
    }

    for (NSString *prefix in prefixNames_)
    {
        NSString *namespaceURI = [self namespaceURIForPrefix:prefix];

        if (prefix.length > 0)
        {
            [parts addObject:[NSString stringWithFormat:@" xmlns:%@=\"%@\"", prefix, namespaceURI]];
        }
        else
        {
            [parts addObject:[NSString stringWithFormat:@" xmlns=\"%@\"", namespaceURI]];
        }
    }

    for (NSString *name in attributeNames_)
    {
        for (PXDOMAttribute *attribute in [attributes_ objectForKey:name])
        {
            [parts addObject:@" "];
            [parts addObject:attribute.description];
        }
    }

    // process children
    NSArray *children = self.children;

    if (children.count > 0)
    {
        [parts addObject:@">"];

        for (id<PXDOMNode> child in children)
        {
            [parts addObject:child.description];
        }

        [parts addObject:[NSString stringWithFormat:@"</%@>", self.name]];
    }
    else
    {
        [parts addObject:@"/>"];
    }

    return [parts componentsJoinedByString:@""];
}

- (NSString *)prefixForURI:(NSString *)uri
{
    NSString *result = nil;
    PXDOMElement *currentElement = self;

    while (currentElement)
    {
        NSString *candidate = [currentElement prefixForURI:uri];

        if (candidate)
        {
            result = candidate;
            break;
        }
        else
        {
            currentElement = currentElement.parent;
        }
    }

    return result;
}

#pragma mark - PXStyleable

- (NSString *)styleId
{
    return [self attributeValueForName:@"id" withNamespace:nil];
}

- (void)setStyleId:(NSString *)styleId
{
    [self setAttributeValue:styleId forName:@"id"];
}

- (NSString *)styleClass
{
    return [self attributeValueForName:@"class" withNamespace:nil];
}

- (void)setStyleClass:(NSString *)styleClass
{
    [self setAttributeValue:styleClass forName:@"class"];
}

- (NSArray *)pxStyleChildren
{
    return self.children;
}

- (NSString *)pxStyleElementName
{
    return self.name;
}

- (id)pxStyleParent
{
    return self.parent;
}

- (NSString *)pxStyleNamespace
{
    return [self namespaceURIForPrefix:self.namespacePrefix];
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

- (void)updateStyleWithRuleSet:(PXRuleSet *)ruleSet context:(PXStylerContext *)context
{
    for (PXDeclaration *declaration in ruleSet.declarations)
    {
        NSString *name = declaration.name;
        NSString *value = declaration.stringValue;

        [self setAttributeValue:value forName:name];
    }
}

@end
