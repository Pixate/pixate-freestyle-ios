//
//  LDMasterViewController.m
//  LivelyDemo
//
//  Created by Romain Goyet on 24/04/12.
//  Copyright (c) 2012 Applidium. All rights reserved.
//

#import "LDMasterViewController.h"
#import "ADLivelyTableView.h"

@implementation LDMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"ADLivelyDemo";
        _objects = [[NSMutableArray alloc] init];
        for (int i = 0; i < 200; i++) {
            [(NSMutableArray *)_objects addObject:[NSString stringWithFormat:@"Lively row #%d", i]];
        }
    }
    return self;
}
							
- (void)dealloc {
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * transitionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(pickTransform:)];
    self.navigationItem.rightBarButtonItem = transitionButton;
    ADLivelyTableView * livelyTableView = (ADLivelyTableView *)self.tableView;
    livelyTableView.initialCellTransformBlock = ADLivelyTransformFan;
    [transitionButton release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)pickTransform:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick a transform"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Fan", @"Curl", @"Fade", @"Helix", @"Wave", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
    [actionSheet release];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    ADLivelyTableView * livelyTableView = (ADLivelyTableView *)self.tableView;
    NSArray * transforms = [NSArray arrayWithObjects:ADLivelyTransformFan, ADLivelyTransformCurl, ADLivelyTransformFade, ADLivelyTransformHelix, ADLivelyTransformWave, nil];

    if (buttonIndex < [transforms count]) {
        livelyTableView.initialCellTransformBlock = [transforms objectAtIndex:buttonIndex];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        UIView * backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.backgroundView = backgroundView;
        [backgroundView release];
    }

    cell.textLabel.text = [_objects objectAtIndex:indexPath.row];

    UIColor * altBackgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    cell.backgroundView.backgroundColor = [indexPath row] % 2 == 0 ? [UIColor whiteColor] : altBackgroundColor;
    cell.textLabel.backgroundColor = cell.backgroundView.backgroundColor;

    return cell;
}
@end
