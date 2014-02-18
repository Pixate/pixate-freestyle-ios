//
//  PickerPreviewController.m
//  Playground
//
//  Created by Paul Colton on 11/19/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PickerPreviewController.h"
#import <PixateFreestyle/PixateFreestyle.h>

@interface PickerPreviewController ()

@end

@implementation PickerPreviewController

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 6;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"Item %d", row];
}

@end
