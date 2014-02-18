//
//  PXShapeViewController.m
//  Shapes
//
//  Created by Kevin Lindsey on 5/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShapeViewController.h"
#import <PixateFreestyle/PXGraphics.h>
#import <PixateFreestyle/PixateFreestyle.h>

@implementation PXShapeViewController
{
    CGFloat startingRotation;
    CGFloat startingScale;
    NSArray *images;
    NSUInteger imageIndex;
}

- (void)loadView
{
    // turn on logging to console
    PixateFreestyle.configuration.parseErrorDestination = PXParseErrorDestinationConsole;

    // create view
    PXShapeView *view = [[PXShapeView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // setup gestures
    [self addGestures:view];

    // set background color
    view.backgroundColor = [UIColor whiteColor];

    // setup image list
    images = [NSArray arrayWithObjects: @"target", @"logos", @"strawberries", @"pixate", nil];

    self.view = view;

    [self loadCurrent];
}

- (void) loadCurrent
{
    PXShapeView *view = (PXShapeView *) self.view;

    // load some vector content
    view.resourcePath = [images objectAtIndex:imageIndex];
}

- (void)addGestures:(PXShapeView *)view
{
    // single-tap
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapRecognizer.delegate = self;
    singleTapRecognizer.numberOfTapsRequired = 1;
    //[singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [view addGestureRecognizer:singleTapRecognizer];

    // swipe left
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    swipeLeftRecognizer.delegate = self;
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftRecognizer.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:swipeLeftRecognizer];

    // swipe right
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    swipeRightRecognizer.delegate = self;
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightRecognizer.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:swipeRightRecognizer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    // walk view and convert to "outline mode"
    PXShapeView *shapeView = (PXShapeView *) self.view;

    NSMutableArray *items = [NSMutableArray array];
    [items addObject:shapeView.document.shape];

    PXNonScalingStroke *stroke = [[PXNonScalingStroke alloc] init];
    stroke.color = [PXSolidPaint paintWithColor:[UIColor blackColor]];
    stroke.width = 1.0;

    while (items.count > 0)
    {
        // dequeue item
        id item = [items objectAtIndex:0];
        [items removeObjectAtIndex:0];

        if ([item conformsToProtocol:@protocol(PXPaintable)])
        {
            id<PXPaintable> paintable = item;

            paintable.fill = nil;
            paintable.stroke = stroke;
        }

        if ([item isKindOfClass:[PXShapeGroup class]])
        {
            PXShapeGroup *group = item;

            for (int i = 0; i < group.shapeCount; i++)
            {
                [items addObject:[group shapeAtIndex:i]];
            }
        }
    }

    [shapeView setNeedsDisplay];
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (imageIndex < images.count - 1)
        {
            imageIndex++;
        }
        else
        {
            imageIndex = 0;
        }

        [self transitionToShapeWithAnimationOptions:UIViewAnimationOptionTransitionCurlUp];
    }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (0 < imageIndex)
        {
            imageIndex--;
        }
        else
        {
            imageIndex = images.count - 1;
        }

        [self transitionToShapeWithAnimationOptions:UIViewAnimationOptionTransitionCurlDown];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [(PXShapeView *)self.view applyBoundsToScene];
}

- (void)transitionToShapeWithAnimationOptions:(UIViewAnimationOptions)transitionType
{
    [UIView transitionWithView:self.view
                      duration:0.8
                       options:transitionType
                    animations:^{
                        [self loadCurrent];
                        [self.view setNeedsDisplay];
                    }
                    completion:NULL];
}
@end
