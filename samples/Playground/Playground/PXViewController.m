//
//  PXViewController.m
//  Visualizer
//
//  Created by Paul Colton on 9/19/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <PixateFreestyle/PixateFreestyle.h>
#import <QuartzCore/QuartzCore.h>
#import "PXViewController.h"
#import "PXPreviewCustomClassProtocol.h"
#import "ReflectionView.h"
#import "DejalActivityView.h"
#import "IASKAppSettingsViewController.h"
#import "NSObject+Blocks.h"

#define PREVIEW_WIDTH  500
#define PREVIEW_HEIGHT 335

@implementation PXViewController
{
    id currentUpdatingBlock_;
    NSString *currentRootNameView_;
    NSString *currentFullNameView_;
    NSDictionary *previews_;
    NSDictionary *themes_;
    NSArray *previewSorted_;
    NSString *currentCSS_;
    NSString *currentTheme_;
    UIPopoverController *settingsPopover_;
    NSUserDefaults *standardUserDefaults_;
    BOOL reloadCurrentlyDisplayedPreview_;
    double carouselArc_, carouselRadius_, carouselSpacing_;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        /**
         * This is a list of the themes supported, which correspond to a
         * .css file of the same name + "Theme" (e.g. DefaultTheme.css).
         */
        themes_ = @{
            // Theme Name : [ Display Name, Use Light Theme ]
            @"Medley"       : @[ @"Medley",       @NO  ],
            @"FlatColor"    : @[ @"Flat Colors",   @YES ],
            @"PixelPerfect" : @[ @"Pixel Perfect", @NO  ],
        };
        
        /**
         * These are the names of the preview panels, which correspond to
         * a .xib file of the same name + "Preview" (e.g. ButtonPreview.xib)
         * and/or a .m file of the same name + "Preview" (e.g. ButtonPreview.m).
         */
        previews_ = @{
            // Preview file(s)name : Preview Display Name
            //@"ActionSheet"              : @"Action Sheet",
            @"ActivityIndicatorView"    : @"Activity Indicator",
            @"Button"                   : @"Button",
            @"ImageView"                : @"Image View",
            @"Label"                    : @"Label",
            @"MapView"                  : @"Maps",
            @"NavigationBar"            : @"Navigation Bar",
            @"PageControl"              : @"Paging Control",
            @"ProgressView"             : @"Progress View",
            @"SearchBar"                : @"Search Bars",
            @"SegmentedControl"         : @"Segmented Control",
            @"Slider"                   : @"Sliders",
            @"Stepper"                  : @"Steppers",
            @"Switch"                   : @"Switches",
            @"TabBar"                   : @"Tab Bar",
            @"TableView"                : @"Table View",
            @"TextField"                : @"Text Fields",
            @"TextView"                 : @"Text Views",
            @"Toolbar"                  : @"Tool Bars",
            @"VectorGraphics"           : @"Scalable Vector Graphics",
            @"View"                     : @"Generic View",
            //@"WebView"                  : @"Web View",
        };
        
        // Add specific 6.0+ previews here...
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6"))
        {
            // Create a mutable version of the static list
            NSMutableDictionary *additionalPreviews = [NSMutableDictionary dictionaryWithDictionary:previews_];

            // Add additional items here
            [additionalPreviews addEntriesFromDictionary:@{ @"CollectionView": @"Collections View" }];
            
            // Reassign the newly modified dictionary to the original ivar
            previews_ = additionalPreviews;
        }
        
        // Create a sorted list of previews
        previewSorted_ = [previews_ keysSortedByValueUsingSelector:@selector(compare:)];
        
        // Init settings
        standardUserDefaults_ = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // iConsole settings
    [iConsole sharedConsole].delegate = self;
    [iConsole sharedConsole].infoString = @"Pixate Playground Console";
    [iConsole sharedConsole].logSubmissionEmail = @"support@pixate.com";
    [[iConsole sharedConsole] performSelector:@selector(rotateView:) withObject:nil];
    
    // Listen to changes in the textview
    [_textView setDelegate:self];

    // iCarousel settings
    self.carousel.type = iCarouselTypeCylinder;

    // Force carousel settings to be loaded from settings
    [self popoverControllerDidDismissPopover:nil];
    
    // Load default theme
    [self previewThemePickerItemSelected:@"PixelPerfect"];
    
    // Apply light theme mode prefs
    // [self applyCurrentLightMode:[[PXViewController retrieveFromUserDefaults:@"playground_lightmode"] boolValue]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#ifdef REBUILD_PREVIEWS_TO_PATH
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Preparing previews..."];
    [self buildImageForIndex:0];
#else
    [self showDefaultPreview];
#endif

}

