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
#import "ActionSheetDatePicker.h"

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
@property (strong, nonatomic) IBOutlet UIButton *cancelAppButton;
@property (strong, nonatomic) IBOutlet UIButton *makeAppointmentButton;

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
    if ([self.appointment.status isEqualToString:@"declined"]) {
        self.cancelAppButton.hidden = YES;
        self.makeAppointmentButton.hidden = NO;
    }
    else {
        self.makeAppointmentButton.hidden = YES;
        self.cancelAppButton.hidden = NO;
    }
}

- (void) coordinate {
    
    CLLocationDegrees lat = [self.appointment.clinic.latitude doubleValue];
    CLLocationDegrees lon = [self.appointment.clinic.longitude doubleValue];
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
    coord.latitude = [self.appointment.clinic.latitude doubleValue];
    coord.longitude = [self.appointment.clinic.longitude doubleValue];
    NSString *title = self.appointment.clinic.name;
    NSString *subtitle = [self.appointment.clinic getFullAddress];
    CustomAnnotation *clinicAnnotation = [[CustomAnnotation alloc] initWithTitle:title Location:coord subtitle:subtitle];
    [self.mapView addAnnotation:clinicAnnotation];
}

- (IBAction)cancelAppointment:(id)sender {
    NSString *msg = @"Are you sure you want to cancel this appointment?";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept", nil];
    [alert setTag:3];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            NSLog(@"Validate date agains doctor appointments & schedule");
        }
    }
    else if (alertView.tag == 2) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == 3) {
        if (buttonIndex == 1)
        {
            [self.appointment updateToStatus:@"canceled" result:^(NSNumber *result) {
                NSLog(@"Appointment canceled");
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }
    else {
        NSLog(@"Tag not recognized.");
    }
}

//Create appointment

- (IBAction)makeAppointment:(id)sender {
    ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc]initWithTitle:@"Select:" datePickerMode:UIDatePickerModeDateAndTime selectedDate:[NSDate date] target:self action:@selector(action:forEvent:) origin:sender];
    [picker setCancelButton:[[UIBarButtonItem alloc] initWithTitle:@"Not sure" style:UIBarButtonItemStylePlain target:self action:@selector(action:cancelEvent:)]];
    [picker showActionSheetPicker];
}

- (void) action: (id) sender forEvent: (UIEvent *) event {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-1];
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    
    if ([yesterday timeIntervalSince1970] > [sender timeIntervalSince1970]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Selected date should be in future" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
        [alert setTag:1];
        [alert show];
    }
    else
    {
        
        NSDate *edDate = [DValidator roundDateMinuteToZero:sender];
        
        [self.appointment.doctor getAppointmentsByStatusAndDate:edDate status:@"scheduled" apps:^(NSArray *appointments) {
            if (appointments.count > 0) {
                [self.appointment.doctor getAppointmentsByStatus:@"scheduled" apps:^(NSArray *appointments) {
                    if (appointments.count > 0) {
                        Appointment *latestApp = [appointments objectAtIndex:0];
                        NSTimeInterval oneHour = 1 * 60 * 60;
                        NSDate *oneHourAhead = [latestApp.date dateByAddingTimeInterval:oneHour];
                        NSString *message  = [NSString stringWithFormat:@"There is no availability at this time. Please book after: %@",[DValidator dateToString:oneHourAhead]];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:message delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
                        [alert setTag:1];
                        [alert show];
                    }
                }];
            }
            else
            {
                NSString *desc = [NSString stringWithFormat:@"Booking at: %@ for doctor %@, patient: %@",[DValidator dateToString:sender], self.appointment.doctor.name, self.appointment.patient.name];
                NSLog(@"%@",desc);
                Appointment *appointment = [Appointment object];
                appointment.description = desc;
                appointment.doctor = self.appointment.doctor;
                appointment.patient = self.appointment.patient;
                appointment.clinic = self.appointment.clinic;
                appointment.status =  @"pending";
                appointment.date = edDate;
                [Appointment save:appointment result:^(BOOL error) {
                    if(!error)
                    {
                        self.appointment.status = @"deleted";
                        [self.appointment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSString *message = @"The new appointment has been requested.";
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:message delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
                            [alert setTag:2];
                            [alert show];
                        }];
                    }
                }];
            }
        }];
        
    }
    
}

- (void) action: (id) sender cancelEvent: (UIEvent *) event {
    NSLog(@"Canceled");
}

@end
