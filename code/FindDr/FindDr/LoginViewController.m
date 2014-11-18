//
//  LoginViewController.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/11/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "LoginViewController.h"
#import "Login.h"
#import "TextFieldValidator.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet TextFieldValidator *usernameField;
@property (strong, nonatomic) IBOutlet TextFieldValidator *passwordField;
@property Login *login;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Validations
    [self.usernameField addRegx:@"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" withMsg:@"Enter valid email"];
    [self.passwordField addRegx:@"^.{6,32}$" withMsg:@"Password charaters limit should be come between 6-32"];

    self.login = [[Login alloc] init];
    [self clear];
    User *currentUser = [self.login getCurrentUser];
    if (currentUser != nil) {
        if ([currentUser.profile isEqualToString:@"doctor"])
            [self performSegueWithIdentifier:@"inboxDr" sender:self];
        else
            [self performSegueWithIdentifier:@"homeSearch" sender:self];
    }
}

- (IBAction)login:(id)sender {
    if ([self.usernameField validate] & [self.passwordField validate]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [self.usernameField text], @"username",
                                     [self.passwordField text], @"password",
                                     nil];

        [self.login login:credentials user:^(PFUser *pfUser) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([self.login getCurrentUser] != nil)
            {
                User *usr = (User*)pfUser;
                [self clear];
                if ([usr.profile isEqualToString:@"doctor"])
                {
                    [self performSegueWithIdentifier:@"inboxDr" sender:self];
                }
                else if ([usr.profile isEqualToString:@"patient"])
                {
                    [self performSegueWithIdentifier:@"homeSearch" sender:self];
                }
                else
                {
                    NSLog(@"Invalid profile: %@",usr.profile);
                }
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"User/password is not valid." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
        }];
    }
}

- (void) clear {
    self.usernameField.text = @"";
    self.passwordField.text = @"";
}

- (IBAction)unwindFromDrInboxViewController:(UIStoryboardSegue*)segue{
    [self.login logOut];
}

@end
