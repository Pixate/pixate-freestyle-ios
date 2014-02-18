//
//  DejalActivityView.m
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
//  Credit: inspired by Matt Gallagher's LoadingView blog post:
//  http://cocoawithlove.com/2009/04/showing-message-over-iphone-keyboard.html
//


#import "DejalActivityView.h"
#import <QuartzCore/QuartzCore.h>


@interface DejalActivityView ()

@property (nonatomic, strong) UIView *originalView;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *activityLabel;

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@implementation DejalActivityView

@synthesize originalView, borderView, activityIndicator, activityLabel, labelWidth, showNetworkActivityIndicator;

static DejalActivityView *dejalActivityView = nil;

/*
 currentActivityView
 
 Returns the currently displayed activity view, or nil if there isn't one.
 
 Written by DJS 2009-07.
*/

+ (DejalActivityView *)currentActivityView;
{
    return dejalActivityView;
}

/*
 activityViewForView:
 
 Creates and adds an activity view centered within the specified view, using the label "Loading...".  Returns the activity view, already added as a subview of the specified view.
 
 Written by DJS 2009-07.
 Changed by DJS 2010-06 to add "new" prefix to the method name to make it clearer that this returns a retained object.
 Changed by DJS 2011-08 to remove the "new" prefix again.
*/

+ (DejalActivityView *)activityViewForView:(UIView *)addToView;
{
    return [self activityViewForView:addToView withLabel:NSLocalizedString(@"Loading...", @"Default DejalActivtyView label text") width:0];
}

/*
 activityViewForView:withLabel:
 
 Creates and adds an activity view centered within the specified view, using the specified label.  Returns the activity view, already added as a subview of the specified view.
 
 Written by DJS 2009-07.
 Changed by DJS 2010-06 to add "new" prefix to the method name to make it clearer that this returns a retained object.
 Changed by DJS 2011-08 to remove the "new" prefix again.
*/

+ (DejalActivityView *)activityViewForView:(UIView *)addToView withLabel:(NSString *)labelText;
{
    return [self activityViewForView:addToView withLabel:labelText width:0];
}

/*
 activityViewForView:withLabel:width:
 
 Creates and adds an activity view centered within the specified view, using the specified label and a fixed label width.  The fixed width is useful if you want to change the label text while the view is visible.  Returns the activity view, already added as a subview of the specified view.
 
 Written by DJS 2009-07.
 Changed by DJS 2010-06 to add "new" prefix to the method name to make it clearer that this returns a retained object.
 Changed by DJS 2011-08 to remove the "new" prefix again, and move the singleton stuff to here.
*/

+ (DejalActivityView *)activityViewForView:(UIView *)addToView withLabel:(NSString *)labelText width:(NSUInteger)aLabelWidth;
{
    // Immediately remove any existing activity view:
    if (dejalActivityView)
        [self removeView];
    
    // Remember the new view (so this is a singleton):
    dejalActivityView = [[self alloc] initForView:addToView withLabel:labelText width:aLabelWidth];
    
    return dejalActivityView;
}

/*
 initForView:withLabel:width:
 
 Designated initializer.  Configures the activity view using the specified label text and width, and adds as a subview of the specified view.
 
 Written by DJS 2009-07.
 Changed by DJS 2011-08 to move the singleton stuff to the calling class method, where it should be.
*/

- (DejalActivityView *)initForView:(UIView *)addToView withLabel:(NSString *)labelText width:(NSUInteger)aLabelWidth;
{
	if (!(self = [super initWithFrame:CGRectZero]))
		return nil;
	
    // Allow subclasses to change the view to which to add the activity view (e.g. to cover the keyboard):
    self.originalView = addToView;
    addToView = [self viewForView:addToView];
    
    // Configure this view (the background) and its subviews:
    [self setupBackground];
    self.labelWidth = aLabelWidth;
    self.borderView = [self makeBorderView];
    self.activityIndicator = [self makeActivityIndicator];
    self.activityLabel = [self makeActivityLabelWithText:labelText];
    
    // Assemble the subviews:
	[addToView addSubview:self];
    [self addSubview:self.borderView];
    [self.borderView addSubview:self.activityIndicator];
    [self.borderView addSubview:self.activityLabel];
    
	// Animate the view in, if appropriate:
	[self animateShow];
    
	return self;
}

