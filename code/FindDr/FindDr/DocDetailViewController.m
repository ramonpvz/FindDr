//
//  DocDetailViewController.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/19/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "DocDetailViewController.h"
#import "Doctor.h"
#import "CreateApptViewController.h"
#import "ActionSheetDatePicker.h"
#import "DValidator.h"
#import "Appointment.h"

@interface DocDetailViewController () <UITableViewDataSource , UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *docPhoto;
@property (strong, nonatomic) IBOutlet UILabel *docTitle;
@property (strong, nonatomic) IBOutlet UILabel *docFullName;
@property (strong, nonatomic) IBOutlet UILabel *docClinicName;
@property (strong, nonatomic) IBOutlet UILabel *docClinicSpecs;

@property (strong, nonatomic) IBOutlet UIImageView *commentIcon;
@property (strong, nonatomic) IBOutlet UIImageView *createAppIcon;
@property NSDate *appointmentDate;
@property NSArray *comments;

@end

@implementation DocDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.docPhoto.image = [UIImage imageNamed:@"juan.jpg"];
    self.commentIcon.image = [UIImage imageNamed:@"comment_add-128.png"];
    self.createAppIcon.image = [UIImage imageNamed:@"schedule_appointment_icon.png"];
    //self.comments = [self.currentDoctor load]
    
    [Patient getPatientByUser:[PFUser currentUser] pat:^(Patient *patient) {
        self.currentPatient = patient;
    }];
    
    PFQuery *docQuery = [Doctor query];
    [docQuery whereKey:@"objectId" equalTo:@"0xyQXiANdm"];
    [docQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.currentDoctor = [objects objectAtIndex:0];
        Clinic *clinic = [[Clinic alloc] init];
        clinic.name = @"Happy Ending Clinic...";
        clinic.street = @"Test street";
        clinic.latitude = @"1412.244019";
        clinic.longitude = @"1412.239990";
        self.currentClinic = clinic;
        [self.currentDoctor addClinic:clinic];
    }];

}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (IBAction)makeAppointment:(id)sender {
    ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc]initWithTitle:@"Select:" datePickerMode:UIDatePickerModeDateAndTime selectedDate:[NSDate date] target:self action:@selector(action:forEvent:) origin:sender];
    [picker setCancelButton:[[UIBarButtonItem alloc] initWithTitle:@"Not sure" style:UIBarButtonItemStylePlain target:self action:@selector(action:cancelEvent:)]];
    [picker showActionSheetPicker];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            NSLog(@"Validate date agains doctor appointments & schedule");
        }
    }
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
        
        [self.currentDoctor getAppointmentsByStatusAndDate:edDate status:@"scheduled" apps:^(NSArray *appointments) {
            if (appointments.count > 0) {
                [self.currentDoctor getAppointmentsByStatus:@"scheduled" apps:^(NSArray *appointments) {
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
                NSString *desc = [NSString stringWithFormat:@"Booking at: %@ for doctor %@, patient: %@",[DValidator dateToString:sender], self.currentDoctor.name, self.currentPatient.name];
                NSLog(@"%@",desc);
                Appointment *appointment = [Appointment object];
                appointment.description = desc;
                appointment.doctor = self.currentDoctor;
                appointment.patient = self.currentPatient;
                appointment.clinic = self.currentClinic;
                appointment.status =  @"pending";
                appointment.date = edDate;
                [Appointment save:appointment];
            }
        }];

    }

}

- (void) action: (id) sender cancelEvent: (UIEvent *) event {
    NSLog(@"Canceled");
}

@end