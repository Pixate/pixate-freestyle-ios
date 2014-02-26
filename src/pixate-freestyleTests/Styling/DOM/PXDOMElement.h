//
//  PXDOMElement.h
//  Pixate
//
//  Created by Kevin Lindsey on 11/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXDOMNode.h"

@interface PXDOMElement : NSObject <PXDOMNode>

@property (nonatomic, readonly) NSString *innerXML;

- (id)initWithName:(NSString *)name;
- (void)addNamespaceURI:(NSString *)URI forPrefix:(NSString *)prefix;
- (void)addChild:(id<PXDOMNode>)child;
- (id)attributeValueForName:(NSString *)name withNamespace:(NSString *)namespace;
- (void)setAttributeValue:(id)value forName:(NSString *)name;

@end
