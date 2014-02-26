//
//  PXDOMNode.h
//  Pixate
//
//  Created by Kevin Lindsey on 11/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStyleable.h"

@protocol PXDOMNode <PXStyleable>

@property (nonatomic, readonly) NSString *namespacePrefix;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, strong) id<PXDOMNode> parent;
@property (nonatomic, readonly) NSArray *children;

@end
