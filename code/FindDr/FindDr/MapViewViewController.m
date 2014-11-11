//
//  MapViewViewController.m
//  FindDr
//
//  Created by Eduardo Alvarado Díaz on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "MapViewViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AZDraggableAnnotationView.h"


@interface MapViewViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, AZDraggableAnnotationViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation *annotation;
@property CLLocationManager *myLocationManager;
@property CLPlacemark *currentLocation;

@end

@implementation MapViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myLocationManager = [[CLLocationManager alloc] init];
    [self.myLocationManager requestWhenInUseAuthorization];
    self.myLocationManager.delegate = self;

    [self.myLocationManager startUpdatingLocation];

    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:singleTapRecognizer];

    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] init];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;

    // In order to pass double-taps to the underlying MKMapView the delegate
    // for this recognizer (self) needs to return YES from
    // gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:
    doubleTapRecognizer.delegate = self;
    [self.mapView addGestureRecognizer:doubleTapRecognizer];

    // This delays the single-tap recognizer slightly and ensures that it
    // will _not_ fire if there is a double-tap
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location Manager
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    for (CLLocation *location in locations) {
        if(location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000){
            [self reverseGeocode:location];
            NSLog(@"location: %f,%f",location.coordinate.latitude,location.coordinate.longitude);
            [self.myLocationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void)reverseGeocode:(CLLocation *)location{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        self.currentLocation = placemarks.firstObject;
        [self moveAnnotationToCoordinate:self.currentLocation.location.coordinate];
        [self zoomIn];
    }];
}

- (void)searchAddress:(CLLocation *)location{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        self.currentLocation = placemarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"%@, %@, %@ at %@, CP %@",
                             self.currentLocation.subThoroughfare,
                             self.currentLocation.thoroughfare,
                             self.currentLocation.subLocality,
                             self.currentLocation.locality,
                             self.currentLocation.postalCode];
        NSLog(@"Found you at: %@",address);
    }];
}

#pragma mark - Map view
- (void)zoomIn{
    CLLocation *location = self.currentLocation.location;

    CLLocationCoordinate2D zoom;
    zoom.latitude = location.coordinate.latitude;
    zoom.longitude = location.coordinate.longitude;

    MKCoordinateSpan span;
    span.latitudeDelta = .005;
    span.longitudeDelta = .005;

    MKCoordinateRegion region;
    region.center = zoom;
    region.span = span;
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"DraggableAnnotationView"];

    if (!annotationView) {
        annotationView = [[AZDraggableAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"DraggableAnnotationView"];
    }

    ((AZDraggableAnnotationView *)annotationView).delegate = self;
    ((AZDraggableAnnotationView *)annotationView).mapView = mapView;

    return annotationView;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Failed to Get Your Location"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
    NSLog(@"Error: %@",error);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)moveAnnotationToCoordinate:(CLLocationCoordinate2D)coordinate{
    if (self.annotation) {
        [UIView beginAnimations:[NSString stringWithFormat:@"slideannotation%@", self.annotation] context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.2];

        self.annotation.coordinate = coordinate;

        NSLog(@"Moved annotation to %f,%f", coordinate.latitude, coordinate.longitude);
        CLLocation *newlocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                             longitude:coordinate.longitude];
        [self searchAddress:newlocation];
        [UIView commitAnimations];
    } else {
        self.annotation = [[MKPointAnnotation alloc] init];
        self.annotation.coordinate = self.currentLocation.location.coordinate;

        [self.mapView addAnnotation:self.annotation];
    }
}

#pragma mark UIGestureRecognizerDelegate methods

/**
 Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    // Returning YES ensures that double-tap gestures propogate to the MKMapView
    return YES;
}

#pragma mark UIGestureRecognizer handlers

- (void)handleSingleTapGesture:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded){
        return;
    }

    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    [self moveAnnotationToCoordinate:[self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView]];
}

#pragma mark Draggable-AnnotationView

- (void)movedAnnotation:(MKPointAnnotation *)anno{
    NSLog(@"Dragged annotation to %f,%f", anno.coordinate.latitude, anno.coordinate.longitude);
    CLLocation *newlocation = [[CLLocation alloc] initWithLatitude:anno.coordinate.latitude
                                                         longitude:anno.coordinate.longitude];
    [self searchAddress:newlocation];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
