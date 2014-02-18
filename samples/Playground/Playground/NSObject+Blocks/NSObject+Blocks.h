//
//  NSObject+Blocks.h
//  Filemator
//
//  Created by Zachary Waldowski on 4/12/11.
//  Copyright 2011 Dizzy Technology. All rights reserved.
//
 
@interface NSObject (Blocks)
 
+ (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay completion:(void (^)(void))completion;
//+ (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
+ (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay;
- (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay;
 
+ (void)cancelBlock:(id)block;
 
@end

