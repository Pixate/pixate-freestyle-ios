//
//  ActionSheetPreviewController.m
//  Playground
//
//  Created by Paul Colton on 12/12/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "ActionSheetPreviewController.h"
#import <PixateFreestyle/PixateFreestyle.h>

@implementation ActionSheetPreviewController
{
    UIActionSheet *actionSheet;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionOne:(UIButton *)sender
{
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"My Sheet Title"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel Button"
                                              destructiveButtonTitle:@"Destructive Button"
                                                   otherButtonTitles:@"Other Button 1", @"Other Button 2", nil];

    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.styleId = @"myActionSheet1";
    [actionSheet showFromRect:sender.frame inView:self.view animated:YES];
    
}

-(IBAction)actionTwo:(UIButton *)sender
{
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Title"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel Button"
                                               destructiveButtonTitle:@"Destructive Button"
                                                    otherButtonTitles:@"Other Button 1", @"Other Button 2", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.styleId = @"myActionSheet2";
    [actionSheet showFromRect:sender.frame inView:self.view animated:YES];
    [actionSheet showInView:self.view];
}

@end