- (void)dealloc;
{
    if ([dejalActivityView isEqual:self])
        dejalActivityView = nil;
}

/*
 removeView
 
 Immediately removes and releases the view without any animation.
 
 Written by DJS 2009-07.
 Changed by DJS 2009-09 to disable the network activity indicator if it was shown by this view.
*/

+ (void)removeView;
{
    if (!dejalActivityView)
        return;
    
    if (dejalActivityView.showNetworkActivityIndicator)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [dejalActivityView removeFromSuperview];
    
    // Remove the global reference:
    dejalActivityView = nil;
}

/*
 viewForView:
 
 Returns the view to which to add the activity view.  By default returns the same view.  Subclasses may override this to change the view.
 
 Written by DJS 2009-07.
*/

- (UIView *)viewForView:(UIView *)view;
{
    return view;
}

/*
 enclosingFrame
 
 Returns the frame to use for the activity view.  Defaults to the superview's bounds.  Subclasses may override this to use something different, if desired.
 
 Written by DJS 2009-07.
*/

- (CGRect)enclosingFrame;
{
    return self.superview.bounds;
}

/*
 setupBackground
 
 Configure the background of the activity view.
 
 Written by DJS 2009-07.
*/

- (void)setupBackground;
{
	self.opaque = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

/*
 makeBorderView
 
 Returns a new view to contain the activity indicator and label.  By default this view is transparent.  Subclasses may override this method, optionally calling super, to use a different or customized view.
 
 Written by DJS 2009-07.
 Changed by DJS 2011-11 to simplify and make it easier to override.
*/

- (UIView *)makeBorderView;
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    
    view.opaque = NO;
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    return view;
}

/*
 makeActivityIndicator
 
 Returns a new activity indicator view.  Subclasses may override this method, optionally calling super, to use a different or customized view.
 
 Written by DJS 2009-07.
 Changed by DJS 2011-11 to simplify and make it easier to override.
*/

- (UIActivityIndicatorView *)makeActivityIndicator;
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [indicator startAnimating];
    
    return indicator;
}

/*
 makeActivityLabelWithText:
 
 Returns a new activity label.  Subclasses may override this method, optionally calling super, to use a different or customized view.
 
 Written by DJS 2009-07.
 Changed by DJS 2011-11 to simplify and make it easier to override.
*/

- (UILabel *)makeActivityLabelWithText:(NSString *)labelText;
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    
    label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.text = labelText;
    
    return label;
}

/*
 layoutSubviews
 
 Positions and sizes the various views that make up the activity view, including after rotation.
 
 Written by DJS 2009-07.
*/

