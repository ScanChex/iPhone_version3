//
//  CheckOutStepTwoViewController.m
//  ScanChex
//
//  Created by Rajeel Amjad on 07/08/2014.
//  Copyright (c) 2014 Adnan Ahmad. All rights reserved.
//

#import "CheckOutStepTwoViewController.h"
#import "AsyncImageView.h"
#import "SharedManager.h"
#import "WebServiceManager.h"
#import "CheckOutConfirmationViewController.h"
@interface CheckOutStepTwoViewController ()

@end

@implementation CheckOutStepTwoViewController
+(id)initWithData:(NSDictionary*)data assetData:(NSMutableDictionary*)assetData selectedAsset:(NSString*)selectedAsset {
    return [[[CheckOutStepTwoViewController alloc]initselfWithData:data assetData:assetData selectedAsset:selectedAsset] autorelease];
}
-(id)initselfWithData:(NSDictionary*)data assetData:(NSMutableDictionary*)assetData selectedAsset:(NSString*)selectedAsset {
    self=[super initWithNibName:@"CheckOutStepTwoViewController" bundle:nil];
    if (self) {
        self.initialData = [data mutableCopy];
        self.assetData = [assetData mutableCopy];
        self.selectedAsset = [selectedAsset copy];
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.scrollView setContentSize:CGSizeMake(320, 978)];
    self.signatureController = [[[SignatureViewController alloc] initWithNibName:@"SignatureView" bundle:nil] autorelease];
    self.signatureController.delegate = self;
    CGRect frame = self.signatureView.frame;
    frame.origin.y = frame.origin.y;
    self.signatureController.view.frame = frame;
    [self.scrollView insertSubview:self.signatureController.view belowSubview:self.signatureView];
    [self.signatureView removeFromSuperview];
    self.signatureView = self.signatureController.view;
    [self.signatureView setBackgroundColor:[UIColor whiteColor]];
    [super viewDidLoad];
    [self.descriptionLabel setText:[self.initialData objectForKey:@"description"]];
    [self.serialNumberLabel setText:[self.initialData objectForKey:@"serial_number"]];
    for (int i = 0; i<[[self.assetData objectForKey:@"assets"] count]; i++) {
        NSDictionary * tempDict = [[self.assetData objectForKey:@"assets"]objectAtIndex:i];
        if ([[tempDict objectForKey:@"id"] isEqualToString:self.selectedAsset]) {
            [self.assetIdLabel setText:[tempDict objectForKey:@"asset_id"]];
            [self.assetImageView setImageURL:[NSURL URLWithString:[tempDict objectForKey:@"asset_photo"]]];
            self.currentSelectedAssetPhoto = [tempDict objectForKey:@"asset_photo"];
            self.currentSelectedAssetId = [tempDict objectForKey:@"id"];
            break;
        }
    }
    
    [self.departmentLabel setText:[self.initialData objectForKey:@"department"]];
    [self.addressTextView setText:[self.initialData objectForKey:@"address"]];
    [self.dateTextField setText:[SharedManager stringFromDate:[NSDate date] withFormat:@"dd-MM-yyyy HH:mm"]];
    [self.dateTextField setEnabled:NO];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Pressed Events
-(IBAction)checkButtonPressed:(id)sender {
    [self.checkButton setSelected:!self.checkButton.selected];
}
- (IBAction)backButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)checkOutPressed:(id)sender {
    BOOL temp = FALSE;
    for (UIView * v in [self.scrollView subviews]) {
        if ([v isKindOfClass:[UITextField class]]) {
            if ([[(UITextField*)v text] length] == 0 ) {
                temp = TRUE;
                break;
            }
        }
    }
    if (temp) {
        UIAlertView * tempAlert = [[[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
        [tempAlert show];
    }
    else {
        if ([[self.notesTextView text] length] == 0) {
            UIAlertView * tempAlert = [[[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
            [tempAlert show];
        }
        else {
            if (self.checkButton.isSelected) {
                if (self.uploadedSignaturePath) {
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                    UserDTO *user=[[VSSharedManager sharedManager] currentUser];
                    [[WebServiceManager sharedManager]checkoutWithMasterKey:[NSString stringWithFormat:@"%d",user.masterKey] employee:[self.employeeTextField text] department:[self.departmentTextField text] date_time_out:[self.dateTextField text] date_time_due_in:[self.dueTextField text] client_id:self.currentSelectedClient reference:[self.referenceTextField text] address:[self.addressTextField text] notes:[self.notesTextView text] signature:self.uploadedSignaturePath asset_id:self.currentSelectedAssetId user_id:[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"] tolerance:[self.toleranceTextField text] withCompletionHandler:^(id data, BOOL error)
                     {
                         
                         
                         [SVProgressHUD dismiss];
                         if (!error) {
                             NSMutableDictionary * dict = [data mutableCopy];
                             NSMutableDictionary * tempDict = [NSMutableDictionary dictionary];
                             [tempDict setObject:[self.descriptionLabel text] forKey:@"desc"];
                             [tempDict setObject:[self.serialNumberLabel text] forKey:@"serial"];
                             [tempDict setObject:[self.assetIdLabel text] forKey:@"assetID"];
                             [tempDict setObject:[self.departmentLabel text] forKey:@"department"];
                             [tempDict setObject:[self.addressTextView text] forKey:@"address"];
                             [tempDict setObject:self.currentSelectedAssetPhoto forKey:@"photo"];
                             [tempDict setObject:[self.employeeTextField text] forKey:@"employee"];
                             NSString * temp = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ticket_id"]];
                             [tempDict setObject:[self.dueTextField text] forKey:@"return"];
                             [tempDict setObject:temp forKey:@"ticket_id"];
                             [self.navigationController pushViewController:[CheckOutConfirmationViewController initWithData:tempDict] animated:YES];
                             
                         }
                         
                         
                         
                     }];
                }
                else {
                    UIAlertView * tempAlert = [[[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please sign and press submit" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
                    [tempAlert show];
                }
            }
            else {
            UIAlertView * tempAlert = [[[UIAlertView alloc] initWithTitle:@"Attention" message:@"CheckBox not checked" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
                [tempAlert show];
            }
            
        }
    }
}

#pragma mark SignatureView Delegate

- (void) signatureViewController:(SignatureViewController *)viewController didSign:(NSData *)signature;
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    UserDTO *user=[[VSSharedManager sharedManager] currentUser];
    [[WebServiceManager sharedManager]uploadSignatureforCICOWithMasterKey:[NSString stringWithFormat:@"%d",user.masterKey] file:signature withCompletionHandler:^(id data, BOOL error)
     {
         
         
         [SVProgressHUD dismiss];
         if (!error) {
             self.uploadedSignaturePath = [data mutableCopy];
         }
         
         
         
     }];
//    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:thisSignature], nil, nil, nil);
//    self.signature = [UIImage imageWithData:thisSignature];
    //
    // Do something with thisSignature, like save it to a file or a database as binary data.
    //
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
    
    if ([textField isEqual:self.employeeTextField]) {
        UIPickerView * tempPicker = [[UIPickerView alloc]init];
        [tempPicker setTag:0];
        [tempPicker setDataSource:self];
        [tempPicker setDelegate:self];
        [textField setInputView:tempPicker];
    }
    if ([textField isEqual:self.departmentTextField]) {
        UIPickerView * tempPicker = [[UIPickerView alloc]init];
        [tempPicker setTag:1];
        [tempPicker setDataSource:self];
        [tempPicker setDelegate:self];
        [textField setInputView:tempPicker];
    }
    if ([textField isEqual:self.addressTextField]) {
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

#pragma mark UIPIcker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView tag] == 0) {
        return [[self.assetData objectForKey:@"employees"] count];
    }
    if ([pickerView tag] == 1) {
        return [[self.assetData objectForKey:@"departments"] count];
    }
    if ([pickerView tag] == 3) {
        return [[self.assetData objectForKey:@"addresses"] count];
    }
    if ([pickerView tag] == 4) {
        return [[self.assetData objectForKey:@"clients"] count];
    }
    else {
        return 0;
    }
    
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([pickerView tag] == 0) {
        return [[[self.assetData objectForKey:@"employees"] objectAtIndex:row] objectForKey:@"full_name"];
    }
    if ([pickerView tag] == 1) {
        return [[[self.assetData objectForKey:@"departments"] objectAtIndex:row] objectForKey:@"name"];
    }
    if ([pickerView tag] == 3) {
        return [[[self.assetData objectForKey:@"addresses"] objectAtIndex:row] objectForKey:@"address1"];
    }
    if ([pickerView tag] == 4) {
        return [[[self.assetData objectForKey:@"clients"] objectAtIndex:row] objectForKey:@"name"];
    }
    else {
        return nil;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView tag] == 0) {
        self.employeeTextField.text = [[[self.assetData objectForKey:@"employees"] objectAtIndex:row] objectForKey:@"full_name"];
    }
    if ([pickerView tag] == 1) {
        self.departmentTextField.text =  [[[self.assetData objectForKey:@"departments"] objectAtIndex:row] objectForKey:@"name"];   
    }
    if ([pickerView tag] == 3) {
        self.addressTextField.text =  [[[self.assetData objectForKey:@"addresses"] objectAtIndex:row] objectForKey:@"address1"];
    }
    if ([pickerView tag] == 4) {
        self.clientTextField.text =  [[[self.assetData objectForKey:@"clients"] objectAtIndex:row] objectForKey:@"name"];
        self.currentSelectedClient = [[[self.assetData objectForKey:@"clients"] objectAtIndex:row] objectForKey:@"id"];
    }
    
}

#pragma mark UiscrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint locationPoint = [scrollView.panGestureRecognizer locationInView:scrollView];
    CGPoint viewPoint = [self.signatureView convertPoint:locationPoint fromView:self.scrollView];
    if ([self.signatureView pointInside:viewPoint withEvent:nil]) {
        self.scrollView.scrollEnabled = NO;
        self.scrollView.scrollEnabled = YES;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    CGPoint viewPoint = [self.signatureView convertPoint:locationPoint fromView:self.view];
    if ([self.signatureView pointInside:viewPoint withEvent:event]) {
        self.scrollView.scrollEnabled = NO;
        self.scrollView.scrollEnabled = YES;
                    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    CGPoint viewPoint = [self.signatureView convertPoint:locationPoint fromView:self.view];
    if ([self.signatureView pointInside:viewPoint withEvent:event]) {
        self.scrollView.scrollEnabled = NO;
        self.scrollView.scrollEnabled = YES;
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    CGPoint viewPoint = [self.signatureView convertPoint:locationPoint fromView:self.view];
    if ([self.signatureView pointInside:viewPoint withEvent:event]) {
        self.scrollView.scrollEnabled = NO;
        self.scrollView.scrollEnabled = YES;
    }
}

@end
