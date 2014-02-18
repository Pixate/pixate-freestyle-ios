//
//  MapViewPreview.m
//  Playground
//
//  Created by Paul Colton on 11/29/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//
//  Special thanks for the "Introduction to MapKit on iOS Tutorial"
//  tutorial at http://www.raywenderlich.com/21365/introduction-to-mapkit-in-ios-6-tutorial

#import "MapViewPreviewController.h"
#import "MapViewPreviewLocation.h"
#import <PixateFreestyle/PixateFreestyle.h>

@interface MapViewPreviewController ()
@end

@implementation MapViewPreviewController
{
    CLLocationCoordinate2D appleLocation_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appleLocation_.latitude = 37.33201682059967;
        appleLocation_.longitude= -122.02986717224121;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(appleLocation_, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapView.styleId = @"myMap";

    MapViewPreviewLocation *annotation = [[MapViewPreviewLocation alloc] initWithName:@"Apple"
                                                                              address:@"1 Infinite Loop"
                                                                           coordinate:appleLocation_] ;
    [_mapView addAnnotation:annotation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

#pragma mark - MapViewDelegate methods

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"MyLocation";
    
    if ([annotation isKindOfClass:[MapViewPreviewLocation class]])
    {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.styleClass = @"myAnnotations";
        }
        else
        {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

@end
