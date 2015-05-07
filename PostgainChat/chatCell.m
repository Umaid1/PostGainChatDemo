//
//  PostGainChatViewController.h
//  PostgainChat
//
//  Created by Umaid Saleem on 5/7/15.
//  Copyright (c) 2015 Umaid Saleem. All rights reserved.
//

#import "chatCell.h"

@implementation chatCell
@synthesize userLabel, timeLabel, textString, thumbnailImageView;


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

@end
