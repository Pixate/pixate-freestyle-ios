//
//  IconGalleryCollectionViewController.m
//  IconGallery
//
//  Created by Paul Colton on 11/12/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "IconGalleryCollectionViewController.h"
#import "ArrayDataSource.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import "IconList.h"

@interface IconGalleryCollectionViewController ()

@property (nonatomic, strong) ArrayDataSource *dataSource;

@end

@implementation IconGalleryCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = [[ArrayDataSource alloc] initWithItems:[IconList getList]
                                              cellIdentifier:@"Cell"
                                          configureCellBlock:^(UICollectionViewCell *cell, NSString *styleClass)
    {
        UIImageView *iconView = (UIImageView *)[cell viewWithTag:100];
        UILabel *iconLabel = (UILabel *)[cell viewWithTag:200];
        
        NSString *prettyName = [styleClass substringFromIndex:3];
        NSString *firstLetter = [prettyName substringToIndex:1];
        iconLabel.text = [[firstLetter uppercaseString] stringByAppendingString:[prettyName substringFromIndex:1]];

        iconView.styleClass = styleClass;
    }];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self.dataSource;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(99, 99);
//}

@end
