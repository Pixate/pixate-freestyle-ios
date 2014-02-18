//
//  ViewController.m
//  TableViewDemo
//
//  Created by Paul Colton on 4/1/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "ViewController.h"
#import <PixateFreestyle/PixateFreestyle.h>

@implementation ViewController

static NSString *CellIdentifier = @"FollowCell";

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell"
                                               bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 20;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Section %d", (section + 1)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    return cell;
}

@end
