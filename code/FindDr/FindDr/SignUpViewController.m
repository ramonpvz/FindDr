//
//  SignUpViewController.m
//  FindDr
//
//  Created by Eduardo Alvarado Díaz on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "SignUpViewController.h"
#import "TextFieldValidator.h"
#import "ActionSheetStringPicker.h"
#import "ActionSheetDatePicker.h"

@interface SignUpViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet TextFieldValidator *emailText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *passwordText;
@property (strong, nonatomic) IBOutlet UISwitch *switchUser;
@property (strong, nonatomic) IBOutlet TextFieldValidator *licenseText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *titleText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *genderText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *birthdayText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *firstNameText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *lastNameText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *secondLastNameText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *phoneNumberText;
@property (strong, nonatomic) IBOutlet UILabel *specialtiesLabel;
@property (strong, nonatomic) IBOutlet UIButton *addSpecialtyButton;
@property (strong, nonatomic) IBOutlet UITableView *specialtiesTable;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self switchUserTapped:self.switchUser];

    //Validations
    [self.emailText addRegx:@"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" withMsg:@"Enter valid email"];

    [self.passwordText addRegx:@"^.{8,}$" withMsg:@"At least 8 characters for password"];

    //self.birthdayText.isMandatory = NO;

    [self.phoneNumberText addRegx:@"[0-9]{1,}" withMsg:@"Only numeric characters are allowed"];

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
    if ([self.emailText validate] & [self.passwordText validate]  & [self.titleText validate] & [self.genderText validate] & [self.birthdayText validate] & [self.firstNameText validate] & [self.lastNameText validate] & [self.secondLastNameText validate] & [self.phoneNumberText validate]) {

        if ((self.switchUser.on == YES) & [self.licenseText validate]) {
            if (YES ) { //si el doctor tiene por lo menos una especialidad
                //guardar datos del usuario doctor y mandarlo a crear la clinica
                [self performSegueWithIdentifier:@"showClinics" sender:self];
            }/*else{
                [[[UIAlertView alloc] initWithTitle:nil message:@"Please, add a specialty." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }*/
        }else {
            //guardar datos del usuario paciente y permitir entrar
        }

    }
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

- (void)textFieldDidBeginEditing:(UITextField *)myTextField{
    if (myTextField == self.titleText) {
        [myTextField resignFirstResponder];
        // Create an array of strings you want to show in the picker:
        NSArray *data = [NSArray arrayWithObjects:@"Sr.", @"Sra.", @"Dr.", @"Dra.", nil];

        [ActionSheetStringPicker showPickerWithTitle:@"Select:"
                                                rows:data
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               NSLog(@"Selected Index: %ld", (long)selectedIndex);
                                               NSLog(@"Selected Value: %@", selectedValue);
                                               self.titleText.text = selectedValue;
                                               [self.titleText validate];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block String Picker Canceled");
                                         }
                                              origin:self.view];

    }else if (myTextField == self.genderText){
        [myTextField resignFirstResponder];
        NSArray *genders = [NSArray arrayWithObjects:@"Male", @"Female", nil];

        [ActionSheetStringPicker showPickerWithTitle:@"Select:"
                                                rows:genders
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               self.genderText.text = selectedValue;
                                               [self.genderText validate];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block String Picker Canceled");
                                         }
                                              origin:self.view];

    }else if (myTextField == self.birthdayText){
        [myTextField resignFirstResponder];
        [ActionSheetDatePicker showPickerWithTitle:@"Select:"
                                    datePickerMode:UIDatePickerModeDate
                                      selectedDate:[NSDate date]
                                         doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
                                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                             [dateFormatter setDateFormat:@"dd-MM-yyyy"];
                                             NSString *strDate = [dateFormatter stringFromDate:selectedDate];

                                             self.birthdayText.text = strDate;
                                             [self.birthdayText validate];
                                         }
                                       cancelBlock:^(ActionSheetDatePicker *picker) {
                                           NSLog(@"Block Date Picker Canceled");
                                       }
                                            origin:self.view];
    }
}

- (IBAction)addSpecialtyButtonTapped:(UIButton *)sender {
    NSLog(@"add specialty tapped");
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (self.switchUser.on == YES) {
        //Doctor
        NSLog(@"Save doctor user");
    }else{
        //Patient
        NSLog(@"Save patient user");
    }
}



@end
