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
@property (strong, nonatomic) IBOutlet UIButton *postponeButton;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;
@property NSDate *postponedDate;
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
        self.postponeButton.hidden = YES;
        self.acceptButton.hidden = YES;
    }
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
        if (buttonIndex ==  1)
        {
            [Schedule getScheduleByClinic:self.appointment.clinic sched:^(Schedule *schedule) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEEE"];
                NSString *day = [dateFormatter stringFromDate:self.postponedDate];
                [dateFormatter setDateFormat:@"HH"];
                int hour = [[dateFormatter stringFromDate:self.postponedDate] intValue] - 1;
                NSNumber *isAvailable = [[self getDayTime:schedule day:day] objectAtIndex:hour];
                if ([isAvailable boolValue] == YES)
                {
                    NSLog(@"That time is available.");
                    //self.appointment.status = @"scheduled";
                    //[self.appointment save];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    NSLog(@"That time is not available.");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Busy time" message:@"Select different time" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
                    [alert setTag:3];
                    [alert show];
                }
            }];
        }
    }
    else if (alertView.tag == 2)
    {
        if (buttonIndex ==  1)
        {
            self.appointment.status = @"scheduled";
            [self.appointment save];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag == 3 || alertView.tag == 4)
    {
        [self postpone:self];
    }
}

- (IBAction)postpone:(id)sender {
    [ActionSheetDatePicker
        showPickerWithTitle:@"Select:"
        datePickerMode:UIDatePickerModeDateAndTime
        selectedDate:[NSDate date]
        doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {

            NSDate *currentDate = [NSDate date];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:-1];
            NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
            NSLog(@"\ncurrentDate: %@\nseven days ago: %@", currentDate, yesterday);
    
            if ([yesterday timeIntervalSince1970] > [selectedDate timeIntervalSince1970]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Selected date should be in future" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
                [alert setTag:4];
                [alert show];
            }
            else
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd-MM-yyyy 'at' HH:mm a"];
                NSString *strDate = [dateFormatter stringFromDate:selectedDate];
                NSString *msg = [NSString stringWithFormat:@"%@ %@", @"The appointment will be scheduled the ",strDate];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept", nil];
                [alert setTag:1];
                [alert show];
                self.postponedDate = selectedDate;
            }
        }
        cancelBlock:^(ActionSheetDatePicker *picker) {
            NSLog(@"Block Date Picker Canceled");
        }origin:self.view];
}

- (NSArray *) getDayTime:(Schedule *)schedule day : (NSString *)day {
    NSArray *time = [NSArray array];
    if ([@"Monday" isEqualToString:day]) {
        time = schedule.monday;
    } else if ([@"Tuesday" isEqualToString:day]) {
        time = schedule.tuesday;
    } else if ([@"Wednesday" isEqualToString:day]) {
        time = schedule.wednesday;
    } else if ([@"Thursday" isEqualToString:day]) {
        time = schedule.thursday;
    } else if ([@"Friday" isEqualToString:day]) {
        time = schedule.friday;
    } else if ([@"Saturday" isEqualToString:day]) {
        time = schedule.saturday;
    } else if ([@"Sunday" isEqualToString:day]) {
        time = schedule.sunday;
    } else {
        NSLog(@"Day is not available: %@", day);
    }
    return time;
}

@end
