//
//  NSObject+PXSwizzle.m
//  pixate-freestyle
//
//  Created by Paul Colton on 4/5/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "NSObject+PXSwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>

void PXForceLoadNSObjectPXSwizzle() {}

@implementation NSObject (PXSwizzle)

/**
 *  from http://stackoverflow.com/questions/5371601/how-do-i-implement-method-swizzling
 *
 *  If the method we're swizzling is actually defined in a superclass, we have to use class_addMethod to add an
 *  implementation of ReceiveMessage: to the target class, which we do using our replacement implementation. Then we can
 *  use class_replaceMethod to replace replacementReceiveMessage: with the superclass's implementation, so our new
 *  version will be able to correctly call the old.
 *
 *  If the method is defined in the target class, class_addMethod will fail but then we can use
 *  method_exchangeImplementations to just swap the new and old versions.
 */
- (void)swizzleMethod:(SEL)orig_sel withMethod:(SEL)alt_sel
{
    // grab reference to class
    Class c = [self class];
    
    // grab original method
    Method origMethod = class_getInstanceMethod(c, orig_sel);
    
    // grab alternate method
    Method altMethod = class_getInstanceMethod(c, alt_sel);
    
    if (class_addMethod(c, orig_sel, method_getImplementation(altMethod), method_getTypeEncoding(altMethod)))
    {
        // new method added successfully, swap with original
        class_replaceMethod(c, alt_sel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        // new method already exists, so swap them
        method_exchangeImplementations(origMethod, altMethod);
    }
}

+ (void)swizzleMethod:(SEL)orig_sel withMethod:(SEL)alt_sel
{
	Class c = self;
    Method origMethod = class_getInstanceMethod(c, orig_sel);
    Method altMethod = class_getInstanceMethod(c, alt_sel);
    
    if (class_addMethod(c, orig_sel, method_getImplementation(altMethod), method_getTypeEncoding(altMethod)))
    {
        class_replaceMethod(c, alt_sel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        method_exchangeImplementations(origMethod, altMethod);
    }
}


@end
