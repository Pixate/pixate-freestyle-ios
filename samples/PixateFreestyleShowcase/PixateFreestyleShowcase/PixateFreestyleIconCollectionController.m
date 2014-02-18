//
//  PixateFreestyleIconCollectionController.m
//  PixateFreestyle
//
//  Copyright 2013 Pixate, Inc.
//  Licensed under the MIT License
//

#import "PixateFreestyleIconCollectionController.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import "ArrayDataSource.h"
#import "PixateFreestyleIconList.h"

@interface PixateFreestyleIconCollectionController ()
    
@property (nonatomic, strong) ArrayDataSource *dataSource;

@end

@implementation PixateFreestyleIconCollectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.dataSource = [[ArrayDataSource alloc] initWithItems:[PixateFreestyleIconList getList]
                                              cellIdentifier:@"Cell"
                                          configureCellBlock:^(UICollectionViewCell *cell, NSString *styleClass)
                       {
                           UIImageView *iconView = (UIImageView *)[cell viewWithTag:100];
                           UILabel *iconLabel = (UILabel *)[cell viewWithTag:200];
                           
                           iconLabel.text = styleClass;
                           iconView.styleClass = [@"icon " stringByAppendingString:styleClass];
                       }];
    
    self.collectionView.dataSource = self.dataSource;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
