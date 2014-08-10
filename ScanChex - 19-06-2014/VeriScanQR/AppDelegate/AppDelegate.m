//
//  AppDelegate.m
//  VeriScanQR
//
//  Created by Adnan Ahmad on 12/12/2012.
//  Copyright (c) 2012 Adnan Ahmad. All rights reserved.
//

#import "AppDelegate.h"
#import "SplashVC.h"
#import "VSLocationManager.h"
#import "Flurry.h"
#import "MessageCentreVC.h"
@implementation AppDelegate
@synthesize navController;

- (void)dealloc
{
    [navController release];
    [_window release];
    [_viewController release];
    [super dealloc];
}

+(id)sharedDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[SharedManager getInstance] setIsMessage:FALSE];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"color"]) {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor blackColor]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"color"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
   
    [Flurry setCrashReportingEnabled:YES];
    [Flurry setAppVersion:@"1.0"];
    [Flurry startSession:@"Z55KW4WFBHXS3FZ8DV6G"];
    
    self.viewController = [SplashVC initWithSplash];
    navController=[[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    navController.navigationBarHidden=YES;
    navController.navigationBar.translucent = NO;
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    UIFont *Boldfont = [UIFont boldSystemFontOfSize:10.0f];
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:11.0f]];
//    NSDictionary *attributes = [NSDictionary dictionaryWithObject:Boldfont forKey:UITextAttributeFont];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSFontAttributeName : Boldfont
                                                              } forState:UIControlStateNormal];
    
    //    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@",deviceTK] forKey:@"apns_device_token"];

    DLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"apns_device_token"]);
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //clear notifications
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if (launchOptions != nil)
	{
		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
            [[SharedManager getInstance] setIsMessage:TRUE];
			NSLog(@"Launched from push notification: %@", dictionary);
			
            ///Handle PushNotificaiton Thing here 
		}
	}
    #if TARGET_IPHONE_SIMULATOR
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@",@"na"] forKey:@"apns_device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    #endif
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *deviceTK=[NSString stringWithFormat:@"%@",deviceToken];
    deviceTK=[deviceTK stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTK=[deviceTK stringByReplacingOccurrencesOfString:@">" withString:@""];
    deviceTK=[deviceTK stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"deviceTk %@",deviceTK);
//    UIAlertView * tempAlert = [[UIAlertView alloc] initWithTitle:@"DeviceToken" message:deviceTK delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [tempAlert show];
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@",deviceTK] forKey:@"apns_device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        //opened from a push notification when the app was on background
        [application setApplicationIconBadgeNumber:application.applicationIconBadgeNumber+1];
        [[SharedManager getInstance] setIsMessage:TRUE];
        
    }
    else if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        //opened from a push notification when the app was in foreground
        [application setApplicationIconBadgeNumber:0];
        [[SharedManager getInstance] setIsMessage:TRUE];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPushReceived object:nil];
       
    }
    
    UIAlertView * tempAlert = [[[UIAlertView alloc]initWithTitle:@"New Message" message:@"Press OK to view message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] autorelease];
    [tempAlert setTag:-922];
    [tempAlert show];
    
//    UIAlertView *alert =[[[UIAlertView alloc] initWithTitle:@"PushNotification Works"
//                                                    message:[userInfo objectForKey:@"data"]
//                                                   delegate:nil
//                                          cancelButtonTitle:@"Ok"
//                                          otherButtonTitles:nil] autorelease];
//    [alert show];
   
        
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView tag] == -922) {
        if (buttonIndex == 1) {
            [[SharedManager getInstance] setIsMessage:FALSE];
            
            UINavigationController * tempController = (UINavigationController*)self.window.rootViewController;
            if ([[tempController viewControllers] count]>2) {
                [tempController pushViewController:[MessageCentreVC initWithMessageCentre] animated:YES];
            }
            else {
                UIAlertView * tempAlert = [[[UIAlertView alloc]initWithTitle:@"Error" message:@"You must Login to view your messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
                [tempAlert setTag:-922];
                [tempAlert show];
            }
            
        }
        
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    UIBackgroundTaskIdentifier myLongTask;
    
    myLongTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    }];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

@end
