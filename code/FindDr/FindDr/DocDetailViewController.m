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
#import "Clinic.h"
#import "Schedule.h"
#import "Ranking.h"

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
@property BOOL editable;

@end

@implementation DocDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.currentDoctor.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.docPhoto.image = [UIImage imageWithData:data];
    }];
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
                NSRange range = [specsLabel rangeOfString:@" | " options:NSBackwardsSearch];
                NSRange createRange = NSMakeRange(0 , range.location);
                self.docClinicSpecs.text = [specsLabel substringWithRange:createRange];
            }
            else
            {
                self.docClinicSpecs.text = @"Without specialities";
            }
        }];
    }];
    [Ranking countReviews:self.currentDoctor pat:self.currentPatient result:^(NSNumber *reviews) {
        self.rateView.notSelectedImage = [UIImage imageNamed:@"kermit_empty.png"];
        self.rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
        self.rateView.fullSelectedImage = [UIImage imageNamed:@"kermit_full.png"];
        if (reviews.intValue > 0) {
            [self loadRanking];
            self.rateView.editable = NO;
            self.editable = NO;
        }
        else
        {
            self.rateView.rating = 0;
            self.rateView.editable =YES;
            self.editable = YES;
        }
        self.rateView.maxRating = 5;
        self.rateView.delegate = self;
    }];
    [self loadComments];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    else if (alertView.tag == 2) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == 3) {
        //Stay on page...
    } else {
        NSLog(@"Tag not recognized.");
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
        
        [Schedule getScheduleByClinic:self.currentClinic sched:^(Schedule *schedule) {
            if (![DValidator validateTimeSchedule:edDate sched:schedule]) {
                NSString *message = @"There is no availability on the doctor's schedule.";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:message delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
                [alert setTag:3];
                [alert show];
            }
            else
            {
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
                        Appointment *appointment = [Appointment object];
                        appointment.description = desc;
                        appointment.doctor = self.currentDoctor;
                        appointment.patient = self.currentPatient;
                        appointment.clinic = self.currentClinic;
                        appointment.status =  @"pending";
                        appointment.date = edDate;
                        [Appointment save:appointment result:^(BOOL error) {
                            if(!error)
                            {
                                NSString *message = @"The appointment has been requested.";
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:message delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
                                [alert setTag:2];
                                [alert show];
                            }
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

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {
    if(self.editable) {
        Ranking *ranking = [Ranking object];
        ranking.doctor = self.currentDoctor;
        ranking.patient = self.currentPatient;
        ranking.ranking = [NSNumber numberWithFloat:rating];
        [ranking saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self loadRanking];
            self.rateView.editable = NO;
            self.editable = NO;
        }];
    }
}

-(void) loadRanking {
    Ranking *myRanking = [[Ranking alloc] init];
    [myRanking getRankingByDoc:self.currentDoctor result:^(Ranking *ranking) {
        self.statusLabel.text = [NSString stringWithFormat:@"%@ out of 5 stars | %@ reviews", ranking.average, ranking.reviews];
        self.rateView.rating = [ranking.average floatValue];
    }];
}

@end