-(void)showDefaultPreview
{
    [self.carousel reloadData];
    [self.carousel scrollToItemAtIndex:[previewSorted_ indexOfObject:@"ImageView"] animated:NO];
    [self displayCurrentPreview:self.carousel];
}

-(void)buildImageForIndex:(NSNumber *)index
{
    int i = index.intValue;
    
    if(i >= [previewSorted_ count])
    {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self showDefaultPreview];
        return;
    }
    
    if([self fileExsits:previewSorted_[i]] == NO)
    {
        [self.carousel scrollToItemAtIndex:i animated:NO];
        [self displayCurrentPreview:self.carousel];
        
        [self performSelector:@selector(saveImageForCurrentIndex:)
                   withObject:@(i)
                   afterDelay:1];

    }
    else
    {
        [self buildImageForIndex:@(i+1)];
    }
}

-(void)saveImageForCurrentIndex:(NSNumber *)index
{
    int i = index.intValue;
    NSString *osVersion = @"";
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        osVersion = @"7";
    }
    
    // Retina
    NSString *name = [NSString stringWithFormat:@"%@_%@%@@2x", [self imagePrefix], previewSorted_[i], osVersion];
    UIImage *screenShot = [self getCurrentScreenshotInSize:CGSizeMake(PREVIEW_WIDTH, PREVIEW_HEIGHT)];
    [self saveImage:name withImage:screenShot];

    // Non-retina
    name = [NSString stringWithFormat:@"%@_%@%@", [self imagePrefix], previewSorted_[i], osVersion];
    screenShot = [self getCurrentScreenshotInSize:CGSizeMake(PREVIEW_WIDTH/2.0f, PREVIEW_HEIGHT/2.0f)];
    [self saveImage:name withImage:screenShot];

    [self buildImageForIndex:@(i+1)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; //UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)switchToPreviewCSS;
{
    if(currentFullNameView_)
    {
        NSString *startRangeMarker = [NSString stringWithFormat:@"/** %@ **/", currentFullNameView_];
        NSRange start = [currentCSS_ rangeOfString:startRangeMarker];
        start.location += startRangeMarker.length + 2;
        
        NSRange end = [currentCSS_ rangeOfString:[NSString stringWithFormat:@"/** End of %@ **/", currentFullNameView_]];

        if(end.location > start.location)
        {
            _textView.text = [currentCSS_ substringWithRange:NSMakeRange(start.location, end.location - start.location)];
        }
        
        [_textView scrollRangeToVisible:NSMakeRange(0, 0)];
        
        [self setCSSAndApply:_textView.text];
    }
}

-(BOOL)isLightModeForTheme:(NSString *)themeName
{
    NSArray *themeDetails = [themes_ objectForKey:themeName];
    return [themeDetails[1] boolValue];
}

-(NSString *)displayNameForTheme:(NSString *)themeName
{
    NSArray *themeDetails = [themes_ objectForKey:themeName];
    return themeDetails[0];
}

#pragma mark - PreviewPicker protocol

-(void)previewThemePickerItemSelected:(NSString *)themeName
{
    [self.previewPickerPopover dismissPopoverAnimated:YES];

    NSString *fullThemeName = [NSString stringWithFormat:@"%@Theme", themeName];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:fullThemeName
                                                     ofType:@"css"];

    currentTheme_ = themeName;
    
    currentCSS_ = [NSString stringWithContentsOfFile:path
                                              encoding:NSUTF8StringEncoding error:NULL];

    [self applyCurrentLightMode:[self isLightModeForTheme:currentTheme_]];
    [self switchToPreviewCSS];
    [self.carousel reloadData];

    [self performBlock:^{
        [self.themeSelect setTitle:[self displayNameForTheme:themeName]
                          forState:UIControlStateNormal];
        [self.themeSelect setTitle:[self displayNameForTheme:themeName]
                          forState:UIControlStateHighlighted];
    } afterDelay:0.1];
}

#pragma mark - Apply CSS to view

-(void)setCSSAndApply:(NSString *)css
{
    [_textView resignFirstResponder];
    
    [self applyStyle:css];

    __weak UITextView *weakview = _textView;
    
    [UIView transitionWithView:self.previewView
                      duration:.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        weakview.text = css;
                    }
                    completion:^(BOOL finished) {
                        // Scroll to top
                        [weakview scrollRangeToVisible:NSMakeRange(0, 0)];
                    }];
}

