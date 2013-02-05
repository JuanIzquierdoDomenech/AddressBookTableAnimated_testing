//
//  ABTATableViewController.m
//  AddressBookTableAnimated
//
//  Created by Juan Jesús Izquierdo Doménech on 04/02/13.
//  Copyright (c) 2013 Juan Jesús Izquierdo Doménech. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "ABTATableViewController.h"
#import "ADLivelyTableView.h"

NSString *const kDenied = @"Access to AddressBook is denied";
NSString *const kRestricted = @"Access to AddressBook is restricted";

@interface ABTATableViewController ()
{
    NSMutableArray *elementsForTesting;
    NSArray *contacts;  //De ABRecordRef
    
    ABAddressBookRef addressBook;
}

@end

@implementation ABTATableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ////////////////////////////////////////////// Para el array de testing
    elementsForTesting = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 100; i++)
        elementsForTesting[i] = [NSString stringWithFormat:@"CELL %i", i];
    ///////////////////////////////////////////////////////////////////////
    
    /////////////////////////////////////////////////// Para los contactos
    
    CFErrorRef error = NULL;
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusAuthorized:

            addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            
            //Aqui accedemos a los contactos
            contacts = [self readFromAddressBook:addressBook];
            
            //[self getContentList:addressBook];
            
            if (addressBook)
                CFRelease(addressBook);
            
            break;
           
        case kABAuthorizationStatusNotDetermined:
            addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            ABAddressBookRequestAccessWithCompletion
            (addressBook, ^(bool granted, CFErrorRef error){
                if (granted) {
                    
                    //Aqui accedemos a los contactos
                    
                }
            });
            break;
            
        default:
            break;
    }
        
    ///////////////////////////////////////////////////////////////////////
    
    ADLivelyTableView * livelyTableView = (ADLivelyTableView *)self.tableView;
    livelyTableView.initialCellTransformBlock = ADLivelyTransformHelix;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Accesing to AddressBook

- (NSArray *)readFromAddressBook:(ABAddressBookRef)paramAddressBook
{
    NSArray *paramContactsArray = (__bridge_transfer NSArray *) ABAddressBookCopyArrayOfAllPeople(paramAddressBook);
    
    return paramContactsArray;
}

