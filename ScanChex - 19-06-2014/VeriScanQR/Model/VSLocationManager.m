//
//  VSLocationManager.m
//  VeriScanQR
//
//  Created by Adnan Ahmad on 23/12/2012.
//  Copyright (c) 2012 Adnan Ahmad. All rights reserved.
//

#import "VSLocationManager.h"
#import "WebServiceManager.h"
#import "UserDTO.h"
#import "VSSharedManager.h"
#import "Constant.h"
#import <sys/utsname.h>



#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface VSLocationManager()

@property (nonatomic, retain)CLLocationManager *manager;
//Threading//
@property (nonatomic) BOOL updaterStopped;
@property (nonatomic, retain) NSThread *updaterThread;

@end
@implementation VSLocationManager

@synthesize lastKnownLocation;
@synthesize manager;
@synthesize assetID=_assetID;

int locationUpdateInterval = 15;//5 mins

static VSLocationManager *sharedInstance;

//http://mobileoop.com/background-location-update-programming-for-ios-7

+(id)sharedManager{
    
    if(sharedInstance==nil)
    {
        
        sharedInstance= [[VSLocationManager alloc] init];
      
      
    }
    
    return sharedInstance;
    
}

-(void)startListening{
  
  
  NSLog(@"startListening");
    
    if(!self.manager)
    {
        self.manager= [[[CLLocationManager alloc] init] autorelease];
        self.manager.delegate=self;
        self.assetID=[[[NSString alloc] initWithString:@"0"] autorelease];
        //Set some parameters for the location object.
        [self.manager setDistanceFilter:kCLDistanceFilterNone];
        [self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.manager setHeadingFilter:kCLHeadingFilterNone];
        [self.manager setHeadingOrientation:CLDeviceOrientationUnknown];
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
      
    }
   
    if (([[[UIDevice currentDevice] systemVersion] floatValue]>=6.0)) {
        
        [self.manager setPausesLocationUpdatesAutomatically:NO];
    }
  
//  SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
//  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
//      [self.manager respondsToSelector:requestSelector]) {
//    ((void (*)(id, SEL))[self.manager methodForSelector:requestSelector])(self.manager, requestSelector);
//    [self.manager startUpdatingHeading];
//    [self.manager startUpdatingLocation];
//  } else {
//    [self.manager startUpdatingHeading];
//    [self.manager startUpdatingLocation];
//  }
    //[self.manager startUpdatingHeading];
    //[self.manager startUpdatingLocation];
  
  if ([CLLocationManager locationServicesEnabled] == NO) {
    NSLog(@"locationServicesEnabled false");
    UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [servicesDisabledAlert show];
  } else {
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    
    if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
      NSLog(@"authorizationStatus failed");
    } else {
      NSLog(@"authorizationStatus authorized");
//      CLLocationManager *locationManager = [VSLocationManager sharedManager];
//      locationManager.delegate = self;
//      locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//      locationManager.distanceFilter = kCLDistanceFilterNone;
//      
      if(IS_OS_8_OR_LATER) {
        [self.manager requestAlwaysAuthorization];
      }
      [self.manager startUpdatingHeading];
      [self.manager startUpdatingLocation];
    }
  }

  
}

//////For Signification Location Updation////

