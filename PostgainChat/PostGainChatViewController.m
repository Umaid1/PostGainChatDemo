//
//  PostGainChatViewController.m
//  PostgainChat
//
//  Created by Umaid Saleem on 5/7/15.
//  Copyright (c) 2015 Umaid Saleem. All rights reserved.
//

#import "PostGainChatViewController.h"

#define NAVIGATIONBAR_HEIGHT 44.0f
#define TEXTFIELD_HEIGHT 70.0f
#define MAX_ENTRIES_LOADED 25

@interface PostGainChatViewController ()

@end

@implementation PostGainChatViewController
@synthesize chatData;
@synthesize chatImage;

BOOL isShowingAlertView = NO;
BOOL isFirstShown = YES;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Real IM";
    self.bgImg.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    self.textBoxImg.frame = CGRectMake(0.0, 519.0, self.view.frame.size.width, 49.0);
    self.chatTable.frame = CGRectMake(0.0, 65.0, self.view.frame.size.width, 455.0);
        
    self.tfEntry.delegate = self;
    self.tfEntry.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self registerForKeyboardNotifications];
    if (_refreshHeaderView == nil) {
        
        PF_EGORefreshTableHeaderView *view = [[PF_EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.chatTable.bounds.size.height, self.view.frame.size.width, self.chatTable.bounds.size.height)];
        view.delegate = self;
        [self.chatTable addSubview:view];
        _refreshHeaderView = view;
    }
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
    UIButton *camBtn = [[UIButton alloc] init];
    camBtn.frame=CGRectMake(0,0,40,30);
    [camBtn setBackgroundImage:[UIImage imageNamed:@"camera_icon.png"] forState:UIControlStateNormal];
    [camBtn addTarget:self action:@selector(TakeSitePicture) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:camBtn];
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Device has no camera"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil];
                [myAlertView show];
    }
    
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 568) {
        self.textBoxImg.frame = CGRectMake(0.0, 519.0, self.view.frame.size.width, 49.0);
        self.tfEntry.frame = CGRectMake(13.0, 528.0, 230, 30.0);
        self.sendBtn.frame = CGRectMake(254, 526.0, 62.0, 34.0);
    }
    else if ((int)[[UIScreen mainScreen] bounds].size.height > 568) {
        
        self.textBoxImg.frame = CGRectMake(0.0, 519.0+20, self.view.frame.size.width, 49.0);
        self.tfEntry.frame = CGRectMake(13.0, 528.0+20.0, 230, 30.0);
        self.sendBtn.frame = CGRectMake(254, 526.0+20.0, 62.0, 34.0);
    }
    
    
}


- (void) TakeSitePicture
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
     }
    else {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
    }
}


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    if (chosenImage) {
        self.chatImage = chosenImage;
        UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil);
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network"
                                                        message:[self stringFromStatus: status]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    className = @"chatroom";
    //userName = @"Umaid Saleem";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userName = [defaults stringForKey:@"chatName"];
    if ([userName isEqualToString:@"Chat Name"]) {
        [self presentChatNameDialog];
    }
    chatData  = [[NSMutableArray alloc] init];
    [self loadLocalChat];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

#pragma mark - Chat textfield

-(IBAction) textFieldDoneEditing : (id) sender
{
    NSLog(@"the text content%@",self.tfEntry.text);
    [sender resignFirstResponder];
    [self.tfEntry resignFirstResponder];
}

-(IBAction) backgroundTap:(id) sender
{
    [self.tfEntry resignFirstResponder];
    
    [self postChatDataToServer];
}