- (void)applyStyle
{
    [self applyStyle:_textView.text];
}

- (void)applyStyle:(NSString *)css
{
    PXStylesheet *sheet = [PixateFreestyle styleSheetFromSource:css
                                                  withOrigin:PXStylesheetOriginUser];
    
    // show or clear any errors
    if (sheet.errors && sheet.errors.count)
    {
        _errorView.text = [NSString stringWithFormat:@"Errors:\n%@", [sheet.errors componentsJoinedByString:@"\n"]];
    }
    else
    {
        _errorView.text = @"";
        
        // apply the new stylesheet
        [self.previewView updateStyles];
    }
}

#pragma mark - Light mode handler

- (void)applyCurrentLightMode:(BOOL)lightMode
{
    if(lightMode)
    {
        [PixateFreestyle styleSheetFromFilePath:[[NSBundle mainBundle] pathForResource:@"light" ofType:@"css"]
                                   withOrigin:PXStylesheetOriginApplication];
    }
    else
    {
        [PixateFreestyle styleSheetFromFilePath:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"css"]
                                   withOrigin:PXStylesheetOriginApplication];
    }

    [PixateFreestyle applyStylesheets];
}

#pragma mark - Send email button action handler

- (IBAction)sendEmail:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        // Grab CSS
        NSString *css = _textView.text;

        // Grab the screenshot
        UIImage *screenShot = [self getCurrentScreenshotInSize:CGSizeMake(PREVIEW_WIDTH, PREVIEW_HEIGHT)];
    
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"My CSS for styling UI%@...", currentRootNameView_]];
        NSData *imageData = UIImagePNGRepresentation(screenShot);
        [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"PixatePlayground"];

        NSString *emailBody = [NSString stringWithFormat:@"I just styled these native iOS controls using Pixate (their site is at http://www.pixate.com)! Here's my CSS:\n\n%@\n\n", css];
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Your device doesn't seem to be configured for email."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - Screenshots

- (UIImage *)getCurrentScreenshotInSize:(CGSize)size
{
    // Grab view image
    UIGraphicsBeginImageContext(CGSizeMake(PREVIEW_WIDTH, PREVIEW_HEIGHT));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_previewView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;}

#pragma mark - Emailer callback

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Could not send the email."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
			break;
        }
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Settings button action handler and popover callback

