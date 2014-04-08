//
//  ArrayDataSource.h
//  IconGallery
//
//  Created by Paul Colton on 11/12/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CellConfigureBlock)(id cell, id item);

@interface ArrayDataSource : NSObject <UICollectionViewDataSource>

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(CellConfigureBlock)aConfigureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
