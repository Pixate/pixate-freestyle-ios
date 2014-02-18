//
//  ArrayDataSource.h
//  PixateFreestyle
//
//  Copyright 2013 Pixate, Inc.
//  Licensed under the MIT License
//

#import <Foundation/Foundation.h>

typedef void (^CellConfigureBlock)(id cell, id item);

@interface ArrayDataSource : NSObject <UICollectionViewDataSource>

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(CellConfigureBlock)aConfigureCellBlock;
    
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
    
@end
