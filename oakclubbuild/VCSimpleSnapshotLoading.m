//
//  VCSimpleSnapshotLoading.m
//  OakClub
//
//  Created by VanLuu on 10/31/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCSimpleSnapshotLoading.h"
#import "AnimatedGif.h"
#import "AppDelegate.h"
#import "UIView+Localize.h"
@interface VCSimpleSnapshotLoading (){
    int typeOfAlert; // 0-Finding, 1-DoneSearching , 2-Noresult
    UIImageView* loadingAnim;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgLoading;
@property (weak, nonatomic) IBOutlet UIButton *btnContentAlert;
@property (weak, nonatomic) IBOutlet UIImageView *imgNOPEDisable;
@property (weak, nonatomic) IBOutlet UIImageView *imgiDisable;
@property (weak, nonatomic) IBOutlet UIImageView *imgLIKEDisable;
@property (weak, nonatomic) IBOutlet UILabel *lblContentAlert;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;

@end

@implementation VCSimpleSnapshotLoading
@synthesize lblContentAlert, imgiDisable, imgLIKEDisable, imgLoading,imgNOPEDisable,btnContentAlert,imgAvatar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Snapshot_gps_loading.gif" ofType:nil]];
        loadingAnim = 	[AnimatedGif getAnimationForGifAtUrl: fileURL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController setNavigationBarHidden:NO];
    [self customBackButtonBarItem];
    [self  loadViewbyType];
}

-(void)customBackButtonBarItem{
    UIView* leftItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    UIButton* buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBack.frame = CGRectMake(IS_OS_7_OR_LATER?-10:0, 0, 44, 44);
    [buttonBack addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"Navbar_btn_menu.png"] forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"Navbar_btn_menu_pressed.png"] forState:UIControlStateHighlighted];
    [buttonBack addTarget:self action:@selector(menuPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack addTarget:self action:@selector(onTouchDownControllButton:) forControlEvents:UIControlEventTouchDown];
    [leftItemView addSubview:buttonBack];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItemView];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
    UIView* rightItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    UIButton* buttonChat = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonChat.frame = CGRectMake(IS_OS_7_OR_LATER?40:36, 0, 44, 44);
    [buttonChat addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [buttonChat setBackgroundImage:[UIImage imageNamed:@"Navbar_btn_chat.png"] forState:UIControlStateNormal];
    [buttonChat setBackgroundImage:[UIImage imageNamed:@"Navbar_btn_chat_pressed.png"] forState:UIControlStateHighlighted];
    [buttonChat addTarget:self action:@selector(rightItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonChat addTarget:self action:@selector(onTouchDownControllButton:) forControlEvents:UIControlEventTouchDown];
    [rightItemView addSubview:buttonChat];
    UIBarButtonItem *buttonChatItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemView];
    self.navigationItem.rightBarButtonItem = buttonChatItem;
   
    AppDelegate* appdel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appdel countTotalNotifications] > 0){
        UILabel* lblNumNotification = [[UILabel alloc]initWithFrame:CGRectMake(IS_OS_7_OR_LATER?47:30,6, 20, 20)];
        [lblNumNotification setFont:FONT_HELVETICANEUE_LIGHT(10)];
        [lblNumNotification setTextColor:[UIColor whiteColor]];
        [lblNumNotification setBackgroundColor:[UIColor clearColor]];
        [lblNumNotification setTextAlignment:NSTextAlignmentCenter];
        UIImageView* imgViewNotification = [[UIImageView alloc]initWithFrame:lblNumNotification.frame];
        [imgViewNotification setImage:[UIImage imageNamed:@"Navbar_notification.png"]];
        [rightItemView addSubview:imgViewNotification];
        lblNumNotification.text = [NSString stringWithFormat:@"%d+", [appdel countTotalNotifications]];
        [rightItemView addSubview:lblNumNotification];
    }
    
    
   
    
//    [self setNotifications:20];
}
-(void)viewWillAppear:(BOOL)animated{
//    [self  loadViewbyType];
    
    AppDelegate* appdel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appdel.reloadSnapshot){
        [self.navigationController popViewControllerAnimated:NO];
    }
    [self setNotifications:[appdel countTotalNotifications]];
    
    [self.view localizeAllViews];
    
    //load avatar
    [appdel.imagePool getImageAtURL:appdel.myProfile.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error) {
        [imgAvatar setImage:img];
    }];
}