- (void)layoutSubviews;
{
    self.frame = [self enclosingFrame];
    
    // If we're animating a transform, don't lay out now, as can't use the frame property when transforming:
    if (!CGAffineTransformIsIdentity(self.borderView.transform))
        return;
    
    CGSize textSize = [self.activityLabel.text sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
    
    // Use the fixed width if one is specified:
    if (self.labelWidth > 10)
        textSize.width = self.labelWidth;
    
    self.activityLabel.frame = CGRectMake(self.activityLabel.frame.origin.x, self.activityLabel.frame.origin.y, textSize.width, textSize.height);
    
    // Calculate the size and position for the border view: with the indicator to the left of the label, and centered in the receiver:
	CGRect borderFrame = CGRectZero;
    borderFrame.size.width = self.activityIndicator.frame.size.width + textSize.width + 25.0;
    borderFrame.size.height = self.activityIndicator.frame.size.height + 10.0;
    borderFrame.origin.x = floor(0.5 * (self.frame.size.width - borderFrame.size.width));
    borderFrame.origin.y = floor(0.5 * (self.frame.size.height - borderFrame.size.height - 20.0));
    self.borderView.frame = borderFrame;
	
    // Calculate the position of the indicator: vertically centered and at the left of the border view:
    CGRect indicatorFrame = self.activityIndicator.frame;
	indicatorFrame.origin.x = 10.0;
	indicatorFrame.origin.y = 0.5 * (borderFrame.size.height - indicatorFrame.size.height);
    self.activityIndicator.frame = indicatorFrame;
    
    // Calculate the position of the label: vertically centered and at the right of the border view:
	CGRect labelFrame = self.activityLabel.frame;
    labelFrame.origin.x = borderFrame.size.width - labelFrame.size.width - 10.0;
	labelFrame.origin.y = floor(0.5 * (borderFrame.size.height - labelFrame.size.height));
    self.activityLabel.frame = labelFrame;
}

/*
 animateShow
 
 Animates the view into visibility.  Does nothing for the simple activity view.
 
 Written by DJS 2009-07.
*/

- (void)animateShow;
{
    // Does nothing by default
}

/*
 animateRemove
 
 Animates the view out of visibiltiy.  Does nothng for the simple activity view.
 
 Written by DJS 2009-07.
*/

- (void)animateRemove;
{
    // Does nothing by default
}

/*
 setShowNetworkActivityIndicator:
 
 Sets whether or not to show the network activity indicator in the status bar.  Set to YES if the activity is network-related.  This can be toggled on and off as desired while the activity view is visible (e.g. have it on while fetching data, then disable it while parsing it).  By default it is not shown.
 
 Written by DJS 2009-09.
*/

- (void)setShowNetworkActivityIndicator:(BOOL)show;
{
    showNetworkActivityIndicator = show;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = show;
}

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@implementation DejalWhiteActivityView

/*
 makeActivityIndicator
 
 Returns a new activity indicator view.  This subclass uses a white activity indicator instead of gray.
 
 Written by DJS 2009-10.
 Changed by DJS 2011-11 to simplify and make it easier to override.
*/

- (UIActivityIndicatorView *)makeActivityIndicator;
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [indicator startAnimating];
    
    return indicator;
}

/*
 makeActivityLabelWithText:
 
 Returns a new activity label.  This subclass uses white text instead of black.
 
 Written by DJS 2009-10.
 Changed by DJS 2011-11 to simplify and make it easier to override.
*/

- (UILabel *)makeActivityLabelWithText:(NSString *)labelText;
{
    UILabel *label = [super makeActivityLabelWithText:labelText];
    
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    
    return label;
}

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@implementation DejalBezelActivityView

/*
 viewForView:
 
 Returns the view to which to add the activity view.  For the bezel style, if there is a keyboard displayed, the view is changed to the keyboard's superview.
 
 Written by DJS 2009-07.
*/

- (UIView *)viewForView:(UIView *)view;
{
    UIView *keyboardView = [[UIApplication sharedApplication] keyboardView];
    
    if (keyboardView)
        view = keyboardView.superview;
    
    return view;
}

/*
 enclosingFrame
 
 Returns the frame to use for the activity view.  For the bezel style, if there is a keyboard displayed, the frame is changed to cover the keyboard too.
 
 Written by DJS 2009-07.
*/

- (CGRect)enclosingFrame;
{
    CGRect frame = [super enclosingFrame];
    
    if (self.superview != self.originalView)
        frame = [self.originalView convertRect:self.originalView.bounds toView:self.superview];
    
    return frame;
}

/*
 setupBackground
 
 Configure the background of the activity view.
 
 Written by DJS 2009-07.
*/

- (void)setupBackground;
{
    [super setupBackground];
    
	self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
}

/*
 makeBorderView
 
 Returns a new view to contain the activity indicator and label.  The bezel style has a semi-transparent rounded rectangle.
 
 Written by DJS 2009-07.
 Changed by DJS 2011-11 to simplify and make it easier to override.
*/

- (UIView *)makeBorderView;
{
    UIView *view = [super makeBorderView];
    
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    view.layer.cornerRadius = 10.0;
    
    return view;
}

/*
 makeActivityIndicator
 
 Returns a new activity indicator view.  The bezel style uses a large white indicator.
 
 Written by DJS 2009-07.
 Changed by DJS 2011-11 to simplify and make it easier to override.
*/