- (void) postChatDataToServer {
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 568) {
        self.textBoxImg.frame = CGRectMake(0.0, 519.0, self.view.frame.size.width, 49.0);
        self.tfEntry.frame = CGRectMake(13.0, 528.0, 230, 30.0);
        self.sendBtn.frame = CGRectMake(254, 526.0, 62.0, 34.0);
    }
    else if ((int)[[UIScreen mainScreen] bounds].size.height > 568) {
        
        self.textBoxImg.frame = CGRectMake(0.0, 519.0+20, self.view.frame.size.width, 49.0);
        self.tfEntry.frame = CGRectMake(13.0, 528.0+20.0, 230, 30.0);
        self.sendBtn.frame = CGRectMake(254, 526.0+20.0, 62.0, 34.0);
        
    }
    
    
    
    if (self.tfEntry.text.length>0) {
        // updating the table immediately
        NSArray *keys = [NSArray arrayWithObjects:@"text", @"userName", @"date", nil];
        NSArray *objects = [NSArray arrayWithObjects:self.tfEntry.text, userName, [NSDate date], nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [chatData addObject:dictionary];
        
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [insertIndexPaths addObject:newPath];
        [self.chatTable beginUpdates];
        [self.chatTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.chatTable endUpdates];
        [self.chatTable reloadData];
        
        if (self.chatImage) {
            
            // Convert to JPEG with 50% quality
            NSData* data = UIImageJPEGRepresentation(self.chatImage, 0.5f);
            PFFile *imageFile = [PFFile fileWithName:@"PostGainImage.png" data:data];
            
            // Save the image to Parse
            
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    // going for the parsing
                    PFObject *newMessage = [PFObject objectWithClassName:@"chatroom"];
                    [newMessage setObject:self.tfEntry.text forKey:@"text"];
                    [newMessage setObject:userName forKey:@"userName"];
                    [newMessage setObject:[NSDate date] forKey:@"date"];
                    [newMessage setObject:imageFile forKey:@"imageFile"];
                    [newMessage saveInBackground];
                    self.tfEntry.text = @"";
                    
                    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error)
                            NSLog(@"Saved");
                        else
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }];
                } else {
                    
                    // going for the parsing
                    PFObject *newMessage = [PFObject objectWithClassName:@"chatroom"];
                    [newMessage setObject:self.tfEntry.text forKey:@"text"];
                    [newMessage setObject:userName forKey:@"userName"];
                    [newMessage setObject:[NSDate date] forKey:@"date"];
                    [newMessage setObject:@"" forKey:@"imageFile"];
                    [newMessage saveInBackground];
                    self.tfEntry.text = @"";
                }
            }];
        }
        else {
            
            NSData* data = UIImageJPEGRepresentation([UIImage imageNamed:@""], 0.5f);              ////  Test Code can be deleted later  as Simulator has no camera
            PFFile *imageFile = [PFFile fileWithName:@"PostGainImage.png" data:data];
            
            // going for the parsing
            PFObject *newMessage = [PFObject objectWithClassName:@"chatroom"];
            [newMessage setObject:self.tfEntry.text forKey:@"text"];
            [newMessage setObject:userName forKey:@"userName"];
            [newMessage setObject:[NSDate date] forKey:@"date"];
            [newMessage setObject:imageFile forKey:@"imageFile"];
            [newMessage saveInBackground];
            self.tfEntry.text = @"";
        }
        
    }
    
    // reload the data
    [self loadLocalChat];
    
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"the text content%@",self.tfEntry.text);
    [textField resignFirstResponder];
    
    [self postChatDataToServer];
    
    return NO;
}


