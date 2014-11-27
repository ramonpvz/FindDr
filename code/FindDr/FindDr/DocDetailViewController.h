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
#import "RateView.h"

@interface DocDetailViewController : UIViewController <RateViewDelegate>

@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property Doctor *currentDoctor;
@property Patient *currentPatient;
@property Clinic *currentClinic;

@end
