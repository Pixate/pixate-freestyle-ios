//
//  TableViewsController.m
//  Playground
//
//  Created by Paul Colton on 11/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "TableViewsController.h"

@interface TableViewsController ()

@end

@implementation TableViewsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.frame = CGRectMake(0, 0, 500, 335);
    
    _tableViewPreview = [[TableViewPreviewViewController alloc] initWithStyle:UITableViewStylePlain
                                                                     cellType:NormalCell
                                                                       cellId:@"myTable"];
    _tableViewPreview2 = [[TableViewPreviewViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                      cellType:NormalCell
                                                                        cellId:@"myTable2"];
    _tableViewPreview3 = [[TableViewPreviewViewController alloc] initWithStyle:UITableViewStylePlain
                                                                      cellType:NIBLoadedCell
                                                                        cellId:@"myTable3"];
    _tableViewPreview4 = [[TableViewPreviewViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                      cellType:NIBLoadedCell
                                                                        cellId:@"myTable4"];
    
    self.viewControllers = @[ _tableViewPreview, _tableViewPreview2, _tableViewPreview3, _tableViewPreview4 ];

    _tableViewPreview.title = @"Plain";
    _tableViewPreview2.title = @"Grouped";
    _tableViewPreview3.title = @"Plain - NIB";
    _tableViewPreview4.title = @"Grouped - NIB";

    _tableViewPreview.tabBarItem.image =
        _tableViewPreview2.tabBarItem.image =
        _tableViewPreview3.tabBarItem.image =
        _tableViewPreview4.tabBarItem.image = [UIImage imageNamed:@"box"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
