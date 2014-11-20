//
//  UserApptsViewController.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/18/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "UserApptsViewController.h"
#import "Patient.h"
#import "Appointment.h"
#import "DValidator.h"
#import "UserApptDetailViewController.h"

@interface UserApptsViewController () <UITableViewDataSource, UITableViewDelegate>
@property NSArray *appointments;
@property Patient *currentPatient;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentCtrl;
@property BOOL _loaded;
@end

@implementation UserApptsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Patient getPatientByUser:[PFUser currentUser] pat:^(Patient *patient) {
        self.currentPatient = patient;
        [self loadAppointmentsByStatus:@"scheduled"];
    }];
}

- (IBAction)refreshAppts:(id)sender {
    if (self.segmentCtrl.selectedSegmentIndex == 0)
    {
        [self loadAppointmentsByStatus:@"pending"];
    }
    else
    {
        [self loadAppointmentsByStatus:@"scheduled"];
    }
}

- (void) loadAppointmentsByStatus: (NSString *) status {
    [self.currentPatient getAppointmentsByStatus:status apps:^(NSArray *appointments) {
        self.appointments = appointments;
        if ([status isEqualToString:@"pending"]) {
            self.segmentCtrl.selectedSegmentIndex = 0;
        }
        else
        {
            self.segmentCtrl.selectedSegmentIndex = 1;
        }
        [self.tableView reloadData];
    }];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self._loaded) {
        if (self.segmentCtrl.selectedSegmentIndex == 0) {
            [self loadAppointmentsByStatus:@"pending"];
        }
        else
        {
            [self loadAppointmentsByStatus:@"scheduled"];
        }
        self._loaded = YES;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"usrAppInfo"])
    {
        UserApptDetailViewController *usrApptDetailVC = segue.destinationViewController;
        usrApptDetailVC.appointment = [self.appointments objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        self._loaded = NO;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appointments.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Appointment *app = [self.appointments objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ApptCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", app.doctor.name, app.doctor.lastName];
    cell.detailTextLabel.text = [DValidator dateToString:app.date];
    return cell;
}

@end