- (IBAction)prefsSelectAction:(UIButton *)sender
{
    IASKAppSettingsViewController *appSettings = [[IASKAppSettingsViewController alloc] init];

    appSettings.title = NSLocalizedString(@"Settings", @"Settings");
    appSettings.delegate = self;
    appSettings.showCreditsFooter = NO;
    appSettings.showDoneButton = NO;
    
    // Hide the carousel settings by default
    appSettings.hiddenKeys = [NSSet setWithArray:@[@"carousel_settings", @"playground_lightmode"]];
    
    UINavigationController *appSettingsNav = [[UINavigationController alloc] initWithRootViewController:appSettings];

    
    settingsPopover_ = [[UIPopoverController alloc] initWithContentViewController:appSettingsNav];
    
    settingsPopover_.delegate = self;
    [settingsPopover_ presentPopoverFromRect:sender.frame
                                      inView:self.view
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [standardUserDefaults_ synchronize];
    
//    [self applyCurrentLightMode:[[PXViewController retrieveFromUserDefaults:@"playground_lightmode"] boolValue]];
    
    carouselArc_ = [[PXViewController retrieveFromUserDefaults:@"carousel_arc" withPlist:@"Carousel.plist"] doubleValue];
    carouselRadius_ = [[PXViewController retrieveFromUserDefaults:@"carousel_radius" withPlist:@"Carousel.plist"] doubleValue];
    carouselSpacing_ = [[PXViewController retrieveFromUserDefaults:@"carousel_spacing" withPlist:@"Carousel.plist"] doubleValue];
    
    [self.carousel setNeedsLayout];
}

#pragma mark - Theme selection button handler

- (IBAction)themeSelectAction:(UIButton *)sender
{
    if (_previewPicker == nil)
    {
        self.previewPicker = [[PXPreviewThemePickerViewController alloc]
                             initWithStyle:UITableViewStylePlain
                              withList:themes_];
        _previewPicker.delegate = self;
        self.previewPickerPopover = [[UIPopoverController alloc]
                                    initWithContentViewController:_previewPicker];
    }
    
    [self.previewPickerPopover presentPopoverFromRect:sender.frame
                                               inView:self.view
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
}

#pragma mark - Open help action handler

- (IBAction)openHelp:(id)sender
{
    NSString *baseUrl = [NSString
                         stringWithFormat:@"http://www.pixate.com/docs/Playground-%@/Pixate Reference.html",
     [[[NSBundle mainBundle] infoDictionary]
      objectForKey:@"CFBundleShortVersionString"]];
    
    // URL-encode the url
    NSString *url = [baseUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    // Create the anchor link and lower-case it
    NSString *anchor = [[NSString stringWithFormat:@"UI%@", currentRootNameView_] lowercaseString];
    
    if([currentRootNameView_ isEqualToString:@"MapView"])
    {
        anchor = [[NSString stringWithFormat:@"MK%@", currentRootNameView_] lowercaseString];
    }
    
    // Build the final URL
    url = [NSString stringWithFormat:@"%@#%@", url, anchor];
    
    // Launch the browser
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)switchToNamedPreview:(NSString *)previewName
{
    // Clear preview
    [[_previewView subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];

    // Controller cache
    static id<PXPreviewCustomClassProtocol> controllerCache;

    // Clear out old preview
    if([controllerCache respondsToSelector:@selector(setPreviewView:)])
    {
        controllerCache.previewView = nil;
    }

    // Check for a custom controller
    Class customClass = NSClassFromString(previewName);
    
    if([customClass conformsToProtocol:@protocol(PXPreviewCustomClassProtocol)])
    {
        id<PXPreviewCustomClassProtocol> controller = [[customClass alloc] init];
        
        if([controller respondsToSelector:@selector(initializeCustomController)])
        {
            [controller initializeCustomController];
        }
        
        if([controller respondsToSelector:@selector(reloadPreviewOnEdit)])
        {
            reloadCurrentlyDisplayedPreview_ = [controller reloadPreviewOnEdit];
        }
        else
        {
            reloadCurrentlyDisplayedPreview_ = YES;
        }
        
        [_previewView addSubview:controller.previewView];
        
        // Cache the controller so it's retained
        controllerCache = controller;
    }
    else
    {
        // Cache the controller so it's retained
        controllerCache = nil;

        // Load our view
        UIView *viewToAdd = [[[NSBundle mainBundle]
                                loadNibNamed:previewName
                                owner:nil
                                options:nil] objectAtIndex:0];
        
        if(viewToAdd)
        {
            // Add it to our preview view
            [_previewView addSubview:viewToAdd];
        }
    }
}

#pragma mark - UITextView delegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [NSObject cancelBlock:currentUpdatingBlock_];

    __weak id weakSelf = self;
    
    currentUpdatingBlock_ = [weakSelf performBlock:^{
        
        if(currentFullNameView_ && reloadCurrentlyDisplayedPreview_)
        {
            [weakSelf switchToNamedPreview:currentFullNameView_];
        }
        
        [weakSelf applyStyle];
        
    } afterDelay:0.7];

    return YES;
}

#pragma mark - iCarousel methods

-(void)scrollCarouselToIndex:(NSNumber *)index
{
    [self.carousel scrollToItemAtIndex:index.intValue animated:YES];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [previewSorted_ count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(ReflectionView *)view
{
    UIImageView *imageView = nil;

    //create new view if no view is available for recycling
    if (view == nil)
    {
		view = [[ReflectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PREVIEW_WIDTH/2.0f, (PREVIEW_HEIGHT/2.0f))];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PREVIEW_WIDTH/2.0f, (PREVIEW_HEIGHT/2.0f))];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = 1;
        [view addSubview:imageView];
    }
    else
    {
        imageView = (UIImageView *)[view viewWithTag:1];
    }
    
    imageView.image = [self loadImage:previewSorted_[index]];
    
    //update reflection
    [view update];

    return view;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    self.titleLabel.text = [previews_ objectForKey:previewSorted_[[self.carousel currentItemIndex]]];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if(carousel.scrolling == NO)
    {
        [self carouselDidEndScrollingAnimation:carousel];
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    [self displayCurrentPreview:carousel];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{

    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return NO;
        }
        case iCarouselOptionArc:
        {
            return 2 * M_PI * carouselArc_;
        }
        case iCarouselOptionRadius:
        {
            return value * carouselRadius_;
        }
        case iCarouselOptionSpacing:
        {
            return value * carouselSpacing_;
        }
        default:
        {
            return value;
        }
    }
}

#pragma mark - Carousel helpers

- (void)displayCurrentPreview:(iCarousel *)carousel
{
    int index = [carousel currentItemIndex];
    
    NSString *fullName = [NSString stringWithFormat:@"%@Preview", previewSorted_[index]];
    
    currentFullNameView_ = fullName;
    currentRootNameView_ = previewSorted_[index];
    
    [self switchToNamedPreview:currentFullNameView_];
    [self switchToPreviewCSS];
}

#pragma mark - File loading / saving

- (NSString *)imagePrefix
{
    return [NSString stringWithFormat:@"Preview_%@", currentTheme_];
}

- (BOOL) fileExsits:(NSString *)name
{
    NSString *getImagePath = [self filenameForName:name];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:getImagePath];
    return fileExists;
}

- (UIImage *)loadImage:(NSString *)name
{
    NSString *osVersion = @"";
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        osVersion = @"7";
    }

    NSString *resourceName = [NSString stringWithFormat:@"%@_%@%@", [self imagePrefix], name, osVersion];
    UIImage *img = [UIImage imageNamed:resourceName];
    return img;
}

- (void) saveImage:(NSString *)name withImage:(UIImage *)image
{
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(image)];
    NSString *getImagePath = [self filenameForName:name];
    [data writeToFile:getImagePath atomically:YES];
}

