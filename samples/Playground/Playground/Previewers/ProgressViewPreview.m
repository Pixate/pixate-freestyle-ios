//
//  ProgressViewPreview.m
//  Playground
//
//  Created by Paul Colton on 11/14/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "ProgressViewPreview.h"
#import <PixateFreestyle/PixateFreestyle.h>

#define DEMO_WIDTH 500
#define DEMO_HEIGHT 335
#define ARC4RANDOM_MAX 0x100000000

@interface ProgressViewPreview ()
-(void)updateProgressBars;
@end

@implementation ProgressViewPreview
{
    UIProgressView *progressView1;
    UIProgressView *progressView2;
    UIProgressView *progressView3;
    NSTimer *timer;
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, DEMO_WIDTH, DEMO_HEIGHT)];
    
    if (self) {
    
        progressView1 = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView2 = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressView3 = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        
        // Define the class for both of these progress bars, so we can style them as a group
        progressView1.styleClass = progressView2.styleClass = progressView3.styleClass = @"myProgressBars";
        
        // Define the id for each individually, so we can do specific styling unique to each one
        progressView1.styleId = @"myProgress1";
        progressView2.styleId = @"myProgress2";
        progressView3.styleId = @"myProgress3";

        // Add the progress bars to the view
        [self addSubview:progressView1];
        [self addSubview:progressView2];
        [self addSubview:progressView3];
    }
    
    return self;
}

- (void) initializeCustomController
{
    // Stop any already running timers
    [timer invalidate];

    // Start the timer that randomly updates the sliders
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateProgressBars)
                                           userInfo:nil
                                            repeats:YES];
}

-(UIView *)previewView
{
    return self;
}

-(void)updateProgressBars
{
    double val = ((double)arc4random() / ARC4RANDOM_MAX);
    [progressView1 setProgress:val animated:YES];
    
    val = ((double)arc4random() / ARC4RANDOM_MAX);
    [progressView2 setProgress:val animated:YES];

    val = ((double)arc4random() / ARC4RANDOM_MAX);
    [progressView3 setProgress:val animated:YES];
}

-(void)dealloc
{
    [timer invalidate];
    progressView1 = nil;
    progressView2 = nil;
    progressView3 = nil;
}

@end
