//
//  PXDOMParser.h
//  Pixate
//
//  Created by Kevin Lindsey on 11/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXDOMElement.h"

@interface PXDOMParser : NSObject <NSXMLParserDelegate>

+ (PXDOMElement *)loadFromURL:(NSURL *)URL;

@end
