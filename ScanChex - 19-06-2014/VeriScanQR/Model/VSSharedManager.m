//
//  VSSharedManager.m
//  VeriScanQR
//
//  Created by Adnan Ahmad on 16/12/2012.
//  Copyright (c) 2012 Adnan Ahmad. All rights reserved.
//

#import "VSSharedManager.h"

@implementation VSSharedManager

@synthesize currentUser=_currentUser;
@synthesize ticketInfo=_ticketInfo;
@synthesize selectedTicket=_selectedTicket;
@synthesize selectedTicketInfo=_selectedTicketInfo;
@synthesize userName=_userName;
@synthesize historyID=_historyID;
@synthesize CurrentSelectedSection = _CurrentSelectedSection;
@synthesize CurrentSelectedIndex = _CurrentSelectedIndex;

static VSSharedManager *sharedInstance;

+(id)sharedManager{
    
    if(sharedInstance==nil){
        
        sharedInstance= [[VSSharedManager alloc] init];
        
        
    }
    return sharedInstance;
}
@end
