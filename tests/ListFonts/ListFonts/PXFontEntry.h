//
//  PXFontEntry.h
//  Pixate
//
//  Created by Kevin Lindsey on 10/25/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXFontEntry : NSObject

@property (readonly, nonatomic) NSString *family;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSInteger weight;
@property (readonly, nonatomic) NSInteger stretch;
@property (readonly, nonatomic) NSString *style;

+ (NSInteger)indexFromStretchName:(NSString *)name;
+ (NSInteger)indexFromWeightName:(NSString *)name;

+ (NSArray *)fontEntriesForFamily:(NSString *)family;
+ (NSArray *)filterEntries:(NSArray *)entries byStretch:(NSInteger)fontStretch;
+ (NSArray *)filterEntries:(NSArray *)entries byStyle:(NSString *)style;
+ (NSArray *)filterEntries:(NSArray *)entries byWeight:(NSInteger)weight;

- (id)initWithFontFamily:(NSString *)family fontName:(NSString *)name;

@end
