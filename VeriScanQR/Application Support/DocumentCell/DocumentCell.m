//
//  DocumentCell.m
//  VeriScanQR
//
//  Created by Adnan Ahmad on 09/01/2013.
//  Copyright (c) 2013 Adnan Ahmad. All rights reserved.
//

#import "DocumentCell.h"
#import "CustomCellHelper.h"
@implementation DocumentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+(DocumentCell *)resuableCellForTableView:(UITableView *)tableview withOwner:(UIViewController *)owner{

    static NSString *identifer= @"DocumentCell";
    DocumentCell *cell = (DocumentCell *)[CustomCellHelper tableView:tableview cellWithIdentifier:identifer owner:owner];
    return cell;

}
-(void)updateCellWithDocument:(DocumentDTO *)ticket{
  
  if (ticket.subject == nil || [ticket.subject isKindOfClass:[NSNull class]]) {
    self.subject.text=@"";
  } else {
  

    self.subject.text=ticket.subject;
  }
  
  if (ticket.status == nil || [ticket.status isKindOfClass:[NSNull class]]) {
    self.status.text=@"";
  }else if
    ( [ticket.status isEqualToString:@"hold"]) {
      self.status.text=  @"(Hold)";
      self.imagetype.image = [UIImage imageNamed:@"pdfonhold.png"];
    }
    self.backgroundColor=[UIColor clearColor];
}

- (void)dealloc {
    [_subject release];
    [super dealloc];
}
@end
