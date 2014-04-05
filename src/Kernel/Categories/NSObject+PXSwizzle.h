//
//  NSObject+PXSwizzle.h
//  pixate-freestyle
//
//  Created by Paul Colton on 4/5/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PXSwizzle)

- (void)swizzleMethod:(SEL)orig_sel withMethod:(SEL)alt_sel;
+ (void)swizzleMethod:(SEL)orig_sel withMethod:(SEL)alt_sel;

@end
