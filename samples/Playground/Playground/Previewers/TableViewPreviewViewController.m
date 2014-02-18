//
//  TableViewPreviewViewController.m
//  Playground
//
//  Created by Paul Colton on 10/29/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "TableViewPreviewViewController.h"
#import <PixateFreestyle/PixateFreestyle.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation TableViewPreviewViewController
{
    int _cellType;
}

static NSString *CellIdentifier = @"TableCellPreviewCell";

-(id)initWithStyle:(UITableViewStyle)style cellType:(TableViewPreviewCellType)cellType cellId:(NSString *)cellId
{
    self = [super initWithStyle:style];
    if (self) {
        _cellType = cellType;
        self.tableView.styleId = cellId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifier
                                               bundle:[NSBundle mainBundle]]
                               forCellReuseIdentifier:CellIdentifier];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6"))
    {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.styleId = @"myRefreshControl";
        self.refreshControl = refreshControl;
        [refreshControl addTarget:self action:@selector(refreshControl:) forControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - Refresh callback 

- (void)refreshControl:(UIRefreshControl *)sender
{
    [sender performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Section %d", (section + 1)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(_cellType == NormalCell)
    {
        static NSString *CellIdentifier2 = @"TableViewPreviewCell";

        cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];

        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        }
        
        cell.textLabel.text = @"Pixate";
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
