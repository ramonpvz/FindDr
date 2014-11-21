//
//  UserApptDetailViewController.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/18/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "UserApptDetailViewController.h"
#import "DValidator.h"
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"
#import <QuartzCore/QuartzCore.h>

@interface UserApptDetailViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *docImg;
@property (strong, nonatomic) IBOutlet UILabel *docTitle;
@property (strong, nonatomic) IBOutlet UILabel *docName;
@property (strong, nonatomic) IBOutlet UILabel *docClinic;
@property (strong, nonatomic) IBOutlet UILabel *docClinicSpecs;
@property Doctor *doc;
@property (strong, nonatomic) IBOutlet UILabel *appDate;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation UserApptDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.appointment.doctor loadImage:^(UIImage *image) {
        self.docImg.image = image;
    }];
    self.docTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    self.docTitle.text = self.appointment.doctor.title;
    self.docName.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    self.docName.text = [self.appointment.doctor getFullName];
    self.appDate.text = [DValidator dateToLabel:self.appointment.date];
    self.docClinic.text = self.appointment.clinic.name;
    [Speciality lisSpecialities:^(NSArray *specialities) {
        NSMutableString *specsLabel = [NSMutableString string];
        [self.appointment.clinic getSpecialities:^(NSArray *_specialities) {
            for (Speciality *clinicSpec in _specialities) {
                for (Speciality *spec in specialities) {
                    if ([spec.objectId isEqualToString:clinicSpec.objectId]) {
                        [specsLabel appendString:spec.name];
                        [specsLabel appendString:@" | "];
                    }
                }
            }
            self.docClinicSpecs.text = specsLabel;
        }];
    }];
    [self coordinate];
    self.mapView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.mapView.layer.borderWidth = 1.0;
    self.addressLabel.backgroundColor = [UIColor colorWithRed:0.93 green:0.80 blue:0.80 alpha:1.0];
    self.addressLabel.text = [self.appointment.clinic getFullAddress];
}

- (void) coordinate {
    
    CLLocationDegrees lat = 19.412032;
    CLLocationDegrees lon = -99.176066;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    
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
    [self pingPoint];
}

- (void) pingPoint {
    CLLocationCoordinate2D coord;
    coord.latitude = 19.412032;
    coord.longitude = -99.176066;
    NSString *title = self.appointment.clinic.name;
    NSString *subtitle = [self.appointment.clinic getFullAddress];
    CustomAnnotation *clinicAnnotation = [[CustomAnnotation alloc] initWithTitle:title Location:coord subtitle:subtitle];
    [self.mapView addAnnotation:clinicAnnotation];
}

- (IBAction)cancelAppointment:(id)sender {
    NSString *msg = @"Are you sure you want to cancel this appointment?";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept", nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        [self.appointment updateToStatus:@"canceled" result:^(NSNumber *result) {
            NSLog(@"Canceling appointment...");
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

@end
