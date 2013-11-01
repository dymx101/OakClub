//
//  SnapshotSetting.m
//  OakClub
//
//  Created by VanLuu on 6/13/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "SnapshotSetting.h"
#import "SettingObject.h"
#import "AppDelegate.h"
#import "UITableView+Custom.h"
#import "UIViewController+Custom.h"
#import "VCLogout.h"

@interface SnapshotSetting (){
    SettingObject* snapshotObj;
    AFHTTPClient *request;
    int fromAge;
    int toAge;
    int i_range;
    NSArray *ageOptions;
    UIPickerView* picker;
}
@property (strong, nonatomic) IBOutlet VCLogout *logoutViewController;
@property (nonatomic) NSUInteger hereTo;
@end

@implementation SnapshotSetting
bool isPickerShowing= false;
UITapGestureRecognizer *tap;
@synthesize lblRange,pickerAge, btnAdvance;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customBackButtonBarItem];
    
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tap];
    
    snapshotObj = [[SettingObject alloc] init];
    [self loadSetting];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];

}
-(void)viewDidAppear:(BOOL)animated{
     [self initSaveButton];
}
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchDownOnSlider:(id)sender {
    [self appDelegate].rootVC.recognizesPanningOnFrontView = NO;
}

- (IBAction)touchUpOnSlider:(id)sender {
    [self appDelegate].rootVC.recognizesPanningOnFrontView = YES;
}

- (IBAction)sliderValueChanged:(id)sender
{
    [self updateSliderPopoverText];
}
- (void)updateSliderPopoverText
{
    double value = self.sliderRange.value;
    int intValue = round(value);
    [self.sliderRange setValue:intValue];
    snapshotObj.range = intValue * 100;
    NSString* sRange = [self getRangeValue:snapshotObj.range];
    self.sliderRange.popover.textLabel.text = sRange;
    lblRange.text = sRange;
}

-(NSString*)getRangeValue:(NSUInteger)value
{
    NSString* sRange;
    if(value < 600)
        sRange = [NSString stringWithFormat:@"%d km", value];
    else
        if(value < 700)
            sRange = @"Country";//snapshotObj.location.countryCode;
        else
            sRange = @"World";
    return sRange;
}