- (UIActivityIndicatorView *)makeActivityIndicator;
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [indicator startAnimating];
    
    return indicator;
}

/*
 makeActivityLabelWithText:
 
 Returns a new activity label.  The bezel style uses centered white text.
 
 Written by DJS 2009-07.
 Changed by Suleman Sidat 2011-07 to support a multi-line label.
 Changed by DJS 2011-11 to simplify and make it easier to override.
*/

- (UILabel *)makeActivityLabelWithText:(NSString *)labelText;
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    
    label.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap; 
    label.text = labelText;
    
    return label;
}

/*
 layoutSubviews
 
 Positions and sizes the various views that make up the activity view, including after rotation.
 
 Written by DJS 2009-07.
 Changed by Suleman Sidat 2011-07 to support a multi-line label.
*/

- (void)layoutSubviews;
{
    // If we're animating a transform, don't lay out now, as can't use the frame property when transforming:
    if (!CGAffineTransformIsIdentity(self.borderView.transform))
        return;
    
    self.frame = [self enclosingFrame];
    
    CGSize maxSize = CGSizeMake(260, 400);
    CGSize textSize = [self.activityLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]] constrainedToSize:maxSize lineBreakMode:self.activityLabel.lineBreakMode];
    
    // Use the fixed width if one is specified:
    if (self.labelWidth > 10)
        textSize.width = self.labelWidth;
    
    // Require that the label be at least as wide as the indicator, since that width is used for the border view:
    if (textSize.width < self.activityIndicator.frame.size.width)
        textSize.width = self.activityIndicator.frame.size.width + 10.0;
    
    // If there's no label text, don't need to allow height for it:
    if (self.activityLabel.text.length == 0)
        textSize.height = 0.0;
    
    self.activityLabel.frame = CGRectMake(self.activityLabel.frame.origin.x, self.activityLabel.frame.origin.y, textSize.width, textSize.height);
    
    // Calculate the size and position for the border view: with the indicator vertically above the label, and centered in the receiver:
	CGRect borderFrame = CGRectZero;
    borderFrame.size.width = textSize.width + 30.0;
    borderFrame.size.height = self.activityIndicator.frame.size.height + textSize.height + 40.0;
    borderFrame.origin.x = floor(0.5 * (self.frame.size.width - borderFrame.size.width));
    borderFrame.origin.y = floor(0.5 * (self.frame.size.height - borderFrame.size.height));
    self.borderView.frame = borderFrame;
	
    // Calculate the position of the indicator: horizontally centered and near the top of the border view:
    CGRect indicatorFrame = self.activityIndicator.frame;
	indicatorFrame.origin.x = 0.5 * (borderFrame.size.width - indicatorFrame.size.width);
	indicatorFrame.origin.y = 20.0;
    self.activityIndicator.frame = indicatorFrame;
    
    // Calculate the position of the label: horizontally centered and near the bottom of the border view:
	CGRect labelFrame = self.activityLabel.frame;
    labelFrame.origin.x = floor(0.5 * (borderFrame.size.width - labelFrame.size.width));
	labelFrame.origin.y = borderFrame.size.height - labelFrame.size.height - 10.0;
    self.activityLabel.frame = labelFrame;
}

/*
 animateShow
 
 Animates the view into visibility.  For the bezel style, fades in the background and zooms the bezel down from a large size.
 
 Written by DJS 2009-07.
*/

- (void)animateShow;
{
    self.alpha = 0.0;
    self.borderView.transform = CGAffineTransformMakeScale(3.0, 3.0);
    
	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:5.0];            // Uncomment to see the animation in slow motion
	
    self.borderView.transform = CGAffineTransformIdentity;
    self.alpha = 1.0;
    
	[UIView commitAnimations];
}

/*
 animateRemove
 
 Animates the view out, deferring the removal until the animation is complete.  For the bezel style, fades out the background and zooms the bezel down to half size.
 
 Written by DJS 2009-07.
 Changed by DJS 2009-09 to disable the network activity indicator if it was shown by this view.
*/

