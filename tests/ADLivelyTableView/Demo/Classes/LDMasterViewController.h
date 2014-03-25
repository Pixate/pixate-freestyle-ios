//
//  LDMasterViewController.h
//  LivelyDemo
//
//  Created by Romain Goyet on 24/04/12.
//  Copyright (c) 2012 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDMasterViewController : UITableViewController <UIActionSheetDelegate> {
    NSArray * _objects;
}
- (IBAction)pickTransform:(id)sender;
@end
