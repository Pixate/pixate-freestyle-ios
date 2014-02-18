//
//  ActionSheetPreviewController.h
//  Playground
//
//  Created by Paul Colton on 12/12/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionSheetPreviewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIButton *button1;
@property (nonatomic, weak) IBOutlet UIButton *button2;

-(IBAction)actionOne:(id)sender;
-(IBAction)actionTwo:(id)sender;

@end
