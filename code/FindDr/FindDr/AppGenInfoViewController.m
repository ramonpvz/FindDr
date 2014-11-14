//
//  AppGenInfoViewController.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/12/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "AppGenInfoViewController.h"
#import "DValidator.h"
#import "DrInboxViewController.h"
#import "ActionSheetDatePicker.h"
#import "Schedule.h"

@interface AppGenInfoViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *photo;
@property (strong, nonatomic) IBOutlet UILabel *patientName;
@property (strong, nonatomic) IBOutlet UILabel *patientAge;
@property (strong, nonatomic) IBOutlet UILabel *patientDateApp;
@property (strong, nonatomic) IBOutlet UITextView *patientDescription;
@property (strong, nonatomic) IBOutlet UIButton *declineButton;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;
@property NSDate *acceptedDate;
@end

@implementation AppGenInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.appointment.patient loadImage:^(UIImage *image) {
        self.photo.image = image;
    }];
    self.patientName.text = [self.appointment.patient getFullName];
    self.patientDateApp.text = [DValidator dateToString:self.appointment.date];
    self.patientDescription.text = [self.appointment objectForKey:@"description"];
    if ([self.appointment.status isEqualToString:@"scheduled"]) {
        self.declineButton.hidden = YES;
        self.acceptButton.hidden = YES;
    }
}
- (IBAction)decline:(id)sender {
    NSString *msg = @"The schedule will be declined";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept", nil];
    [alert setTag:1];
    [alert show];
}

- (IBAction)accept:(id)sender {
    NSString *date = [DValidator dateToString:self.appointment.date];
    NSString *msg = [NSString stringWithFormat:@"%@ %@",@"The appointment will be scheduled the ",date];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept", nil];
    [alert setTag:2];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            [self.appointment updateToStatus:@"declined"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag == 2)
    {
        if (buttonIndex ==  1)
        {
            [self.appointment updateToStatus:@"scheduled"];
            [self.appointment.doctor getAppointmentsByStatusAndDate:self.appointment.date status:@"pending" apps:^(NSArray *appointments){
                NSLog(@"Notify to these appointments: %@", appointments);
            }];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        NSLog(@"Tag is not defined");
    }
}

@end
