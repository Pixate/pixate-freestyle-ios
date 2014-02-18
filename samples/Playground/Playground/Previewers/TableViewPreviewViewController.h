//
//  TableViewPreviewViewController.h
//  Playground
//
//  Created by Paul Colton on 10/29/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    NormalCell = 0,
    NIBLoadedCell = 1
} TableViewPreviewCellType;

@interface TableViewPreviewViewController : UITableViewController

-(id)initWithStyle:(UITableViewStyle)style cellType:(TableViewPreviewCellType)cellType cellId:(NSString *)cellId;

@end
