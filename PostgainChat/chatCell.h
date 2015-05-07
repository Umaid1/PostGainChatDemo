//
//  PostGainChatViewController.h
//  PostgainChat
//
//  Created by Umaid Saleem on 5/7/15.
//  Copyright (c) 2015 Umaid Saleem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface chatCell : UITableViewCell
{
    UILabel *userLabel;
	UITextView *textString;
	UILabel *timeLabel;
    PFImageView *thumbnailImageView;
}

@property (nonatomic,strong) IBOutlet UILabel *userLabel;
@property (nonatomic,strong) IBOutlet UITextView *textString;
@property (nonatomic,strong) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet PFImageView *thumbnailImageView;

@end
