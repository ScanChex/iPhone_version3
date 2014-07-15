//
//  UserDTO.m
//  VeriScanQR
//
//  Created by Adnan Ahmad on 16/12/2012.
//  Copyright (c) 2012 Adnan Ahmad. All rights reserved.
//

#import "UserDTO.h"

@implementation UserDTO


@synthesize name=_name;
@synthesize logo=_logo;
@synthesize masterKey=_masterKey;
@synthesize exist=_exist;
@synthesize messageList=_messageList;
@synthesize levelID=_levelID;
@synthesize company_user = _company_user;
@synthesize employee_card_id = _employee_card_id;
+(id)userWithDictionary:(NSDictionary *)dictionary{

    return [[[self alloc] initWithDictionary:dictionary] autorelease];
}
-(void)updateWithDictionary:(NSDictionary *)dict{

    self.name=[dict valueForKey:@"full_name"];
    self.logo=[dict valueForKey:@"logo"];
    self.masterKey=[[dict valueForKey:@"master_key"] intValue];
    self.exist=[[dict valueForKey:@"exist"] intValue];
    self.messageList=[NSArray arrayWithArray:[dict valueForKey:@"msg"]];
    self.levelID=[dict valueForKey:@"level_id"];
    self.company_user = [dict valueForKey:@"company_user"];
    self.employee_card_id = [dict valueForKey:@"employee_card_id"];
    
}

-(void)dealloc{

    [self.name release];
    [self.logo release];
    [self.messageList release];
    [self.company_user release];
    
    [super dealloc];
}
@end
