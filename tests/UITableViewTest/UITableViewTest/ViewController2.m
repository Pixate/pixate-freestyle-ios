//
//  ViewController2.m
//  UITableViewTest
//
//  Created by Paul Colton on 3/9/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "ViewController2.h"
#import "UIView+PXStyling.h"

@interface ViewController2 ()

@end

@implementation ViewController2
{
    NSArray * _data;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _data = @[ @"Sally", @"Jane", @"Marry", @"Shannon" ];
    NSLog(@"Parent style class: %@", self.navigationController.view.styleClass);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _data.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Test 2";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [_data objectAtIndex:indexPath.row];

    return cell;
}

@end
