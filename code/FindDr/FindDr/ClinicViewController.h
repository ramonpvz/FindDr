//
//  ClinicViewController.h
//  FindDr
//
//  Created by Eduardo Alvarado Díaz on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Clinic.h"

@interface ClinicViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) Clinic *currentClinic;
@property (nonatomic, assign) BOOL hasSchedule;

@end
