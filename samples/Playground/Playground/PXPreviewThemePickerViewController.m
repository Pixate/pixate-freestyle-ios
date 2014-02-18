//
//  PXPreviewPickerViewController.m
//  Visualizer
//
//  Created by Paul Colton on 10/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXPreviewThemePickerViewController.h"
#import <PixateFreestyle/PixateFreestyle.h>

@implementation PXPreviewThemePickerViewController
{
    NSArray *list_;
    NSDictionary *listMap_;
}

- (id)initWithStyle:(UITableViewStyle)style withList:(NSDictionary *)list
{
    self = [super initWithStyle:style];
    if (self) {
        listMap_ = list;
        list_ = [list keysSortedByValueUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
            return [obj1[0] compare:obj2[0]];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(150.0, 335.0);
    self.tableView.styleId = @"themePickerList";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [list_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ThemePickerCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.styleClass = @"themePickerCell";
    }

    // Set cell label
    NSArray *themeItem = [listMap_ valueForKey:list_[indexPath.row]];
    cell.textLabel.text = (NSString *) themeItem[0];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate != nil)
    {
        [_delegate previewThemePickerItemSelected:list_[indexPath.row]];
    }
}

@end
