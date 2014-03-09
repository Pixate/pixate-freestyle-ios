//
//  ViewController.m
//  UITableViewTest
//
//  Created by Paul Colton on 3/8/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController
{
    NSArray * _data;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _data = @[ @"Paul", @"John", @"Joe", @"Bob" ];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Configure the cell.
    cell.textLabel.text = [_data objectAtIndex:indexPath.row];
    
    return cell;
}

@end
