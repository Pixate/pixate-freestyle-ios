//
//  PXXPath.h
//  Pixate
//
//  Created by Kevin Lindsey on 11/13/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXDOMNode.h"

@interface PXXPath : NSObject

- (NSArray *)findNodesFromNode:(id<PXDOMNode>)node withPath:(NSString *)path;

@end
