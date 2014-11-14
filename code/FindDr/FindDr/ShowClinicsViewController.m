//
//  ShowClinicsViewController.m
//  FindDr
//
//  Created by Eduardo Alvarado Díaz on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "ShowClinicsViewController.h"
#import "Clinic.h"
#import "Doctor.h"
#import "ClinicViewController.h"

@interface ShowClinicsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *clinicsTable;
@property (strong, nonatomic) NSMutableArray *clinics;
@property (strong, nonatomic) Doctor *currentDoctor;
@property (strong, nonatomic) Clinic *clinicSelected;

@end

@implementation ShowClinicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Doctor getDoctorByUser:[PFUser currentUser] doc:^(Doctor *doctor) {
        self.currentDoctor = doctor;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table Specialties

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.clinics.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellClinic" forIndexPath:indexPath];

    Clinic *clinic = self.clinics[indexPath.row];
    cell.textLabel.text = clinic.name;
    cell.detailTextLabel.text = [clinic objectForKey:@"description"];

    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row (speciality)
        [self.clinics removeObjectAtIndex:indexPath.row];

        // Animate the deletion
        [self.clinicsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Actions
- (IBAction)homeButtonTapped:(UIBarButtonItem *)sender {
    if (self.clinics.count > 0) {  //the doctor has at least one clinic
        //save clinics
        [self.currentDoctor saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            for (Clinic *clinic in self.clinics){
                [self.currentDoctor addClinic:clinic];
            }

            [self performSegueWithIdentifier:@"goHome" sender:self];
        }];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please, add at least one clinic." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }
}


- (IBAction)addClinicButtonTapped:(UIBarButtonItem *)sender {
    Clinic *newClinic = [Clinic object];
    [newClinic saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.clinicSelected = newClinic;
        [self.clinics addObject:newClinic];
        [self.clinicsTable reloadData];
        [self performSegueWithIdentifier:@"addClinic" sender:self];
    }];

}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //send clinic
    if ([[segue identifier] isEqualToString:@"addClinic"])
    {
        // Get reference to the destination view controller
        ClinicViewController *cvc = [segue destinationViewController];

        // Pass any objects to the view controller here, like...
        [cvc setCurrentClinic:self.clinicSelected];
    }
}


@end
