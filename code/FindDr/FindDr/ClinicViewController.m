//
//  ClinicViewController.m
//  FindDr
//
//  Created by Eduardo Alvarado Díaz on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "ClinicViewController.h"
#import "TextFieldValidator.h"
#import "Doctor.h"
#import "Clinic.h"
#import "MBProgressHUD.h"

@interface ClinicViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet TextFieldValidator *nameClinicText;
@property (strong, nonatomic) IBOutlet UITextView *descriptionText;
@property (strong, nonatomic) IBOutlet UIImageView *imageClinic;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) IBOutlet TextFieldValidator *streetText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *numberText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *cityText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *stateText;
@property (strong, nonatomic) IBOutlet TextFieldValidator *postalCodeText;
@property (strong, nonatomic) Doctor *currentDoctor;

@end

@implementation ClinicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Doctor getDoctorByUser:[PFUser currentUser] doc:^(Doctor *doctor) {
        self.currentDoctor = doctor;
    }];

    //load clinic values
    self.nameClinicText.text = self.currentClinic.name;
    self.descriptionText.text = [self.currentClinic objectForKey:@"description"];
    self.imageClinic.image = [UIImage imageWithData:[self.currentClinic.photo getData]];
    self.streetText.text = self.currentClinic.street;
    self.numberText.text = self.currentClinic.number;
    self.cityText.text = self.currentClinic.city;
    self.stateText.text = self.currentClinic.state;
    self.postalCodeText.text = self.currentClinic.zipCode;

    [self.numberText addRegx:@"[0-9]{1,}" withMsg:@"Only numeric characters are allowed"];
    [self.postalCodeText addRegx:@"[0-9]{1,5}" withMsg:@"Only 5 numeric characters are allowed"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonTapped:(UIBarButtonItem *)sender {
    NSLog(@"Validations");
    if ([self.nameClinicText validate] & [self.streetText validate]  & [self.numberText validate] & [self.cityText validate] & [self.stateText validate] & [self.postalCodeText validate]) {

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if (YES ) { //si el doctor guarda para la clinica el schedule y el marcador en mapa
            //update clinic values
            self.currentClinic.name = self.nameClinicText.text;
            [self.currentClinic setObject:self.descriptionText.text forKey:@"description"];
            self.imageData = UIImageJPEGRepresentation(self.imageClinic.image, 1.0f);
            PFFile *image = [PFFile fileWithName:@"image.png" data:self.imageData];
            self.currentClinic.photo = image;
            self.currentClinic.street = self.streetText.text;
            self.currentClinic.number = self.numberText.text;
            self.currentClinic.city = self.cityText.text;
            self.currentClinic.state = self.stateText.text;
            self.currentClinic.zipCode = self.postalCodeText.text;
            [self.currentClinic saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self performSegueWithIdentifier:@"clinicAdded" sender:self];
            }];

        }/*else{
          [[[UIAlertView alloc] initWithTitle:nil message:@"Please, add a schedule/mark in map." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
          }*/
    }
}

- (IBAction)imageClinicTapped:(id)sender {
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

    self.imageClinic.image = imageEdited;

    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)viewMapButtonTapped:(UIButton *)sender {
}

- (IBAction)scheduleButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"showSchedule" sender:self];
}

- (IBAction)selectSpecialtiesTapped:(UIButton *)sender {
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"clinicAdded"]){
        NSLog(@"updated data clinic");
    }
}


@end