-(void)initSaveButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 37, 31);
    [btn setImage:[UIImage imageNamed:@"header_btn_save.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"header_btn_save_pressed.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(saveSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *Item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=Item;
    self.navigationItem.title = @"Snapshot Settings";
}
- (int) loadHereTo:(NSString*)value{
    if(value!= NULL && [value isEqualToString:value_MakeFriend]){
        return 1;
    }
    else{
        if([value isEqualToString:value_Chat]){
            return 2;
        }
        else{
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectedBackgroundView = [tableView customSelectdBackgroundViewForCellAtIndexPath:indexPath];
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    switch (section)
    {
        case 0:
            if (row == self.hereTo)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
            
        case 1:
            if (row == 0 && snapshotObj.interested_new_people)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 1 && snapshotObj.interested_friend_of_friends)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 2 && snapshotObj.interested_friends)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 2:
            if (row == 0 && ([snapshotObj.gender_of_search isEqualToString:value_Male] || [snapshotObj.gender_of_search isEqualToString:value_All]))
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 1 && ([snapshotObj.gender_of_search isEqualToString:value_Female] || [snapshotObj.gender_of_search isEqualToString:value_All]) )
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if(row == 2){
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d-%d year old",fromAge,toAge];
            }
            break;
        case 3:
            if(row == 0){
                cell.detailTextLabel.text = snapshotObj.location.name;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                
            break;
    }
    [cell.detailTextLabel setFont: FONT_NOKIA(17.0)];
    [cell.textLabel setFont: FONT_NOKIA(17.0)];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.detailTextLabel.highlightedTextColor = COLOR_BLUE_CELLTEXT;
    return cell;
}
#pragma mark - Table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    UIImageView *headerImage = [[UIImageView alloc] init]; //set your image/
    
    UILabel *headerLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 205, 20)];//set as you need
    headerLbl.backgroundColor = [UIColor clearColor];
    UIFont *newfont = FONT_NOKIA(20.0);
    [headerLbl setFont:newfont];
    switch (section) {
        case 0:
            headerLbl.text = @"I'm here to";
            break;
        case 1:
            headerLbl.text = @"I want to see";
            break;
        case 2:
            headerLbl.text = @"With who";
            break;
        case 3:
            if(!isPickerShowing)
                headerLbl.text = @"Where";
            break;
        default:
            headerLbl.text = nil;
            break;
    }
    [headerImage addSubview:headerLbl];
    
    headerImage.frame = CGRectMake(0, 0, tableView.bounds.size.width, 20);
    
    [headerView addSubview:headerImage];
    
    return headerView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (section)
    {
        case 3:
            if (row==0) {
                 [self gotoChooseCity];
            }
            break;
        case 0:
            self.hereTo = row;
            switch (row) {
                case 0:
                    snapshotObj.purpose_of_search = value_Date;
                    break;
                case 1:
                    snapshotObj.purpose_of_search = value_MakeFriend;
                    break;
                case 2:
                    snapshotObj.purpose_of_search = value_Chat;
                    break;
                default:
                    break;
            }
            break;
        case 1:
            if(row == 0){
                snapshotObj.interested_new_people = !snapshotObj.interested_new_people;
            }
            if(row == 1){
                snapshotObj.interested_friend_of_friends = !snapshotObj.interested_friend_of_friends;
            }
            if(row == 2){
                snapshotObj.interested_friends = !snapshotObj.interested_friends;
            }
            break;
        case 2:
            if(row == 0){
                if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                    if([snapshotObj.gender_of_search isEqualToString:value_Male])
                        snapshotObj.gender_of_search = @"none";
                    else
                        snapshotObj.gender_of_search = value_Female;
                }
                else{
                    if([snapshotObj.gender_of_search isEqualToString:value_Female])
                        snapshotObj.gender_of_search =value_All;
                    else
                        snapshotObj.gender_of_search = value_Male;
                }
               
            }
            if(row == 1){
                if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                    if([snapshotObj.gender_of_search isEqualToString:value_Female])
                        snapshotObj.gender_of_search = @"none";
                    else
                        snapshotObj.gender_of_search = value_Male;
                }
                else{
                    if([snapshotObj.gender_of_search isEqualToString:value_Male])
                        snapshotObj.gender_of_search =value_All;
                    else
                        snapshotObj.gender_of_search = value_Female;
                }
            }
            if(row == 2){
//                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                
                if(isPickerShowing){
                    [picker removeFromSuperview];
                }
                else{
                    picker = [[UIPickerView alloc] init];
                    picker.delegate = self;
                    picker.dataSource =self;
                    picker.showsSelectionIndicator = YES;
                    picker.frame = CGRectMake(0, cell.frame.origin.y + 52, 320, 200);
                    
//                    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, picker.frame.size.width, 30)];
//                    toolbar.barStyle = UIBarStyleBlackOpaque;
//                    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleBordered target: self action: @selector(donePressed)];
//                    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//                    toolbar.items = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
//                    
                    [self initAgeList];
//                    [picker addSubview: toolbar];
                    [self.view addSubview: picker];
                    [picker setNeedsDisplay];
                    
                }
                isPickerShowing = !isPickerShowing;
//                [self.tableView.tableHeaderView setHidden:isPickerShowing];// setSectionHeaderHeight:0];
                [self.tableView reloadData];
                
            }
            break;
    }
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [self setSliderRange:nil];
    [self setLblRange:nil];
    [self setPickerAge:nil];
    [self setBtnAdvance:nil];
    [super viewDidUnload];
}

- (void)gotoChooseCity {
    ListForChoose *locationView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [locationView setListType:LISTTYPE_COUNTRY];
    locationView.delegate=self;
    [self.navigationController pushViewController:locationView animated:YES];
    
}
#pragma mark ListForChoose DataSource/Delegate
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row{
    Profile* selected = [uvcList getCurrentValue];
    SettingObject* selectedValue = [uvcList getSettingValue];
    switch ([uvcList getType]) {
        case LISTTYPE_CITY:
        {
            snapshotObj.location = selected.s_location;
            [self.tableView reloadData];
            break;
        }
        case LISTTYPE_COUNTRY:{
            ListForChoose *locationSubview = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
            [locationSubview setCityListWithCountryCode:selected.s_location.countryCode];
            locationSubview.delegate = self;
            [self.navigationController pushViewController:locationSubview animated:YES];
            break;
        }
        default:
            break;
    }
}

-(NSString*) BoolToString:(BOOL)value{
    if(value)
        return value_TRUE;
    else
        return value_FALSE;
}

