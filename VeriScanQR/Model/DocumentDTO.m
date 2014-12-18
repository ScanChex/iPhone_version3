//
//  DocumentDTO.m
//  VeriScanQR
//
//  Created by Adnan Ahmad on 09/01/2013.
//  Copyright (c) 2013 Adnan Ahmad. All rights reserved.
//

#import "DocumentDTO.h"

@implementation DocumentDTO

@synthesize subject=_subject;
@synthesize link=_link;
@synthesize document_id=_document_id;
@synthesize status=_status;
@synthesize version=_version;

+(id)initWithDocument:(NSDictionary *)document{

    return [[[self alloc] initWithDictionary:document] autorelease];
}

-(void)updateWithDictionary:(NSDictionary *)dictionary{

    self.subject=[dictionary objectForKey:@"subject"];
    self.link=[dictionary objectForKey:@"link"];
    self.document_id=[dictionary objectForKey:@"document_id"];
    self.status=[dictionary objectForKey:@"status"];
    self.version=[dictionary objectForKey:@"version"];



}
-(void)dealloc{

    [_subject release];
    [_link release];
    [_document_id release];
    [_status release];
    [_version release];
    [super dealloc];
}
@end
