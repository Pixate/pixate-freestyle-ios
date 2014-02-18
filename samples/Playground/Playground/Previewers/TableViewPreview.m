//
//  TableViewPreview.m
//  Playground
//
//  Created by Paul Colton on 11/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "TableViewPreview.h"
#import "TableViewPreviewViewController.h"

@implementation TableViewPreview
{
    TableViewPreviewViewController *_tableViewPreview;
}

- (void) initializeCustomController
{
    _tableViewPreview = [[TableViewPreviewViewController alloc] initWithStyle:UITableViewStylePlain
                                                                     cellType:NIBLoadedCell
                                                                       cellId:@"myTable"];
}

-(UIView *)previewView
{
    return _tableViewPreview.view;
}

@end

