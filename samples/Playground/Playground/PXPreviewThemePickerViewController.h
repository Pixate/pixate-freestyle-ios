//
//  PXPreviewPickerViewController.h
//  Visualizer
//
//  Created by Paul Colton on 10/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

// Protocol for receiving events from the table view
@protocol PXPreviewThemePickerDelegate

- (void)previewThemePickerItemSelected:(NSString *)viewName;

@end

// Main class descriptor
@interface PXPreviewThemePickerViewController : UITableViewController

@property (nonatomic, assign) id<PXPreviewThemePickerDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style withList:(NSDictionary *)list;

@end
