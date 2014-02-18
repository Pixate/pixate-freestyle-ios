//
//  DejalActivityView.h
//  Dejal Open Source
//
//  Created by David Sinclair on 2009-07-26.
//  Copyright (c) 2009-2012 Dejal Systems, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <UIKit/UIKit.h>


@interface DejalActivityView : UIView

// The view to contain the activity indicator and label.  The bezel style has a semi-transparent rounded rectangle, others are fully transparent:
@property (nonatomic, strong, readonly) UIView *borderView;

// The activity indicator view:
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicator;

// The activity label:
@property (nonatomic, strong, readonly) UILabel *activityLabel;

// A fixed width for the label text, or zero to automatically calculate the text size (normally set on creation of the view object):
@property (nonatomic) NSUInteger labelWidth;

// Whether to show the network activity indicator in the status bar.  Set to YES if the activity is network-related.  This can be toggled on and off as desired while the activity view is visible (e.g. have it on while fetching data, then disable it while parsing it).  By default it is not shown:
@property (nonatomic) BOOL showNetworkActivityIndicator;

//  Returns the currently displayed activity view, or nil if there isn't one:
+ (DejalActivityView *)currentActivityView;

// Creates and adds an activity view centered within the specified view, using the label "Loading...".  Returns the activity view, already added as a subview of the specified view:
+ (DejalActivityView *)activityViewForView:(UIView *)addToView;

// Creates and adds an activity view centered within the specified view, using the specified label.  Returns the activity view, already added as a subview of the specified view:
+ (DejalActivityView *)activityViewForView:(UIView *)addToView withLabel:(NSString *)labelText;

// Creates and adds an activity view centered within the specified view, using the specified label and a fixed label width.  The fixed width is useful if you want to change the label text while the view is visible.  Returns the activity view, already added as a subview of the specified view:
+ (DejalActivityView *)activityViewForView:(UIView *)addToView withLabel:(NSString *)labelText width:(NSUInteger)aLabelWidth;

// Designated initializer.  Configures the activity view using the specified label text and width, and adds as a subview of the specified view:
- (DejalActivityView *)initForView:(UIView *)addToView withLabel:(NSString *)labelText width:(NSUInteger)aLabelWidth;

// Immediately removes and releases the view without any animation:
+ (void)removeView;

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


// These methods are exposed for subclasses to override to customize the appearance and behavior; see the implementation for details:

@interface DejalActivityView ()

- (UIView *)viewForView:(UIView *)view;
- (CGRect)enclosingFrame;
- (void)setupBackground;
- (UIView *)makeBorderView;
- (UIActivityIndicatorView *)makeActivityIndicator;
- (UILabel *)makeActivityLabelWithText:(NSString *)labelText;
- (void)animateShow;
- (void)animateRemove;

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@interface DejalWhiteActivityView : DejalActivityView

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@interface DejalBezelActivityView : DejalActivityView

// Animates the view out from the superview and releases it, or simply removes and releases it immediately if not animating:
+ (void)removeViewAnimated:(BOOL)animated;

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@interface DejalKeyboardActivityView : DejalBezelActivityView

// Creates and adds a keyboard-style activity view, using the label "Loading...".  Returns the activity view, already covering the keyboard, or nil if the keyboard isn't currently displayed:
+ (DejalKeyboardActivityView *)activityView;

// Creates and adds a keyboard-style activity view, using the specified label.  Returns the activity view, already covering the keyboard, or nil if the keyboard isn't currently displayed:
+ (DejalKeyboardActivityView *)activityViewWithLabel:(NSString *)labelText;

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@interface UIApplication (KeyboardView)

- (UIView *)keyboardView;

@end;

