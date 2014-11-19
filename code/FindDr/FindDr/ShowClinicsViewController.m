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
#import "MBProgressHUD.h"

@interface ShowClinicsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *clinicsTable;
@property (strong, nonatomic) NSMutableArray *clinics;
@property (strong, nonatomic) Doctor *currentDoctor;
@property (strong, nonatomic) Clinic *clinicSelected;

@end

@implementation ShowClinicsViewController

- (void) loadData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Doctor getDoctorByUser:[PFUser currentUser] doc:^(Doctor *doctor) {
        self.currentDoctor = doctor;
        [self.currentDoctor getClinics:^(NSArray *clinics) {
            self.clinics = [[NSMutableArray alloc]initWithArray:clinics];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.clinicsTable reloadData];
        }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
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
    cell.imageView.image = [UIImage imageWithData:[clinic.photo getData]];
    cell.textLabel.text = clinic.name;

    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //delete relation form clinic to doctor
        self.clinicSelected = [self.clinics objectAtIndex:indexPath.row];
        [self.currentDoctor removeClinic:self.clinicSelected];
        [self.clinics removeObject:self.clinicSelected];
        // Animate the deletion
        [self.clinicsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.clinicSelected = [self.clinics objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showClinic" sender:self];
}

#pragma mark - Actions
- (IBAction)homeButtonTapped:(UIBarButtonItem *)sender {
    if (self.clinics.count > 0) {  //the doctor has at least one clinic
        [self performSegueWithIdentifier:@"goHome" sender:self];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please, add at least one clinic." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }
}

- (IBAction)addClinicButtonTapped:(UIBarButtonItem *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    Clinic *newClinic = [Clinic object];
    [newClinic setObject:@"Description here" forKey:@"description"];
    PFFile *image = [PFFile fileWithName:@"image.png"
                                    data:UIImageJPEGRepresentation([UIImage imageNamed:@"clinic.png"], 1.0f)];
    newClinic.photo = image;
    //create a clinic
    [newClinic saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.clinicSelected = newClinic;
        //save clinic to doctor
        [self.currentDoctor addClinic:newClinic];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self performSegueWithIdentifier:@"addClinic" sender:self];
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue method");
    if ([[segue identifier] isEqualToString:@"addClinic"]){
        //send new clinic
        ClinicViewController *cvc = [segue destinationViewController];
        NSLog(@"setting new currentClinic");
        [cvc setCurrentClinic:self.clinicSelected];
        cvc.navigationItem.hidesBackButton = YES;
    }else if ([[segue identifier] isEqualToString:@"showClinic"]){
        //send clinic selected
        ClinicViewController *cvc = [segue destinationViewController];
        NSLog(@"updating currentClinic");
        [cvc setCurrentClinic:self.clinicSelected];
    }
    if ([[segue identifier] isEqualToString:@"goHome"]){
        NSLog(@"go home");
    }
}

-(IBAction)unwindFromClinicViewController:(UIStoryboardSegue*)segue{
    [self loadData];
}

@end