- (void)animateRemove;
{
    if (self.showNetworkActivityIndicator)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.borderView.transform = CGAffineTransformIdentity;
    
	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:5.0];            // Uncomment to see the animation in slow motion
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
	
    self.borderView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.alpha = 0.0;
    
	[UIView commitAnimations];
}

- (void)removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    [[self class] removeView];
}

/*
 removeViewAnimated:
 
 Animates the view out from the superview and releases it, or simply removes and releases it immediately if not animating.
 
 Written by DJS 2009-07.
*/

+ (void)removeViewAnimated:(BOOL)animated;
{
    if (!dejalActivityView)
        return;
    
    if (animated)
        [dejalActivityView animateRemove];
    else
        [[self class] removeView];
}

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@implementation DejalKeyboardActivityView

/*
 activityView
 
 Creates and adds a keyboard-style activity view, using the label "Loading...".  Returns the activity view, already covering the keyboard, or nil if the keyboard isn't currently displayed.
 
 Written by DJS 2009-07.
 Changed by DJS 2010-06 to add "new" prefix to the method name to make it clearer that this returns a retained object.
 Changed by DJS 2011-08 to remove the "new" prefix again.
*/

+ (DejalKeyboardActivityView *)activityView;
{
    return [self activityViewWithLabel:NSLocalizedString(@"Loading...", @"Default DejalActivtyView label text")];
}

/*
 activityViewWithLabel:
 
 Creates and adds a keyboard-style activity view, using the specified label.  Returns the activity view, already covering the keyboard, or nil if the keyboard isn't currently displayed.
 
 Written by DJS 2009-07.
 Changed by DJS 2010-06 to add "new" prefix to the method name to make it clearer that this returns a retained object.
 Changed by DJS 2011-08 to remove the "new" prefix again.
*/

+ (DejalKeyboardActivityView *)activityViewWithLabel:(NSString *)labelText;
{
    UIView *keyboardView = [[UIApplication sharedApplication] keyboardView];
    
    if (!keyboardView)
        return nil;
    else
        return (DejalKeyboardActivityView *)[self activityViewForView:keyboardView withLabel:labelText];
}

/*
 viewForView:
 
 Returns the view to which to add the activity view.  For the keyboard style, returns the same view (which will already be the keyboard).
 
 Written by DJS 2009-07.
*/

- (UIView *)viewForView:(UIView *)view;
{
    return view;
}

/*
 animateShow
 
 Animates the view into visibility.  For the keyboard style, simply fades in.
 
 Written by DJS 2009-07.
*/

- (void)animateShow;
{
    self.alpha = 0.0;
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	
    self.alpha = 1.0;
    
	[UIView commitAnimations];
}

/*
 animateRemove
 
 Animates the view out, deferring the removal until the animation is complete.  For the keyboard style, simply fades out.
 
 Written by DJS 2009-07.
*/

- (void)animateRemove;
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
	
    self.alpha = 0.0;
    
	[UIView commitAnimations];
}

/*
 setupBackground
 
 Configure the background of the activity view.
 
 Written by DJS 2009-07.
*/

- (void)setupBackground;
{
    [super setupBackground];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
}

/*
 makeBorderView
 
 Returns a new view to contain the activity indicator and label.  The keyboard style has a transparent border.
 
 Written by DJS 2009-07.
 Changed by DJS 2011-11 to simplify and make it easier to override.
*/

- (UIView *)makeBorderView;
{
    UIView *view = [super makeBorderView];
    
    view.backgroundColor = nil;
    
    return view;
}

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@implementation UIApplication (KeyboardView)

//  keyboardView
//
//  Copyright Matt Gallagher 2009. All rights reserved.
// 
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

- (UIView *)keyboardView;
{
	NSArray *windows = [self windows];
	for (UIWindow *window in [windows reverseObjectEnumerator])
	{
		for (UIView *view in [window subviews])
		{
            // UIPeripheralHostView is used from iOS 4.0, UIKeyboard was used in previous versions:
			if (!strcmp(object_getClassName(view), "UIPeripheralHostView") || !strcmp(object_getClassName(view), "UIKeyboard"))
			{
				return view;
			}
		}
	}
	
	return nil;
}

@end

