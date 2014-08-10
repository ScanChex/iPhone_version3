//
//  CheckOutInitialInformationViewController.m
//  ScanChex
//
//  Created by Rajeel Amjad on 26/07/2014.
//  Copyright (c) 2014 Adnan Ahmad. All rights reserved.
//

#import "CheckOutInitialInformationViewController.h"
#import "WebServiceManager.h"
#import "AsyncImageView.h"
#import "CheckOutStepTwoViewController.h"
@interface CheckOutInitialInformationViewController ()
-(id)initWithScan;
-(id)initWithManual;
@end

@implementation CheckOutInitialInformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // Custom initialization
    }
    return self;
}

+(id)initCheckWithScan {
    return [[[CheckOutInitialInformationViewController alloc]initWithScan] autorelease];
}
-(id)initWithScan {
    self=[super initWithNibName:@"CheckOutInitialInformationViewController" bundle:nil];
    if (self) {
        self.isScan = TRUE;
        // Custom initialization
    }
    return self;
}
+(id)initCheckWithManual {
    return [[[CheckOutInitialInformationViewController alloc]initWithManual] autorelease];
}
-(id)initWithManual {
    self=[super initWithNibName:@"CheckOutInitialInformationViewController" bundle:nil];
    if (self) {
        self.isScan = FALSE;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.scrollView setContentSize:CGSizeMake(320, 490)];
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScanner:) name:K_Update_ScanCode object:Nil];
    if (self.isScan) {
        [self.scanButton setTitle:@"SCAN MODE" forState:UIControlStateNormal];
        [self showQrScanner];
    }
    else {
        [self.scanButton setTitle:@"MANUAL LOOKUP" forState:UIControlStateNormal];
        [self fetchAllData];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Button Pressed Events
- (IBAction)backButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)checkOutAction:(id)sender {
    NSLog(@"Check Out");
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    UserDTO *user=[[VSSharedManager sharedManager] currentUser];
    [[WebServiceManager sharedManager] checkoutFirstStepWithMasterKey:[NSString stringWithFormat:@"%d",user.masterKey] description:[self.descriptionTextField text] serial_number:[self.serialNumberTextField text] address:[self.addressTextView text] department:[self.departmentTextField text] user_id:[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"] type:@"check_out" asset_id:self.currentSelectedAsset client:[self.clientTextField text] withCompletionHandler:^(id data, BOOL error)
     {
      
         
         [SVProgressHUD dismiss];
         if (!error) {
             NSMutableArray * tempDict = [data mutableCopy];
             NSLog(@"%@",tempDict);
             [self.navigationController pushViewController:[CheckOutStepTwoViewController initWithData:[tempDict objectAtIndex:0] assetData:self.dataDict selectedAsset:self.currentSelectedAsset]  animated:YES];
         }
         
         
         
     }];
}

#pragma mark- NSNOTIFICATION CENTRE

-(void)updateScanner:(NSNotification *)info
{
    
    DLog(@"Current Scan %@",self.currentScannedCode);
    [self fetchAllData];
   
}

-(void)fetchAllData {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    UserDTO *user=[[VSSharedManager sharedManager] currentUser];
    [[WebServiceManager sharedManager] getAllCheckOutDataWithMasterKey:[NSString stringWithFormat:@"%d",user.masterKey] withCompletionHandler:^(id data, BOOL error)
     {
         
         [SVProgressHUD dismiss];
         if (!error) {
             self.dataDict = [data mutableCopy];
             if (self.isScan) {
                 for (int i  = 0; i<[[self.dataDict objectForKey:@"assets"] count]; i++) {
                     if ([[[[self.dataDict objectForKey:@"assets"] objectAtIndex:i] objectForKey:@"asset_code"] isEqualToString:self.currentScannedCode]) {
                         [self.descriptionTextField setText:[[[self.dataDict objectForKey:@"assets"] objectAtIndex:i] objectForKey:@"description"]];
                         [self.assetImageView setImageURL:[NSURL URLWithString:[[[self.dataDict objectForKey:@"assets"] objectAtIndex:i] objectForKey:@"asset_photo"]]];
                         [self.assetIDTextField setText:[[[self.dataDict objectForKey:@"assets"] objectAtIndex:i] objectForKey:@"asset_id"]];
                         self.currentSelectedAsset = [[[self.dataDict objectForKey:@"assets"] objectAtIndex:i] objectForKey:@"id"];
                         [self.addressTextView setText:[[[self.dataDict objectForKey:@"assets"] objectAtIndex:i] objectForKey:@"address"]];
                         [self.departmentTextField setText:[[[self.dataDict objectForKey:@"assets"] objectAtIndex:i] objectForKey:@"department"]];
                         for (int j = 0; j<[[self.dataDict objectForKey:@"clients"] count]; j++) {
                             NSDictionary * tempDict = [[self.dataDict objectForKey:@"clients"]objectAtIndex:j];
                             if ([[tempDict objectForKey:@"id"] isEqualToString:[[[self.dataDict objectForKey:@"assets"] objectAtIndex:i] objectForKey:@"client_id"]]) {
                                 [self.clientTextField setText:[tempDict objectForKey:@"name"]];
                                 break;
                                 
                             }
                         }
                         break;
                     }
                 }
             }
         }
         
         
         
     }];
}


#pragma mark UitextField Delegate
-(void)resignKeyboard {
    [self.view endEditing:YES];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField {
//    UIToolbar * keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
//    
//    keyboardToolBar.barStyle = UIBarStyleDefault;
//    [keyboardToolBar setItems: [NSArray arrayWithObjects:
//                               
//                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
//                                [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignKeyboard)],
//                                nil]];
//    textField.inputAccessoryView = keyboardToolBar;

    if ([textField isEqual:self.descriptionTextField]) {
        UIPickerView * tempPicker = [[UIPickerView alloc]init];
        [tempPicker setTag:0];
        [tempPicker setDataSource:self];
        [tempPicker setDelegate:self];
        [textField setInputView:tempPicker];
    }
    if ([textField isEqual:self.assetIDTextField]) {
        UIPickerView * tempPicker = [[UIPickerView alloc]init];
        [tempPicker setTag:1];
        [tempPicker setDataSource:self];
        [tempPicker setDelegate:self];
        [textField setInputView:tempPicker];
    }
    if ([textField isEqual:self.departmentTextField]) {
        UIPickerView * tempPicker = [[UIPickerView alloc]init];
        [tempPicker setTag:3];
        [tempPicker setDataSource:self];
        [tempPicker setDelegate:self];
        [textField setInputView:tempPicker];
    }
    if ([textField isEqual:self.clientTextField]) {
        UIPickerView * tempPicker = [[UIPickerView alloc]init];
        [tempPicker setTag:4];
        [tempPicker setDataSource:self];
        [tempPicker setDelegate:self];
        [textField setInputView:tempPicker];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
//    UIToolbar * keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
//    
//    keyboardToolBar.barStyle = UIBarStyleDefault;
//    [keyboardToolBar setItems: [NSArray arrayWithObjects:
//                                
//                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
//                                [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignKeyboard)],
//                                nil]];
//    textView.inputAccessoryView = keyboardToolBar;
    
    
        UIPickerView * tempPicker = [[UIPickerView alloc]init];
        [tempPicker setTag:2];
        [tempPicker setDataSource:self];
        [tempPicker setDelegate:self];
        [textView setInputView:tempPicker];
        [textView reloadInputViews];
    
}

#pragma mark UIPIcker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView tag] == 0) {
        return [[self.dataDict objectForKey:@"assets"] count];
    }
    if ([pickerView tag] == 1) {
        return [[self.dataDict objectForKey:@"assets"] count];
    }
    if ([pickerView tag] == 2) {
        return [[self.dataDict objectForKey:@"addresses"] count];
    }
    if ([pickerView tag] == 3) {
        return [[self.dataDict objectForKey:@"departments"] count];
    }
    if ([pickerView tag] == 4) {
        return [[self.dataDict objectForKey:@"clients"] count];
    }
    else {
        return 0;
    }
    
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([pickerView tag] == 0) {
        return [[[self.dataDict objectForKey:@"assets"] objectAtIndex:row] objectForKey:@"description"];
    }
    if ([pickerView tag] == 1) {
        return [[[self.dataDict objectForKey:@"assets"] objectAtIndex:row] objectForKey:@"asset_id"];
    }
    if ([pickerView tag] == 2) {
        return [[[self.dataDict objectForKey:@"addresses"] objectAtIndex:row] objectForKey:@"address1"];
    }
    if ([pickerView tag] == 3) {
        return [[[self.dataDict objectForKey:@"departments"] objectAtIndex:row] objectForKey:@"name"];
    }
    if ([pickerView tag] == 4) {
        return [[[self.dataDict objectForKey:@"clients"] objectAtIndex:row] objectForKey:@"name"];
    }
    else {
        return nil;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView tag] == 0) {
        self.descriptionTextField.text = [[[self.dataDict objectForKey:@"assets"] objectAtIndex:row] objectForKey:@"description"];
    }
    if ([pickerView tag] == 1) {
        self.assetIDTextField.text =  [[[self.dataDict objectForKey:@"assets"] objectAtIndex:row] objectForKey:@"asset_id"];
        self.currentSelectedAsset =[[[self.dataDict objectForKey:@"assets"] objectAtIndex:row] objectForKey:@"id"];
        [self.assetImageView setImageURL:[NSURL URLWithString:[[[self.dataDict objectForKey:@"assets"] objectAtIndex:row] objectForKey:@"asset_photo"]]];
    }
    if ([pickerView tag] == 2) {
        self.addressTextView.text =  [[[self.dataDict objectForKey:@"addresses"] objectAtIndex:row] objectForKey:@"address1"];
    }
    if ([pickerView tag] == 3) {
        self.departmentTextField.text =  [[[self.dataDict objectForKey:@"departments"] objectAtIndex:row] objectForKey:@"name"];
    }
    if ([pickerView tag] == 4) {
        self.clientTextField.text =  [[[self.dataDict objectForKey:@"clients"] objectAtIndex:row] objectForKey:@"name"];
    }
    
}




@end
