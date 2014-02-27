//
//  PXLexeme.h
//  Protostyle
//
//  Created by Kevin Lindsey on 2/3/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PXLexeme <NSObject>

@property (nonatomic) int type;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong, readonly) NSString *name;

- (id)initWithType:(int)type text:(NSString *)text;

@end
