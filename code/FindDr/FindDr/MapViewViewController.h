//
//  MapViewViewController.h
//  FindDr
//
//  Created by Eduardo Alvarado Díaz on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewViewController : UIViewController

@property (strong, nonatomic) NSString *subThoroughfare;
@property (strong, nonatomic) NSString *thoroughfare;
@property (strong, nonatomic) NSString *subLocality;
@property (strong, nonatomic) NSString *locality;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) CLPlacemark *currentLocation;
@property (strong, nonatomic) CLLocation *pinMap;

- (void)reverseGeocode:(CLLocation *)location;
- (void)searchAddress:(CLLocation *)location;
@end
