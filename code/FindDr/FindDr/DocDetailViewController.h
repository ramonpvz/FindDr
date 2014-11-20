//
//  DocDetailViewController.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/19/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Doctor.h"
#import "Patient.h"
#import "Clinic.h"

@interface DocDetailViewController : UIViewController

@property Doctor *currentDoctor;
@property Patient *currentPatient;
@property Clinic *currentClinic;

@end
