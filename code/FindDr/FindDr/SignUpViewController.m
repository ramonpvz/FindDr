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
#import "Speciality.h"
#import "Login.h"
#import "Doctor.h"
#import "Patient.h"
#import "MBProgressHUD.h"

@interface SignUpViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) NSData *imageData;
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
@property (strong, nonatomic) NSMutableArray *specialties;
@property (strong, nonatomic) NSArray *specialtiesCatalog;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self switchUserTapped:self.switchUser];

    //Validations
    [self.emailText addRegx:@"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" withMsg:@"Enter valid email"];

    [self.passwordText addRegx:@"^.{6,32}$" withMsg:@"Password charaters limit should be come between 6-32"];

    self.secondLastNameText.isMandatory = NO;
    self.birthdayText.isMandatory = NO;

    [self.phoneNumberText addRegx:@"[0-9]{1,}" withMsg:@"Only numeric characters are allowed"];

    self.specialties = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table Specialties

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.specialties.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSpecialty" forIndexPath:indexPath];

    Speciality *especiality = self.specialties[indexPath.row];
    cell.textLabel.text = especiality.name;
    cell.detailTextLabel.text = [especiality objectForKey:@"description"];

    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row (speciality)
        [self.specialties removeObjectAtIndex:indexPath.row];

        // Animate the deletion
        [self.specialtiesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Actions

- (IBAction)nextButtonTapped:(UIBarButtonItem *)sender {
    NSLog(@"Validations");
    if ([self.emailText validate] & [self.passwordText validate]  & [self.titleText validate] & [self.genderText validate] & [self.birthdayText validate] & [self.firstNameText validate] & [self.lastNameText validate] & [self.secondLastNameText validate] & [self.phoneNumberText validate]) {

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        Login *login = [[Login alloc]init];
        if ((self.switchUser.on == YES) & [self.licenseText validate]) {
            if (self.specialties.count > 0) { //the doctor has at least one specialty
                [login signUp:self.emailText.text pass:self.passwordText.text user:^(User *pfUser) {
                    NSLog(@"User: %@",pfUser);
                    if (pfUser.message == nil) { //if logins is successful
                        pfUser.profile = @"doctor";
                        [pfUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //create the doctor
                            if (pfUser.username != nil) {
                                //save doctor data
                                Doctor *doc = [Doctor object];

                                doc.user = [login getCurrentUser];
                                self.imageData = UIImageJPEGRepresentation(self.userImage.image, 1.0f);
                                PFFile *image = [PFFile fileWithName:@"image.png" data:self.imageData];
                                doc.photo = image;
                                doc.licence = self.licenseText.text;
                                doc.title = self.titleText.text;
                                doc.gender = self.genderText.text;
                                doc.email = self.emailText.text;
                                doc.phone = self.phoneNumberText.text;

                                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                                [formatter setDateFormat:@"dd/MM/yyyy"];
                                NSDate *date = [formatter dateFromString:self.birthdayText.text];
                                doc.birthday = date;

                                doc.name = self.firstNameText.text;
                                doc.lastName = self.lastNameText.text;
                                doc.secondLastName = self.secondLastNameText.text;


                                [doc saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    for (Speciality *speciality in self.specialties){
                                        [doc addSpeciality:speciality];
                                    }

                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    [self performSegueWithIdentifier:@"showClinics" sender:self];
                                }];
                            }else{
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                [[[UIAlertView alloc] initWithTitle:nil message:pfUser.message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                            }
                        }];
                    }else{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [[[UIAlertView alloc] initWithTitle:nil message:pfUser.message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                    }
                }];
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [[[UIAlertView alloc] initWithTitle:nil message:@"Please, add at least one specialty." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
        }else {
            Login *login = [[Login alloc]init];
            [login signUp:self.emailText.text pass:self.passwordText.text user:^(User *pfUser) {
                NSLog(@"User: %@",pfUser);
                if (pfUser.message == nil) { //if logins is successful
                    pfUser.profile = @"patient";
                    [pfUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //create the patient
                        if (pfUser.username != nil) {
                            //save doctor data
                            Patient *patient = [Patient object];

                            patient.user = [login getCurrentUser];
                            self.imageData = UIImageJPEGRepresentation(self.userImage.image, 1.0f);
                            PFFile *image = [PFFile fileWithName:@"image.png" data:self.imageData];
                            patient.photo = image;
                            patient.title = self.titleText.text;
                            patient.gender = self.genderText.text;
                            patient.email = self.emailText.text;
                            patient.phone = self.phoneNumberText.text;

                            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                            [formatter setDateFormat:@"dd/MM/yyyy"];
                            NSDate *date = [formatter dateFromString:self.birthdayText.text];
                            patient.birthday = date;

                            patient.name = self.firstNameText.text;
                            patient.lastName = self.lastNameText.text;
                            patient.secondLastName = self.secondLastNameText.text;


                            [patient saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                [self performSegueWithIdentifier:@"goSearchDoctor" sender:self];
                            }];
                        }else{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            [[[UIAlertView alloc] initWithTitle:nil message:pfUser.message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                        }
                    }];
                }else{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [[[UIAlertView alloc] initWithTitle:nil message:pfUser.message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                }
            }];
        }
    }
}

- (IBAction)imageUserTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take photo", @"Choose from library", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;

    if (buttonIndex == 0){  //NSLog(@"TakePhotoWithCamera");
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }else if (buttonIndex == 1){  //NSLog(@"SelectPhotoFromLibrary");
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }else if (buttonIndex == 2){
        //NSLog(@"cancel");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // Access the edited image from info dictionary
    UIImage *imageEdited = [info objectForKey:@"UIImagePickerControllerEditedImage"];

    self.userImage.image = imageEdited;

    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchUserTapped:(UISwitch *)sender {
    if (sender.on == YES) {
        //show some elements to doctor
        self.licenseText.hidden = NO;
        self.specialtiesLabel.hidden = NO;
        self.specialtiesTable.hidden = NO;
        self.addSpecialtyButton.hidden = NO;
        [self.specialtiesTable setEditing:YES animated:YES];
    }else{
        //hide some elements to pacients
        self.licenseText.hidden = YES;
        self.specialtiesLabel.hidden = YES;
        self.specialtiesTable.hidden = YES;
        self.addSpecialtyButton.hidden = YES;
        [self.specialtiesTable setEditing:NO animated:YES];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)myTextField{
    if (myTextField == self.titleText) {
        [myTextField resignFirstResponder];
        // Create an array of strings you want to show in the picker:
        NSArray *data = [NSArray arrayWithObjects:@"Dr.", @"Dra.", @"Sr.", @"Sra.", nil];

        [ActionSheetStringPicker showPickerWithTitle:@"Select:"
                                                rows:data
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               self.titleText.text = selectedValue;
                                               [self.titleText validate];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             //NSLog(@"Block String Picker Canceled");
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
                                             //NSLog(@"Block String Picker Canceled");
                                         }
                                              origin:self.view];

    }else if (myTextField == self.birthdayText){
        [myTextField resignFirstResponder];
        NSDate *dateSelected;
        if ([self.birthdayText.text isEqualToString:@""]) {
            dateSelected = [NSDate date];
        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"dd/MM/yyyy"];
            NSDate *date = [formatter dateFromString:self.birthdayText.text];
            dateSelected = date;
        }
        [ActionSheetDatePicker showPickerWithTitle:@"Select:"
                                    datePickerMode:UIDatePickerModeDate
                                      selectedDate:dateSelected
                                         doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
                                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                             [dateFormatter setDateFormat:@"dd/MM/yyyy"];
                                             NSString *strDate = [dateFormatter stringFromDate:selectedDate];

                                             self.birthdayText.text = strDate;
                                             [self.birthdayText validate];
                                         }
                                       cancelBlock:^(ActionSheetDatePicker *picker) {
                                           //NSLog(@"Block Date Picker Canceled");
                                       }
                                            origin:self.view];
    }
}

- (IBAction)addSpecialtyButtonTapped:(UIButton *)sender {
    NSMutableArray *nameSpecialities = [[NSMutableArray alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Speciality lisSpecialities:^(NSArray *specialities) {
        self.specialtiesCatalog = specialities;

        for (Speciality *speciality in self.specialtiesCatalog){
            [nameSpecialities addObject:speciality.name];
        }
        [ActionSheetStringPicker showPickerWithTitle:@"Select:"
                                                rows:nameSpecialities
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               if (![self doctorHasSpecialty:self.specialtiesCatalog[selectedIndex]]) {
                                                   [self.specialties addObject:self.specialtiesCatalog[selectedIndex]];
                                                   [self.specialtiesTable reloadData];
                                               }
                                               [MBProgressHUD hideHUDForView:self.view animated:YES];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             //NSLog(@"Block String Picker Canceled");
                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                         }
                                              origin:self.view];
    }];
}

- (BOOL)doctorHasSpecialty:(Speciality *)specialty{
    for (Speciality *sp in self.specialties) {
        if ([sp.objectId isEqual:specialty.objectId]) {
            return YES;
        }
    }
    return NO;
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
