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
#import "Comment.h"

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
@property (strong, nonatomic) IBOutlet UITableView *commentsTable;
@property (strong, nonatomic) IBOutlet UITextField *commentText;

@end

@implementation DocDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.docPhoto.image = [UIImage imageWithData:[self.currentDoctor.photo getData]];
    self.commentIcon.image = [UIImage imageNamed:@"comment_add-128.png"];
    self.createAppIcon.image = [UIImage imageNamed:@"schedule_appointment_icon.png"];
    self.docTitle.text = self.currentDoctor.title;
    self.docFullName.text = [self.currentDoctor getFullName];
    self.docClinicName.text = self.currentClinic.name;

    [Speciality lisSpecialities:^(NSArray *specialities) {
        NSMutableString *specsLabel = [NSMutableString string];
        [self.currentClinic getSpecialities:^(NSArray *_specialities) {
            if (_specialities.count > 0) {
                for (Speciality *clinicSpec in _specialities) {
                    for (Speciality *spec in specialities) {
                        if ([spec.objectId isEqualToString:clinicSpec.objectId]) {
                            [specsLabel appendString:spec.name];
                            [specsLabel appendString:@" | "];
                        }
                    }
                }
                self.docClinicSpecs.text = specsLabel;
            }
            else
            {
                self.docClinicSpecs.text = @"Without specialities";
            }
        }];
    }];

    [self loadComments];

}

-(void)loadComments{
    [Comment getCommentsByDoctor:self.currentDoctor doc:^(NSArray *comments) {
        self.comments = comments;
        [self.commentsTable reloadData];
    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];

    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    cell.textLabel.text = comment.patient.name;
    cell.detailTextLabel.text = [comment objectForKey:@"description"];
    cell.detailTextLabel.numberOfLines = 2;

    return cell;
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


- (IBAction)makeComment:(UITapGestureRecognizer *)sender {
    if (![self.commentText.text isEqualToString:@""]) {
        Comment *comment = [Comment object];
        comment.description = self.commentText.text;
        comment.doctor = self.currentDoctor;
        comment.patient = self.currentPatient;
        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"comment saved");
            [self loadComments];
        }];
        self.commentText.text = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.commentText) {
        [textField resignFirstResponder];
        [self makeComment:nil];
        return NO;
    }
    return YES;
}

@end