-(void)startListeningWithSignificantChanges{
    
    if(!self.manager){
        
        self.manager= [[[CLLocationManager alloc] init] autorelease];
        self.manager.delegate=self;
        //Set some parameters for the location object.
        [self.manager setDistanceFilter:kCLDistanceFilterNone];
        [self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        if (([[[UIDevice currentDevice] systemVersion] floatValue]>=6.0)) {
            
            [self.manager setPausesLocationUpdatesAutomatically:NO];
        }
        
    }
    [self.manager startMonitoringSignificantLocationChanges];
}

-(void)stopListeningWithSignificationChanges{
    
    [self.manager stopMonitoringSignificantLocationChanges];
}

-(void)stopListening{
    
 
  NSLog(@"stopListening");
  
  if (self.shareModel.timer) {
    [self.shareModel.timer invalidate];
    self.shareModel.timer = nil;
  }
  
  [self.manager stopUpdatingHeading];
  [self.manager stopUpdatingLocation];
  
  
}


-(CLLocation *)currentLocation{
    
    if(!self.lastKnownLocation){
        
        self.lastKnownLocation = [self.manager location];
    }
    
    return self.lastKnownLocation;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
{
  
    NSLog(@"didUpdateToLocation");
  
    self.lastKnownLocation = newLocation;
    
    NSDate *newLocationTimestamp = newLocation.timestamp;
    NSDate *lastLocationUpdateTiemstamp;
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
    if (userDefaults) {
        
        lastLocationUpdateTiemstamp = [userDefaults objectForKey:kLastLocationUpdateTimestamp];
        
        if (!([newLocationTimestamp timeIntervalSinceDate:lastLocationUpdateTiemstamp] < locationUpdateInterval)) {
            //NSLog(@"New Location: %@", newLocation);
            

            [self performSelector:@selector(updateLocationToServer) withObject:nil];
            [userDefaults setObject:newLocationTimestamp forKey:kLastLocationUpdateTimestamp];
            [userDefaults synchronize];
        }
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
  
 // NSLog(@"didUpdateLocations");
  

  
    self.lastKnownLocation = [locations lastObject];
    
    NSDate *newLocationTimestamp = self.lastKnownLocation.timestamp;
    NSDate *lastLocationUpdateTiemstamp;
    
    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults) {
        
        lastLocationUpdateTiemstamp = [userDefaults objectForKey:kLastLocationUpdateTimestamp];
        
        if (!([newLocationTimestamp timeIntervalSinceDate:lastLocationUpdateTiemstamp] < locationUpdateInterval)) {
            
            [self performSelector:@selector(updateLocationToServer) withObject:nil];
            [userDefaults setObject:newLocationTimestamp forKey:kLastLocationUpdateTimestamp];
            [userDefaults synchronize];
        }
    }
  
//  //Restart the locationMaanger after 1 minute
//  self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self
//                                                         selector:@selector(restartLocationUpdates)
//                                                         userInfo:nil
//                                                          repeats:NO];
//  
//  //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
//  //The location manager will only operate for 10 seconds to save battery
//  if (self.shareModel.delay10Seconds) {
//    [self.shareModel.delay10Seconds invalidate];
//    self.shareModel.delay10Seconds = nil;
//  }
//  
//  self.shareModel.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:10 target:self
//                                                                  selector:@selector(stopLocationDelayBy10Seconds)
//                                                                  userInfo:nil
//                                                                   repeats:NO];


    
}

-(void)applicationEnterBackground{
//    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    locationManager.distanceFilter = kCLDistanceFilterNone;
//    [locationManager startUpdatingLocation];
  
  
//  CLLocationManager *locationManager = [VSLocationManager sharedManager];
//  locationManager.delegate = self;
//  locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//  locationManager.distanceFilter = kCLDistanceFilterNone;
  
  if(IS_OS_8_OR_LATER) {
    [self.manager requestAlwaysAuthorization];
  }
  [self.manager startUpdatingLocation];
  
    //Use the BackgroundTaskManager to manage all the background Task
    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
}

- (void) restartLocationUpdates
{
  NSLog(@"restartLocationUpdates");
  
  if (self.shareModel.timer) {
    [self.shareModel.timer invalidate];
    self.shareModel.timer = nil;
  }
  
//  CLLocationManager *locationManager = [VSSharedManager sharedManager];
//  locationManager.delegate = self;
//  locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//  locationManager.distanceFilter = kCLDistanceFilterNone;
  
  if(IS_OS_8_OR_LATER) {
    [self.manager requestAlwaysAuthorization];
  }
  [self.manager startUpdatingLocation];
}



-(void)updateLocationToServer{
  
  NSLog(@"updateLocationToServer");
  

  
    CLLocation *lasKnownLocation= self.lastKnownLocation;
    UserDTO *user=[[VSSharedManager sharedManager] currentUser];
  
  // NSString *currentspeed = [[NSString alloc] initWithFormat:@"%.2f m per sec", (lasKnownLocation.speed * 3.6f * 0.278f)];
  
    NSString *currentspeed = [[NSString alloc] initWithFormat:@"%.2f", (lasKnownLocation.speed * 3.6f * 0.278f)];
    NSLog(@" Speed %@",currentspeed);
  
    [[WebServiceManager sharedManager] updateLocation:[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]
                                            masterKey:[NSString stringWithFormat:@"%d", user.masterKey]
                                              assetId:self.assetID
                                           deviceMake:@"Apple"
                                          deviceModel:machineName()
                                             deviceOS:[[UIDevice currentDevice] systemVersion]
                                             deviceID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                             latitude:[NSString stringWithFormat:@"%.7f",lasKnownLocation.coordinate.latitude]
                                            longitude:[NSString stringWithFormat:@"%.7f",lasKnownLocation.coordinate.longitude]
                                                speed:currentspeed
                                        batteryStatus:[NSString stringWithFormat:@"%.2f",(float) [[UIDevice currentDevice] batteryLevel] * -100 ]
                                withCompletionHandler:^(id data, BOOL error){
                                            
                                                if (!error) {
                                                    
                                                    DLog(@"%@",@"Location Updated");
                                                }else{
                                                    
                                                    DLog(@"%@",@"Failed");
                                                }

                                            }];

}



- (void)startUpdating{
    
    /*if already running*/
    if(!self.updaterStopped){
        [self.updaterThread cancel];
    }
    
    
    self.updaterStopped=NO;
    self.updaterThread= [[NSThread alloc] initWithTarget:self selector:@selector(updateLocation) object:nil];
    [self.updaterThread start];
    
    
    
}
- (void)stopUpdating{
    
    self.updaterStopped=YES;
    [self.updaterThread cancel];
    
}


- (void)requestUpdates{
    
    [self stopUpdating];
    [self startUpdating];
    
}

- (void)updateLocation{
    
    
    @autoreleasepool {
        
       
        [self startListening];
        
        //wait here
        [NSThread sleepForTimeInterval:kUPDATE_INTERVAL];
        
        
        //check if we have been stoped
        if([[NSThread currentThread] isCancelled] || self.updaterStopped){
            return ;
        }
        
        //else spawn again
        [self startUpdating];
        
    }
    
}

//Stop the locationManager
-(void)stopLocationDelayBy10Seconds{
//  CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
  [self.manager stopUpdatingLocation];
  
  NSLog(@"locationManager stop Updating after 10 seconds");
}


- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
  // NSLog(@"locationManager error:%@",error);
  
  switch([error code])
  {
    case kCLErrorNetwork: // general, network-related error
    {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
      [alert show];
    }
      break;
    case kCLErrorDenied:{
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
      [alert show];
    }
      break;
    default:
    {
      
    }
      break;
  }
}
NSString* machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}


-(void)dealloc{
  
   // DLog(@"%@ dealloced", NSStringFromClass([self class]));
    [manager release];
    [lastKnownLocation release];
    [super dealloc];
}

@end