-(void)viewDidDisappear:(BOOL)animated{
//    [self removeNotification];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Load view by typeOfAlert
-(void) setTypeOfAlert:(int)type andAnim:(UIImageView*)imgAnim{
    typeOfAlert = type;
    for (UIView * subview in [self.view subviews]){
        if([subview isKindOfClass:[UIImageView class]]){
            [subview removeFromSuperview];
        }
    }
    
    [self.view addSubview:imgAvatar];
    if(imgAnim != nil){
        CGRect gifFrame;
        if(IS_HEIGHT_GTE_568)
            gifFrame = CGRectMake(9, 25, imgAnim.frame.size.width, imgAnim.frame.size.height);
        else
            gifFrame = CGRectMake(9, 0, imgAnim.frame.size.width, imgAnim.frame.size.height);
        [imgAnim setFrame:gifFrame];
        [self.view  addSubview:imgAnim];
        imgAvatar.center = imgAnim.center;
    }
    [self loadViewbyType];
    
}
-(int)typeOfAlert
{
    return typeOfAlert;
}
-(void)loadViewbyType
{
    switch (typeOfAlert) {
        case 0:
        {
//            [self.view addSubview:imgNOPEDisable];
//            [self.view addSubview:imgLIKEDisable];
//            [self.view addSubview:imgiDisable];
//            [self.view sendSubviewToBack:imgAvatar];
            [btnContentAlert setHidden:YES];
            [lblContentAlert setText:[@"Finding nearby people ..." localize]];
            break;
        }
        case 1:
        {
            [btnContentAlert setHidden:NO];
            [lblContentAlert setText:[@"You've seen all the recommendations near you." localize]];
            [imgLoading setImage:[UIImage imageNamed:@"SnapshotLoading_map_loaded.png"]];
//            [self.view addSubview:imgLoading];
            break;
        }
        case 2:
        {
//            [self.view addSubview:imgNOPEDisable];
//            [self.view addSubview:imgLIKEDisable];
//            [self.view addSubview:imgiDisable];
            [imgLoading setImage:[UIImage imageNamed:@"SnapshotLoading_graymap_loaded.png"]];
//            [self.view addSubview:imgLoading];
            [btnContentAlert setHidden:YES];
            [lblContentAlert setText:[@"Location setting is disabled" localize]];
        }
        default:
            break;
    }
}
- (IBAction)onTouchTellYourFriends:(id)sender {
    NSString* body = [@"Join www.OakClub.com and meet many cool singles nearby. Safe, trustworthy and private." localize];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:[NSArray arrayWithObjects:body,[UIImage imageNamed:@"Default-image_share"],nil] applicationActivities:nil];
    [activityViewController setValue:[@"I am in OakClub, you?" localize] forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark handle onTouch in button
- (void)menuPressed:(id)sender {
    NSLog(@"openMenu");
    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
    appDel.rootVC.recognizesPanningOnFrontView = YES;
    [appDel showLeftView];
}
-(void)onTouchDownControllButton:(id)sender{
    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
    appDel.rootVC.recognizesPanningOnFrontView = NO;
}

- (void)rightItemPressed:(id)sender {
    NSLog(@"rightItemPressed");
    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
    appDel.rootVC.recognizesPanningOnFrontView = YES;
    [appDel.rootVC showViewController:appDel.chat];
}

#pragma mark notification
-(void)setNotifications:(int)count
{
    UILabel* lblNumNotification = [[UILabel alloc]initWithFrame:CGRectMake(265, 6, 20, 20)];
    [lblNumNotification setBackgroundColor:[UIColor clearColor]];
    [lblNumNotification setTextColor:[UIColor whiteColor]];
    [lblNumNotification setFont:FONT_HELVETICANEUE_LIGHT(10)];
    [lblNumNotification setTextAlignment:NSTextAlignmentCenter];
    UIImageView* imgViewNotification = [[UIImageView alloc]initWithFrame:lblNumNotification.frame];
    [imgViewNotification setImage:[UIImage imageNamed:@"Navbar_notification.png"]];

    if(count > 0)
    {
        [self.navigationController.navigationBar addSubview:imgViewNotification];
        lblNumNotification.text = [NSString stringWithFormat:@"%d+", count];
        [self.navigationController.navigationBar addSubview:lblNumNotification];
    }
    
//     NSLog(@"subview  =  %i",[[self.navigationController.navigationBar subviews] count]);
}
-(void)removeNotification{
//    if(IS_OS_7_OR_LATER){
    self.navigationController.navigationBarHidden = YES;
//    NSLog(@"subview  =  %i",[[self.navigationController.navigationBar subviews] count]);
        for(UIView* subview in [self.navigationController.navigationBar subviews]){
            if([subview isKindOfClass:[UILabel class]] || [subview isKindOfClass:[UIImageView class]])
                [subview removeFromSuperview];
        }
//    }
}
@end
