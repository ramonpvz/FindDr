//
//  SelectSpecialtiesViewController.m
//  FindDr
//
//  Created by Eduardo Alvarado Díaz on 11/19/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "SelectSpecialtiesViewController.h"
#import "Speciality.h"

@interface SelectSpecialtiesViewController ()
@property (strong, nonatomic) IBOutlet UITableView *specialities;

@end

@implementation SelectSpecialtiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.specialtiesDoctor.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"specialtyCell" forIndexPath:indexPath];
    
    Speciality *especiality = self.specialtiesDoctor[indexPath.row];
    cell.textLabel.text = especiality.name;
    if ([self isSelected:especiality]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Speciality *sp = [self.specialtiesDoctor objectAtIndex:indexPath.row];
    if ([self isSelected:sp]){
        [self removeSpecialty:sp];
    }
    else{
        [self.specialtiesClinic addObject:sp];
    }
    [self.specialities reloadData];
}

#pragma mark - Actions
- (IBAction)saveButtonTapped:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"saveSpecialties" sender:self];
}

-(BOOL)isSelected:(Speciality*)specialty{
    for (Speciality *sp in self.specialtiesClinic) {
        if ([sp.objectId isEqual:specialty.objectId]) {
            return YES;
        }
    }
    return NO;
}

-(void)removeSpecialty:(Speciality *)specialty{
    Speciality *toDelete = nil;
    for (Speciality *sp in self.specialtiesClinic) {
        if ([sp.objectId isEqual:specialty.objectId]) {
            toDelete = sp;
        }
    }
    if (toDelete != nil) {
        [self.specialtiesClinic removeObject:toDelete];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
