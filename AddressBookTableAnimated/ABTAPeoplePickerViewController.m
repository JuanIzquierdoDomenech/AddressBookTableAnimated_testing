//
//  ABTAPeoplePickerViewController.m
//  AddressBookTableAnimated
//
//  Created by Juan Jesús Izquierdo Doménech on 05/02/13.
//  Copyright (c) 2013 Juan Jesús Izquierdo Doménech. All rights reserved.
//

#import "ABTAPeoplePickerViewController.h"

@interface ABTAPeoplePickerViewController ()

@end

@implementation ABTAPeoplePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    ABPeoplePickerNavigationController *peoplePiclerNavController = [[ABPeoplePickerNavigationController alloc] init];
    peoplePiclerNavController.peoplePickerDelegate = self;
    
    [self presentViewController:peoplePiclerNavController
                       animated:YES
                     completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

// Called after the user has pressed cancel
// The delegate is responsible for dismissing the peoplePicker
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES
                                     completion:^(){
                                         
                                         [self.navigationController
                                          popToRootViewControllerAnimated:YES];
                                         
                                     }];
}

// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person;
{
    return YES;
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
{
    return NO;
}

@end
