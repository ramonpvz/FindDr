//
//  DrInboxViewController.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/11/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "DrInboxViewController.h"
#import "Doctor.h"
#import "Appointment.h"
#import "AppGenInfoViewController.h"
#import "DValidator.h"
#import "Login.h"

@interface DrInboxViewController () <UITableViewDataSource , UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UISegmentedControl *drSegmentCtrl;
@property (strong, nonatomic) IBOutlet UITableView *drTableView;
@property NSArray *appRequests;
@property Doctor *currentDoctor;
@property BOOL _loaded;
@property Login *login;
@end

@implementation DrInboxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.login = [[Login alloc] init];
    [Doctor getDoctorByUser:[PFUser currentUser] doc:^(Doctor *doctor) {
        self.currentDoctor = doctor;
        [self loadAppointmentsByStatus:@"scheduled"];
    }];
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                     initWithImage:[UIImage imageNamed:@"Logout-32.png"]
                                     style:UIBarButtonItemStylePlain
                                     target:self action:@selector(doLogout:)];
    self.navigationItem.rightBarButtonItem = logoutButton;
    self.navigationItem.hidesBackButton = YES;
}

- (void)doLogout:(id)sender {
    //[self.login logOut];
    //[self.navigationController popViewControllerAnimated:YES];
    [self performSegueWithIdentifier:@"logout" sender:self];
}

- (IBAction)getAppointments:(id)sender
{
    if (self.drSegmentCtrl.selectedSegmentIndex == 0)
    {
        [self loadAppointmentsByStatus:@"pending"];
    }
    else
    {
        [self loadAppointmentsByStatus:@"scheduled"];
    }
}

- (void) loadAppointmentsByStatus: (NSString *) status {
    [self.currentDoctor getAppointmentsByStatus:status apps:^(NSArray *appointments) {
        self.appRequests = appointments;
        if ([status isEqualToString:@"pending"]) {
            self.drSegmentCtrl.selectedSegmentIndex = 0;
        }
        else
        {
            self.drSegmentCtrl.selectedSegmentIndex = 1;
        }
        [self.drTableView reloadData];
    }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"appInfo"])
    {
        AppGenInfoViewController *appGenInfoVC = segue.destinationViewController;
        appGenInfoVC.appointment = [self.appRequests objectAtIndex:self.drTableView.indexPathForSelectedRow.row];
        self._loaded = NO;
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self._loaded) {
        if (self.drSegmentCtrl.selectedSegmentIndex == 0) {
            [self loadAppointmentsByStatus:@"pending"];
        }
        else
        {
            [self loadAppointmentsByStatus:@"scheduled"];
        }
        self._loaded = YES;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appRequests.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Appointment *app = [self.appRequests objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", app.patient.name, app.patient.lastName];
    cell.detailTextLabel.text = [DValidator dateToString:app.date];
    return cell;
}

@end