- (void) loadSetting{
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [request getPath:URL_getSnapshotSetting parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSMutableDictionary * data= [dict valueForKey:key_data];
        snapshotObj.purpose_of_search = [data valueForKey:key_purpose_of_search];
        self.hereTo = [self loadHereTo:snapshotObj.purpose_of_search];
        snapshotObj.gender_of_search = [data valueForKey:key_gender_of_search];//[Profile parseGender:[data valueForKey:key_gender_of_search]];
        
        fromAge = [[data valueForKey:key_age_from] integerValue];
        toAge= [[data valueForKey:key_age_to] integerValue];
        
        NSMutableDictionary* status_interested_in = [data valueForKey:key_status_interested_in];
        snapshotObj.interested_new_people = [[status_interested_in valueForKey:key_new_people] boolValue];
        snapshotObj.interested_friend_of_friends = [[status_interested_in valueForKey:key_status_fof] boolValue];
        snapshotObj.interested_friends = [[status_interested_in valueForKey:key_friends] boolValue];
        
        i_range = [[data valueForKey:key_range] integerValue];
        
        [self.sliderRange setValue:i_range/100];
        lblRange.text = [self getRangeValue:i_range];
        
        NSMutableDictionary *location = [data valueForKey:key_location];
        snapshotObj.location = [[Location alloc] initWithNSDictionary:location];
        
        // advance settings
//        [self loadShowFOF:[[data valueForKey:key_show_fof] boolValue]];
//        
//        [btnAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old",fromAge,toAge] forState:UIControlStateNormal];
//        [chbInterests setSelected:[[data valueForKey:key_is_interests] boolValue]];
//        [chbLikes setSelected:[[data valueForKey:key_is_likes] boolValue]];
//        [chbSchool setSelected:[[data valueForKey:key_is_school] boolValue]];
//        [chbwork setSelected:[[data valueForKey:key_is_work] boolValue]];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}

-(void)saveSetting{
    if(fromAge > toAge){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message:@"FromAge Must Be Smaller Than ToAge"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSString * s_isInterest= [self BoolToString:false];
    NSString * s_isLikes= [self BoolToString:false];
    NSString * s_isWork= [self BoolToString:false];
    NSString * s_isSchool= [self BoolToString:false];
    NSString * s_isNewPeople= [self BoolToString:snapshotObj.interested_new_people];
    NSString * s_isFOF= [self BoolToString:snapshotObj.interested_friend_of_friends];
    NSString * s_isFriend= [self BoolToString:snapshotObj.interested_friends];
    NSString *s_hereto = snapshotObj.purpose_of_search;
    NSString *s_gender= snapshotObj.gender_of_search;
    NSString *s_showFOF= [self BoolToString:false];
    //    NSString *s_fromAge = [NSString stringWithFormat:@"%i",fromAge];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                            s_hereto,key_purpose_of_search,
                            s_gender,key_gender_of_search,
                            [NSString stringWithFormat:@"%i",i_range],key_range,
                            [NSString stringWithFormat:@"%i",fromAge], key_age_from,
                            [NSString stringWithFormat:@"%i",toAge], key_age_to,
                            s_isNewPeople,key_new_people_status,
                            s_isFOF,key_FOF_status,
                            snapshotObj.location.ID,key_locationID,
                            s_isInterest,key_is_interests,
                            s_isLikes,key_is_likes,
                            s_isWork,key_is_work,
                            s_isSchool,key_is_school,
                            s_showFOF,key_show_fof,
                            @"",key_BlockList,
                            @"",key_PriorityList,
                            nil];
    [request setParameterEncoding:AFFormURLParameterEncoding];
    [request postPath:URL_setSnapshotSetting parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        BOOL status= [[dict valueForKey:key_status] boolValue];
        if(status){
            NSLog(@"POST SUCCESS!!!");
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
            NSLog(@"POST FAIL...");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}


#pragma mark Picker DataSource/Delegate
-(void) initAgeList{
//    showCityPicker = NO;
    NSMutableArray *ages = [NSMutableArray array];
    for(int i =MIN_AGE; i <= MAX_AGE; i++){
        [ages addObject:[NSString stringWithFormat:@"%d",i] ];
    }
    ageOptions =  ages;
    [picker reloadAllComponents];
    [picker selectRow:(fromAge - 16) inComponent:0 animated:NO];
    [picker selectRow:(toAge - 16) inComponent:1 animated:NO];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

        return [ageOptions count];
}
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
//    
//        return 70.0;
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [ageOptions objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@" select age is %@ OF COMPONENT %d",[ageOptions objectAtIndex:row],component);
    if(component == 0)
        fromAge = [[ageOptions objectAtIndex:row] integerValue];
    else
        toAge = [[ageOptions objectAtIndex:row] integerValue];
//    [self.tableView reloadSections:[[NSIndexPath alloc] initWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
//    [btnAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old",fromAge,toAge] forState:UIControlStateNormal];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [picker removeFromSuperview];
    isPickerShowing = NO;
    [self.tableView reloadData];
}
- (void)dismissKeyboard {
    if (isPickerShowing){
        [[self.tableView.gestureRecognizers objectAtIndex:2] setCancelsTouchesInView:isPickerShowing];
        [picker removeFromSuperview];
        isPickerShowing = NO;
        [self.tableView reloadData];
    }
}
@end
