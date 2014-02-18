//
//  PixateFreestyleFormButtonController.h
//  PixateFreestyle
//
//  Copyright 2013 Pixate, Inc.
//  Licensed under the MIT License
//

#import <UIKit/UIKit.h>

@interface PixateFreestyleFormButtonController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end