-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void) freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void) keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    NSDictionary* info = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    // Move
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    NSLog(@"frame..%f..%f..%f..%f",self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"keyboard..%f..%f..%f..%f",keyboardFrame.origin.x, keyboardFrame.origin.y, keyboardFrame.size.width, keyboardFrame.size.height);
    
    //[self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y- keyboardFrame.size.height+NAVIGATIONBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    //[chatTable setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+ keyboardFrame.size.height+TEXTFIELD_HEIGHT+NAVIGATIONBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-keyboardFrame.size.height)];
    
    [self.view setFrame:CGRectMake(0.0, -209.0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.chatTable setFrame:CGRectMake(self.view.frame.origin.x, 158.0, self.view.frame.size.width, 315.0)];
    
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 568) {
         self.textBoxImg.frame = CGRectMake(0.0, 82+NAVIGATIONBAR_HEIGHT+self.view.frame.size.height-keyboardFrame.size.height, self.view.frame.size.width, 49.0);
        self.tfEntry.frame = CGRectMake(13.0, 88+NAVIGATIONBAR_HEIGHT+self.view.frame.size.height-keyboardFrame.size.height, 230, 30.0);
        self.sendBtn.frame = CGRectMake(254, 88+NAVIGATIONBAR_HEIGHT+self.view.frame.size.height-keyboardFrame.size.height, 62.0, 34.0);
    }
    else if ((int)[[UIScreen mainScreen] bounds].size.height > 568) {
        
        self.textBoxImg.frame = CGRectMake(0.0, 20+82+NAVIGATIONBAR_HEIGHT+self.view.frame.size.height-keyboardFrame.size.height, self.view.frame.size.width, 49.0);
        self.tfEntry.frame = CGRectMake(13.0, 20+88+NAVIGATIONBAR_HEIGHT+self.view.frame.size.height-keyboardFrame.size.height, 230, 30.0);
        self.sendBtn.frame = CGRectMake(254, 20+88+NAVIGATIONBAR_HEIGHT+self.view.frame.size.height-keyboardFrame.size.height, 62.0, 34.0);
    }
    
    
    
    [self.chatTable scrollsToTop];
    [UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification*)aNotification
{
    NSLog(@"Keyboard will hide");
    NSDictionary* info = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    // Move
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //[self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height-NAVIGATIONBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    //[chatTable setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-NAVIGATIONBAR_HEIGHT)];
    
    [self.view setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.chatTable setFrame:CGRectMake(0.0, 64.0, self.view.frame.size.width, 456.0)];
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 568) {
        self.textBoxImg.frame = CGRectMake(0.0, 519.0, self.view.frame.size.width, 49.0);
        self.tfEntry.frame = CGRectMake(13.0, 528.0, 230, 30.0);
        self.sendBtn.frame = CGRectMake(254, 526.0, 62.0, 34.0);
    }
    else if ((int)[[UIScreen mainScreen] bounds].size.height > 568) {
        
        self.textBoxImg.frame = CGRectMake(0.0, 519.0+20, self.view.frame.size.width, 49.0);
        self.tfEntry.frame = CGRectMake(13.0, 528.0+20.0, 230, 30.0);
        self.sendBtn.frame = CGRectMake(254, 526.0+20.0, 62.0, 34.0);
    }
    
    
    [UIView commitAnimations];
    
    
}

#pragma mark - Parse

- (void)loadLocalChat
{
    PFQuery *query = [PFQuery queryWithClassName:className];
    
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([chatData count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query orderByAscending:@"createdAt"];
        NSLog(@"Trying to retrieve from cache");
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d chats from cache.", (int)objects.count);
                [chatData removeAllObjects];
                [chatData addObjectsFromArray:objects];
                [self.chatTable reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    else {
        
        __block int totalNumberOfEntries = 0;
        [query orderByAscending:@"createdAt"];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                // The count request succeeded. Log the count
                NSLog(@"There are currently %d entries", number);
                totalNumberOfEntries = number;
                if (totalNumberOfEntries > [chatData count]) {
                    NSLog(@"Retrieving data");
                    int theLimit;
                    if (totalNumberOfEntries-[chatData count]>MAX_ENTRIES_LOADED) {
                        theLimit = MAX_ENTRIES_LOADED;
                    }
                    else {
                        theLimit = totalNumberOfEntries -(int)[chatData count];
                    }
                    query.limit = (NSInteger)[NSNumber numberWithInt:theLimit];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            // The find succeeded.
                            NSLog(@"Successfully retrieved %d chats.", (int)objects.count);
                            [chatData addObjectsFromArray:objects];
                            NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                            for (int ind = 0; ind < objects.count; ind++) {
                                NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                                [insertIndexPaths addObject:newPath];
                            }
                            [self.chatTable beginUpdates];
                            [self.chatTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                            [self.chatTable endUpdates];
                            [self.chatTable reloadData];
                            [self.chatTable scrollsToTop];
                        } else {
                            // Log details of the failure
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                }
                
            } else {
                // The request failed, we'll keep the chatData count?
                number = (int)[chatData count];
            }
        }];
    }
    
}


