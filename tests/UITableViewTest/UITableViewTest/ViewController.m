//
//  ViewController.m
//  UITableViewTest
//
//  Created by Paul Colton on 3/8/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "ViewController.h"
#import "UIView+PXStyling.h"

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Test 1";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Configure the cell.
    cell.textLabel.text = [_data objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.parentViewController.view styleClassed:@"correct" enabled:(indexPath.row == 0)];
    [self.parentViewController.view styleClassed:@"error" enabled:(indexPath.row != 0)];
}

@end
