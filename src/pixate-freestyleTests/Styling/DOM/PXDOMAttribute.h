//
//  PXDOMAttribute.h
//  Pixate
//
//  Created by Kevin Lindsey on 11/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXDOMAttribute : NSObject

@property (nonatomic, readonly) NSString *namespacePrefix;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, strong) id value;

- initWithName:(NSString *)name value:(id)value;

@end
