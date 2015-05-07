//
//  PostGainChatViewController.h
//  PostgainChat
//
//  Created by Umaid Saleem on 5/7/15.
//  Copyright (c) 2015 Umaid Saleem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "chatCell.h"
#import "Reachability.h"

@interface PostGainChatViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource,PF_EGORefreshTableHeaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    
    NSMutableArray          *chatData;
    PF_EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL                    _reloading;
    NSString                *className;
    NSString                *userName;
    
    UIImage             *chatImage;
}

@property (weak, nonatomic) IBOutlet UITextField *tfEntry;
@property (weak, nonatomic) IBOutlet UITableView *chatTable;
@property (strong, nonatomic) NSMutableArray *chatData;
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet UIImageView *textBoxImg;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property  (strong, nonatomic) UIImage *chatImage;


-(void) registerForKeyboardNotifications;
-(void) freeKeyboardNotifications;
-(void) keyboardWasShown:(NSNotification*)aNotification;
-(void) keyboardWillHide:(NSNotification*)aNotification;

- (void)loadLocalChat;

- (NSString *)stringFromStatus:(NetworkStatus )status;
-(void)presentChatNameDialog;


@end
