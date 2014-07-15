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

int locationUpdateInterval = 300;//5 mins

static VSLocationManager *sharedInstance;



+(id)sharedManager{
    
    if(sharedInstance==nil)
    {
        
        sharedInstance= [[VSLocationManager alloc] init];
        
    }
    
    return sharedInstance;
    
}

-(void)startListening{
    
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
    }
   
    if (([[[UIDevice currentDevice] systemVersion] floatValue]>=6.0)) {
        
        [self.manager setPausesLocationUpdatesAutomatically:NO];
    }
    [self.manager startUpdatingHeading];
    [self.manager startUpdatingLocation];
    
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

    
}

-(void)applicationEnterBackground{
//    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    locationManager.distanceFilter = kCLDistanceFilterNone;
//    [locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
}


-(void)updateLocationToServer{

    
    CLLocation *lasKnownLocation= self.lastKnownLocation;
    UserDTO *user=[[VSSharedManager sharedManager] currentUser];
    
   
    [[WebServiceManager sharedManager] updateLocation:[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]
                                            masterKey:[NSString stringWithFormat:@"%d", user.masterKey]
                                              assetId:self.assetID
                                           deviceMake:@"Apple"
                                          deviceModel:[[UIDevice currentDevice] platformString]
                                             deviceOS:[[UIDevice currentDevice] systemVersion]
                                             deviceID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                             latitude:[NSString stringWithFormat:@"%.7f",lasKnownLocation.coordinate.latitude]
                                            longitude:[NSString stringWithFormat:@"%.7f",lasKnownLocation.coordinate.longitude]
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

-(void)dealloc{
    
   // DLog(@"%@ dealloced", NSStringFromClass([self class]));
    [manager release];
    [lastKnownLocation release];
    [super dealloc];
}

@end
