//
//  DocumentDTO.h
//  VeriScanQR
//
//  Created by Adnan Ahmad on 09/01/2013.
//  Copyright (c) 2013 Adnan Ahmad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDTO.h"
@interface DocumentDTO : BaseDTO

@property(nonatomic,retain) NSString *subject;
@property(nonatomic,retain) NSString *link;
@property(nonatomic,retain) NSString *document_id;
@property(nonatomic,retain) NSString *status;
@property(nonatomic,retain) NSString *version;

+(id)initWithDocument:(NSDictionary *)document;
@end