- (UIImage *)getPersonImage:(ABRecordRef)paramPerson
{
    NSData *imageData = (__bridge_transfer NSData*)ABPersonCopyImageData(paramPerson);
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    return image;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return elementsForTesting.count;
    return contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    // cell.textLabel.text = elementsForTesting[indexPath.row];

    ABRecordRef person = (__bridge ABRecordRef)contacts[indexPath.row];
    NSString *firstName =
    (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    cell.textLabel.text = firstName;
    //cell.imageView.image = [UIImage imageNamed:@"nyan2.gif"];
    cell.imageView.image = [self getPersonImage:person];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

# pragma mark - Otros

- (void)grantAddressBook
{
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            [self getContentList:addressBookRef];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self getContentList:addressBookRef];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
}

- (void)getContentList:(ABAddressBookRef)addressBookRef
{
    CFArrayRef arrayOfEntries = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    CFIndex countOfEntries = CFArrayGetCount(arrayOfEntries);
    for (int i=0; i!=countOfEntries; i++) {
        NSLog(@"------------------------ [%d] ------------------------", i);
        ABRecordRef currentRecord = CFArrayGetValueAtIndex(arrayOfEntries, i);
        
        //image
        NSData *imageData = (__bridge_transfer NSData*)ABPersonCopyImageData(currentRecord);
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        NSLog(@"image = %@", image);
        
        //last
        NSString *lastName  = (__bridge_transfer NSString *)ABRecordCopyValue(currentRecord, kABPersonLastNameProperty);
        if (lastName)
            NSLog(@"lastName：%@", lastName);
        
        //firstname
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(currentRecord, kABPersonFirstNameProperty);
        if (firstName)
            NSLog(@"firstName：%@", firstName);
        
        //nickname
        NSString *nickName  = (__bridge_transfer NSString *)ABRecordCopyValue(currentRecord, kABPersonNicknameProperty);
        if (nickName)
            NSLog(@"nickName：%@", nickName);
        
        //middlename
        NSString *middlename = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonMiddleNameProperty);
        if(middlename)
            NSLog(@"middlename：%@", nickName);
        
        //prefix
        NSString *prefix = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonPrefixProperty);
        if(prefix)
            NSLog(@"prefix：%@", prefix);
        
        //suffix
        NSString *suffix = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonSuffixProperty);
        if(suffix)
            NSLog(@"suffix：%@", suffix);
        
        //firstname phonetic
        NSString *firstnamePhonetic = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonFirstNamePhoneticProperty);
        if(firstnamePhonetic != nil)
            NSLog(@"firstnamePhonetic : %@", firstnamePhonetic);
        
        //lastname phonetic
        NSString *lastnamePhonetic = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonLastNamePhoneticProperty);
        if(lastnamePhonetic != nil)
            NSLog(@"lastnamePhonetic : %@", lastnamePhonetic);
        
        //middlename phonetic
        NSString *middlenamePhonetic = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonMiddleNamePhoneticProperty);
        if(middlenamePhonetic != nil)
            NSLog(@"middlenamePhonetic : %@", middlenamePhonetic);
        
        //jobtitle
        NSString *jobtitle = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonJobTitleProperty);
        if (jobtitle)
            NSLog(@"jobtitle : %@", jobtitle);
        
        //Organization
        NSString *organization = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonOrganizationProperty);
        if(organization)
            NSLog(@"organization : %@", organization);
        
        //department
        NSString *department = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonDepartmentProperty);
        if(department)
            NSLog(@"organization : %@", organization);
        
        //birthday
        NSDate *birthday = (__bridge_transfer NSDate*)ABRecordCopyValue(currentRecord, kABPersonBirthdayProperty);
        if(birthday)
            NSLog(@"birthday : %@", birthday);
        
        //note
        NSString *note = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonNoteProperty);
        if(note)
            NSLog(@"note : %@", note);
        
        //create at
        NSString *firstknow = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonCreationDateProperty);
        if(firstknow)
            NSLog(@"firstknow : %@", firstknow);
        
        //update at
        NSString *lastknow = (__bridge_transfer NSString*)ABRecordCopyValue(currentRecord, kABPersonModificationDateProperty);
        if(lastknow)
            NSLog(@"lastknow : %@", lastknow);
        
        //Phone
        ABMultiValueRef phone   = ABRecordCopyValue(currentRecord, kABPersonPhoneProperty);
        
        for(CFIndex x=0; x!=ABMultiValueGetCount(phone); x++) {
            NSString *phoneLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phone, x);
            
            if ([phoneLabel isEqualToString:(__bridge_transfer NSString *)kABPersonPhoneMobileLabel]) {
                NSLog(@"Cell phone：%@", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phone, x));
            }
            
            if ([phoneLabel isEqualToString:(__bridge_transfer NSString *)kABPersonPhoneIPhoneLabel]) {
                NSLog(@"iPhone：%@", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phone, x));
            }
            
            if ([phoneLabel isEqualToString:(__bridge_transfer NSString *)kABPersonPhoneMainLabel]) {
                NSLog(@"Main phone：%@", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phone, x));
            }
            
            if ([phoneLabel isEqualToString:(__bridge_transfer NSString *)kABPersonPhoneHomeFAXLabel]) {
                NSLog(@"Home Fax：%@", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phone, x));
            }
            
            if ([phoneLabel isEqualToString:(__bridge_transfer NSString *)kABPersonPhoneWorkFAXLabel]) {
                NSLog(@"Work Fax：%@", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phone, x));
            }
            
            if ([phoneLabel isEqualToString:(__bridge_transfer NSString *)kABPersonPhoneOtherFAXLabel]) {
                NSLog(@"Other Fax：%@", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phone, x));
            }
            
            if ([phoneLabel isEqualToString:(__bridge_transfer NSString *)kABPersonPhonePagerLabel]) {
                NSLog(@"Pager：%@", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phone, x));
            }
        }
        
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //phone label
            NSString * personPhoneLabel = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
            //phone number
            NSString * personPhone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            
            NSLog(@"%@:%@", personPhoneLabel, personPhone);
        }
        
        //Email
        ABMultiValueRef mail    = ABRecordCopyValue(currentRecord, kABPersonEmailProperty);
        for(CFIndex x=0; x!=ABMultiValueGetCount(mail); x++) {
            NSLog(@"E-Mail：%@", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(mail, x));
        }
        
        //Address
        ABMultiValueRef address = ABRecordCopyValue(currentRecord, kABPersonAddressProperty);
        for(CFIndex x=0; x!=ABMultiValueGetCount(address); x++) {
            
            NSString* addressLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(address, x);
            BOOL home = [addressLabel isEqualToString:(__bridge_transfer NSString *)kABHomeLabel];
            BOOL work = [addressLabel isEqualToString:(__bridge_transfer NSString *)kABWorkLabel];
            BOOL other = [addressLabel isEqualToString:(__bridge_transfer NSString *)kABOtherLabel];
            NSLog(@"%d || %d || %d", home, work, other);
            
            NSDictionary* personAddress =(__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(address, x);
            NSLog(@"Country：%@", [personAddress valueForKey:(__bridge_transfer NSString *)kABPersonAddressCountryKey]);
            NSLog(@"Zipcode：%@", [personAddress valueForKey:(__bridge_transfer NSString *)kABPersonAddressZIPKey]);
            NSLog(@"City：%@", [personAddress valueForKey:(__bridge_transfer NSString *)kABPersonAddressCityKey]);
            NSLog(@"State：%@", [personAddress valueForKey:(__bridge_transfer NSString *)kABPersonAddressStateKey]);
            NSLog(@"Street：%@", [personAddress valueForKey:(__bridge_transfer NSString *)kABPersonAddressStreetKey]);
            NSLog(@"Country code：%@", [personAddress valueForKey:(__bridge_transfer NSString *)kABPersonAddressCountryCodeKey]);
        }
        
        //url
        ABMultiValueRef url = ABRecordCopyValue(currentRecord, kABPersonURLProperty);
        for (int m = 0; m < ABMultiValueGetCount(url); m++)
        {
            //urlLabel
            NSString * urlLabel = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m));
            //url conent
            NSString * urlContent = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(url,m);
            NSLog(@"%@ : %@", urlLabel, urlContent);
        }
        
        //IM
        ABMultiValueRef instantMessage = ABRecordCopyValue(currentRecord, kABPersonInstantMessageProperty);
        for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
        {
            //IM Label
            NSString* instantMessageLabel = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
            NSLog(@"instantMessageLabel : %@", instantMessageLabel);
            
            NSDictionary* instantMessageContent =(__bridge_transfer NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
            NSString* username = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
            if(username != nil)
                NSLog(@"username : %@", username);
            
            NSString* service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
            if(service != nil)
                NSLog(@"service : %@", service);
        }
        
        //date
        ABMultiValueRef dates = ABRecordCopyValue(currentRecord, kABPersonDateProperty);
        int datescount = ABMultiValueGetCount(dates);
        for (int y = 0; y < datescount; y++)
        {
            //dates Label
            NSString* datesLabel = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(dates, y));
            //dates
            NSString* datesContent = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(dates, y);
            NSLog(@"%@ : %@", datesLabel, datesContent);
        }
        
        //kind
        CFNumberRef recordType = ABRecordCopyValue(currentRecord, kABPersonKindProperty);
        if (recordType == kABPersonKindOrganization) {
            // it's a company
            NSLog(@"it's a company\n");
        } else {
            // it's a person, resource, or room
            NSLog(@"it's a person, resource, or room\n");
        }
    }
    
    NSLog(@"Total:%ld", countOfEntries);
    CFRelease(arrayOfEntries);
}



@end
