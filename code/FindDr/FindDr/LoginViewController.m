//
//  LoginViewController.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/11/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "LoginViewController.h"
#import "Login.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property Login *login;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.login = [[Login alloc] init];
}

- (IBAction)login:(id)sender {

    NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:
                               [self.usernameField text], @"username",
                               [self.passwordField text], @"password",
                               nil];

    [self.login login:credentials user:^(PFUser *pfUser) {
        if (pfUser != nil)
        {
            [self clear];
            [self performSegueWithIdentifier:@"showSignUp" sender:self];
        }
    }];

}

- (void) clear {
    self.usernameField.text = @"";
    self.passwordField.text = @"";
}

@end
