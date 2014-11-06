//
//  SignUpViewController.m
//  FindDr
//
//  Created by Eduardo Alvarado Díaz on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UITextField *emailText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UISwitch *switchUser;
@property (strong, nonatomic) IBOutlet UITextField *licenseText;
@property (strong, nonatomic) IBOutlet UITextField *titleText;
@property (strong, nonatomic) IBOutlet UITextField *genderText;
@property (strong, nonatomic) IBOutlet UITextField *birthdayText;
@property (strong, nonatomic) IBOutlet UITextField *firstNameText;
@property (strong, nonatomic) IBOutlet UITextField *lastNameText;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberText;
@property (strong, nonatomic) IBOutlet UILabel *specialtiesLabel;
@property (strong, nonatomic) IBOutlet UIButton *addSpecialtyButton;
@property (strong, nonatomic) IBOutlet UITableView *specialtiesTable;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //check the user.
    self.switchUser.on = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table Specialties

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSpecialty" forIndexPath:indexPath];

    return cell;
}

#pragma mark - Actions

- (IBAction)nextButtonTapped:(UIBarButtonItem *)sender {
    NSLog(@"Validations");
    [self performSegueWithIdentifier:@"showClinics" sender:self];
}

- (IBAction)imageUserTapped:(id)sender {
    NSLog(@"image user tapped");
}

- (IBAction)switchUserTapped:(UISwitch *)sender {
    if (sender.on == YES) {
        //show some elements to pacients
        self.licenseText.hidden = NO;
        self.specialtiesLabel.hidden = NO;
        self.specialtiesTable.hidden = NO;
        self.addSpecialtyButton.hidden = NO;
    }else{
        //hide some elements to pacients
        self.licenseText.hidden = YES;
        self.specialtiesLabel.hidden = YES;
        self.specialtiesTable.hidden = YES;
        self.addSpecialtyButton.hidden = YES;
    }
}

- (IBAction)titleTapped:(UITextField *)sender {
    NSLog(@"title tapped");
}

- (IBAction)genderTapped:(UITextField *)sender {
    NSLog(@"gender tapped");
}

- (IBAction)birthdayTapped:(UITextField *)sender {
    NSLog(@"birthday tapped");
}

- (IBAction)addSpecialtyButtonTapped:(UIButton *)sender {
    NSLog(@"add specialty tapped");
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self.switchUser isSelected] == YES) {
        //Doctor
        NSLog(@"Save doctor user");
    }else{
        //Patient
        NSLog(@"Save patient user");
    }
}



@end
