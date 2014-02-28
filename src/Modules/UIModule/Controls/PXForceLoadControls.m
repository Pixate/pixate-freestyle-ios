/*
 * Copyright 2012-present Pixate, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  PXForceLoadControls.m
//  Pixate
//
//  Created by Paul Colton on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXForceLoadControls.h"

#import "PXMKAnnotationView.h"
#import "PXMKMapView.h"
#import "PXUICollectionView.h"
#import "PXUICollectionViewCell.h"
#import "PXUINavigationBar.h"
#import "PXUITableView.h"
#import "PXUITableViewCell.h"
#import "PXUITableViewHeaderFooterView.h"
#import "PXMPVolumeView.h"
#import "PXUIActionSheet.h"
#import "PXUIActivityIndicatorView.h"
#import "PXUIButton.h"
#import "PXUIDatePicker.h"
#import "PXUIImageView.h"  
#import "PXUILabel.h"
#import "PXUIPageControl.h"
#import "PXUIPickerView.h"
#import "PXUIProgressView.h"
#import "PXUIRefreshControl.h"
#import "PXUIScrollView.h"
#import "PXUISearchBar.h"
#import "PXUISegmentedControl.h"
#import "PXUISlider.h"
#import "PXUIStepper.h"
#import "PXUISwitch.h"
#import "PXUITabBar.h"
#import "PXUITextField.h"
#import "PXUITextView.h"
#import "PXUIToolbar.h"
#import "PXUIView.h"
#import "PXUIWebView.h"
#import "PXUIWindow.h"

@implementation PXForceLoadControls

+(void)forceLoad
{
    [PXMKAnnotationView class];
    [PXMKMapView class];
    [PXUICollectionView class];
    [PXUICollectionViewCell class];
    [PXUINavigationBar class];
    [PXUITableView class];
    [PXUITableViewCell class];
    [PXUITableViewHeaderFooterView class];
    [PXMPVolumeView class];
    [PXUIActionSheet class];
    [PXUIActivityIndicatorView class];
    [PXUIButton class];
    [PXUIDatePicker class];
    [PXUIImageView class];
    [PXUILabel class];
    [PXUIPageControl class];
    [PXUIPickerView class];
    [PXUIProgressView class];
    [PXUIRefreshControl class];
    [PXUIScrollView class];
    [PXUISearchBar class];
    [PXUISegmentedControl class];
    [PXUISlider class];
    [PXUIStepper class];
    [PXUISwitch class];
    [PXUITabBar class];
    [PXUITextField class];
    [PXUITextView class];
    [PXUIToolbar class];
    [PXUIView class];
    [PXUIWebView class];
    [PXUIWindow class];
}

@end
