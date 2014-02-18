//
//  PXViewController.h
//  Visualizer
//
//  Created by Paul Colton on 9/19/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "PXPreviewThemePickerViewController.h"
#import "iCarousel.h"
#import "iConsole.h"

@interface PXViewController : UIViewController <UITextViewDelegate,
                                                PXPreviewThemePickerDelegate,
                                                MFMailComposeViewControllerDelegate,
                                                UIPopoverControllerDelegate,
                                                iConsoleDelegate
                                                >

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *editorView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextView *errorView;
@property (weak, nonatomic) IBOutlet UIButton *themeSelect;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic, retain) IBOutlet iCarousel *carousel;
@property (nonatomic, retain) PXPreviewThemePickerViewController *previewPicker;
@property (nonatomic, retain) UIPopoverController *previewPickerPopover;

- (IBAction)themeSelectAction:(id)sender;
- (IBAction)prefsSelectAction:(id)sender;
- (IBAction)sendEmail:(id)sender;
- (IBAction)openHelp:(id)sender;

- (void)switchToNamedPreview:(NSString *)previewName;

@end

//This should probably not be commented out :-)
//#define REBUILD_PREVIEWS_TO_PATH "/Users/pcolton/Desktop/imgs"