#pragma mark - Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chatData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    chatCell *cell = (chatCell *)[tableView dequeueReusableCellWithIdentifier: @"chatCellIdentifier"];
    NSUInteger row = [chatData count]-[indexPath row]-1;
    
    if (row < chatData.count){
        NSString *chatText = [[chatData objectAtIndex:row] objectForKey:@"text"];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize size = [chatText sizeWithFont:font constrainedToSize:CGSizeMake(225.0f, 1000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
        cell.textString.frame = CGRectMake(85, 14, size.width +20, size.height + 20);
        cell.textString.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        cell.textString.textColor = [UIColor blackColor];
        cell.textString.text = chatText;
        [cell.textString sizeToFit];
        
        
        // Configure the cell
        
        NSDictionary *dict = [chatData objectAtIndex:row];
        NSLog(@"Dict %@",dict);
        
        cell.thumbnailImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
        
        if ([dict objectForKey:@"imageFile"]) {
            
            if (dict != [NSNull class]) {
                
                PFFile *thumbnail = [[chatData objectAtIndex:row] objectForKey:@"imageFile"];

                    if ([thumbnail isDataAvailable]) {
                        cell.thumbnailImageView.file = thumbnail;
                        [cell.thumbnailImageView loadInBackground];
                    }
            }
            
        }
        
        NSDate *theDate = [[chatData objectAtIndex:row] objectForKey:@"date"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        NSString *timeString = [formatter stringFromDate:theDate];
        cell.timeLabel.text = timeString;
        
        cell.userLabel.text = [[chatData objectAtIndex:row] objectForKey:@"userName"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [[chatData objectAtIndex:chatData.count-indexPath.row-1] objectForKey:@"text"];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 80;
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    _reloading = YES;
    [self loadLocalChat];
    [self.chatTable reloadData];
}

- (void)doneLoadingTableViewData{
    
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.chatTable];
    
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(PF_EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(PF_EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(PF_EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark - Connections

- (NSString *)stringFromStatus:(NetworkStatus ) status {
    NSString *string; switch(status) {
        case NotReachable:
            string = @"You are not connected to the internet";
            break;
        case ReachableViaWiFi:
            string = @"Reachable via WiFi";
            break;
        case ReachableViaWWAN:
            string = @"Reachable via WWAN";
            break;
        default:
            string = @"Unknown connection";
            break;
    }
    return string;
}

#pragma mark - Chat name dialog

-(void)presentChatNameDialog
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Chat Name"
                                                      message:@"Choose a chat name, it can be changed later from Parse server"
                                                     delegate:self
                                            cancelButtonTitle:@"Dismiss"
                                            otherButtonTitles:@"Confirm", nil];
    
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    //    [message setBackgroundColor:[UIColor colorWithRed:0.7765f green:0.1725f blue:0.1451f alpha:1.0f]];
    //    [message setAlpha:0.8f];
    [message show];
    isShowingAlertView = YES;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Alert View dismissed with button at index %d",(int)buttonIndex);
    if (buttonIndex != 0) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSLog(@"Plain text input: %@",textField.text);
        userName = textField.text;
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"chatName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isShowingAlertView = NO;
    }
    else if (isFirstShown){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Ooops"
                              message:@"Something's went wrong. To post in this room you must have a chat name. Please revist the screen to define one, else \"Chat Name\" will be as default"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Dismiss", nil];
        [alert show];
        isFirstShown = NO;
    }
    [self.chatTable setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
