//
//  ViewController.m
//  ListFonts
//
//  Created by Kevin Lindsey on 1/13/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PXFontEntry.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    NSMutableString *results = [[NSMutableString alloc] init];
    
    
    [[UIFont familyNames] enumerateObjectsUsingBlock:^(NSString *familyName, NSUInteger idx, BOOL *stop) {
        [results appendString:@"FAMILY ** "];
        [results appendString:familyName];
        [results appendString:@" **\n"];
        NSLog(@"%@", familyName);
        [[UIFont fontNamesForFamilyName:familyName] enumerateObjectsUsingBlock:^(NSString *fontName, NSUInteger idx, BOOL *stop) {
            PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:familyName fontName:fontName];
            [results appendString:entry.description];
            [results appendString:@"\n\n"];
            NSLog(@"  %@ = %@", fontName, entry);
        }];
    }];
    
    self.textview.text = results;

//    NSString *fontFamily = @"Whitney Condensed";
//    NSString *fontName = @"WhitneyCondensed-Bold";
//    PXFontEntry *entry = [[PXFontEntry alloc] initWithFontFamily:fontFamily fontName:fontName];
//
//    NSLog(@"%@", entry);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