- (NSString *)filenameForName:(NSString *)name
{
    NSString *previewsDirectory = nil;
    
#ifdef REBUILD_PREVIEWS_TO_PATH
    previewsDirectory = @REBUILD_PREVIEWS_TO_PATH;
#endif
    
    NSAssert(previewsDirectory,
             @"filenameForName: Please set the 'previewsDirectory' ivar to a local path for preview image generation.");
    
    NSString *getImagePath = [previewsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
    return getImagePath;
}

#pragma mark - NSUserDefaults methods (from: http://greghaygood.com/2009/03/09/updating-nsuserdefaults-from-settingsbundle)

+ (void)saveToUserDefaults:(NSString*)key value:(NSString*)valueString
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
	if (standardUserDefaults) {
		[standardUserDefaults setObject:valueString forKey:key];
		[standardUserDefaults synchronize];
	} else {
		NSLog(@"Unable to save %@ = %@ to user defaults", key, valueString);
	}
}

+ (NSString*)retrieveFromUserDefaults:(NSString*)key
{
    return [PXViewController retrieveFromUserDefaults:key withPlist:@"Root.plist"];
}

+ (NSString*)retrieveFromUserDefaults:(NSString*)key withPlist:(NSString *)plist
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

	NSString *val = nil;
    
	if (standardUserDefaults)
		val = [standardUserDefaults objectForKey:key];
    
	if (val == nil)
    {
		//Get the bundle path
		NSString *bPath = [[NSBundle mainBundle] bundlePath];
		NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *plistFile = [settingsPath stringByAppendingPathComponent:plist];
        
		//Get the Preferences Array from the dictionary
		NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
		NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
        
		//Loop through the array
		NSDictionary *item;
		for(item in preferencesArray)
		{
			//Get the key of the item.
			NSString *keyValue = [item objectForKey:@"Key"];
            

			//Get the default value specified in the plist file.
			id defaultValue = [item objectForKey:@"DefaultValue"];

//            NSLog(@"user defaults may not have been loaded from Settings.bundle ... %@", defaultValue);
            
			if (keyValue && defaultValue) {
				[standardUserDefaults setObject:defaultValue forKey:keyValue];
				if ([keyValue compare:key] == NSOrderedSame)
					val = defaultValue;
			}
		}
		[standardUserDefaults synchronize];
	}
	return val;
}

#pragma mark - iConsole delegate methods

- (void)handleEmail:(NSString *)contents
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"My Pixate Playground log..."];
        [mailer setToRecipients:@[[iConsole sharedConsole].logSubmissionEmail]];
        NSString *emailBody = [NSString stringWithFormat:@"Additional comments:\n\n\n\n------------------LOG------------------\n\n%@", contents];
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Your device doesn't seem to be configured for email."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}


- (void)handleConsoleCommand:(NSString *)command
{
	if ([command isEqualToString:@"version"])
	{
		[iConsole info:@"%@ version %@ build %@",
         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],
         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	}
	else
	{
		[iConsole error:@"unrecognised command, try 'version' instead"];
	}
}

@end
