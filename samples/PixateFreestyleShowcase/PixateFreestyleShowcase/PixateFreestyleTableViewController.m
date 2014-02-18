//
//  PixateFreestyleTableViewController.m
//  PixateFreestyle
//
//  Copyright 2013 Pixate, Inc.
//  Licensed under the MIT License
//

#import "PixateFreestyleTableViewController.h"
#import "PixateFreestyleTableDetailController.h"
#import <PixateFreestyle/PixateFreestyle.h>

@interface PixateFreestyleTableViewController ()
{
    // Initalizing the array that will hold our static table data
    NSMutableArray *tableData;
}

@end

@implementation PixateFreestyleTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // initalize the tableData array
    tableData = [[NSMutableArray alloc] init];
    
    // set up sample table data with three sections
    NSArray *tableDataFirstSection = [NSArray arrayWithObjects:@"Lorem", @"Ipsum", @"Dolor", @"Sit", @"Amet", @"Consectetur", @"Adipiscing", @"Elit", @"Pellentesque", @"Suscipit", @"Risus", nil];
    NSDictionary *tableDataFirstSectionDict = [NSDictionary dictionaryWithObject:tableDataFirstSection forKey:@"data"];
    [tableData addObject:tableDataFirstSectionDict];
    
    NSArray *tableDataSecondSection = [NSArray arrayWithObjects:@"Vel", @"Luctus", @"Tristique", @"Morbi", @"Congue", @"Augue", @"Quis", @"Mauris", @"Condimentum", @"Luctus", nil];
    NSDictionary *tableDataSecondSectionDict = [NSDictionary dictionaryWithObject:tableDataSecondSection forKey:@"data"];
    [tableData addObject:tableDataSecondSectionDict];
    
    NSArray *tableDataThirdSection = [NSArray arrayWithObjects:@"Morbi", @"Nunc", @"Urna", @"Vulputate", @"Quis", @"Orci", @"Sit", @"Amet", @"Sagittis", nil];
    NSDictionary *tableDataThirdSectionDict = [NSDictionary dictionaryWithObject:tableDataThirdSection forKey:@"data"];
    [tableData addObject:tableDataThirdSectionDict];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections
    return [tableData count];
}

    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSDictionary *dictionary = [tableData objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    return [array count];
}
    
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // hardcode static section headers
    if (section == 0)
        return @"Lorem";
    else if (section == 1)
        return @"Ipsum";
    else
        return @"Dolor";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    
    
    
    

    // set text for label in cell
    NSDictionary *dictionary = [tableData objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    cell.textLabel.text = [array objectAtIndex:indexPath.row];
    
    return cell;
}

    // In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowSelectedDetail"]) {
        PixateFreestyleTableDetailController *destViewController = [segue destinationViewController];
        
        NSDictionary *dictionary = [tableData objectAtIndex:[[self.tableView indexPathForSelectedRow] section]];
        NSArray *array = [dictionary objectForKey:@"data"];
        destViewController.selectedItem = [NSString stringWithFormat:@"%@", [array objectAtIndex:[[self.tableView indexPathForSelectedRow] row]]];
    }
}
    
@end
