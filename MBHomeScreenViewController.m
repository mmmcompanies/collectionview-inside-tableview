//
//  MBHomeScreenViewController.m
//  MyBag1
//
//  Created by Divyanshu Sharma on 10/08/15.
//  Copyright (c) 2015 Techno Softwares. All rights reserved.
//

#import "MBHomeScreenViewController.h"
#import "Global.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Reachability.h"

#define TIME_INTERVAL_TO_UPDATE_LOGIN_DURATION 1800

#define SECONDS_IN_24HRS 86480

@interface MBHomeScreenViewController ()
{
    UIAlertView *alert;
    
    Global *global;
    
    // Variable to identify whether sideMenu screen is open or not.
    BOOL isReveal;
    
    // Variable to identify table:did select method called by gesture or not
    BOOL isFromGesture;
    
    // Array to hold category list permanently
    NSArray *arrCategory;
    
    // Array to hold category list temporary
    NSMutableArray *arrTimerCategory;
    
    // Timer function to load cells with some delay
    NSTimer *timer;
    
    // Object to save reference of long pressed button
    UIButton *touchedButton;
    
    // Time interval from last updated time to the server
    CGFloat timeInterval;
    
    
}
@property(strong,nonatomic) RigthSlideMenu *rigthMenuView;
@end

@implementation MBHomeScreenViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    [locationManager requestWhenInUseAuthorization];
    
    arrCategory = @[@"Chemistry",@"Biology",@"Physics",@"Math",@"Business",@"English"];
    
    arrTimerCategory = [[NSMutableArray alloc]initWithObjects:@"Chemistry", nil];
    
    global = [Global sharedInstance];
    
    self.btnSearch.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.btnSearch.layer.cornerRadius = 8.0;
        self.btnSearch.layer.borderWidth = 2.0;
    }
    else
    {
        self.btnSearch.layer.cornerRadius = 5.0;
        self.btnSearch.layer.borderWidth = 1.0;
    }
    
        [_btnView addTarget:self action:@selector(btnViewPressed) forControlEvents:UIControlEventTouchUpInside];
    
        // Touch Up Inside
        
         [self.btnBiolgy addTarget:self action:@selector(btnCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        
         [self.btnBusiness addTarget:self action:@selector(btnCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        
         [self.btnChemistry addTarget:self action:@selector(btnCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        
         [self.btnEnglish addTarget:self action:@selector(btnCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        
         [self.btnMath addTarget:self action:@selector(btnCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        
         [self.btnPhysis addTarget:self action:@selector(btnCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.btnSearch addTarget:self action:@selector(btnCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self.btnSideMenu addTarget:self action:@selector(btnSideMenuPressed) forControlEvents:UIControlEventTouchUpInside];
    
        [self.btnMyVideo addTarget:self action:@selector(btnMyVideoPressed) forControlEvents:UIControlEventTouchUpInside];
    
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    
    
        [self.view addGestureRecognizer:longPress];
    
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnView)];
    
        [self.view addGestureRecognizer:tap];
    
        tap.delegate = self;
    
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeOnView)];
    
        swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
        [self.view addGestureRecognizer:swipeGesture];
    
        _txtSearchVideo.returnKeyType = UIReturnKeySearch;
    
        // Do any additional setup after loading the view.
    
 //   NSDate *loginDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginTime"];
    
//    if(loginDate)
//    {
//        timeInterval = [[NSDate date] timeIntervalSinceDate:loginDate];
//    }
    
   // [self updateUserLoginTime];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    [self setCategoriyButtons];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [self fetchPrivacyPolicy];
    _btnView.userInteractionEnabled = NO;
    
    if(![global isConnectedToInternet])
    {
        _btnView.userInteractionEnabled = YES;
    }
    [self GetLoginData];
    
    self.lblCategory.hidden = NO;
    
    self.lblSearchVideo.hidden = NO;
    
    self.txtCategory.text = @"";
    
    self.txtSearchVideo.text = @"";

    NSArray *arr = [self.childViewControllers mutableCopy];
        
    for(UIViewController *viewController in arr)
    {
            if([viewController isKindOfClass:[RigthSlideMenu class]])
            {
                [viewController.view removeFromSuperview];
                [viewController removeFromParentViewController];
            }
    }
        
    isReveal = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNewViewController:) name:@"sideMenuPressed" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"sideMenuPressed" object:nil];
    
    [self.view endEditing:YES];
    
    self.rigthMenuView = nil;
    
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        

            obj.userInteractionEnabled = YES;
        
    }];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setCategoriyButtons];
    
    _imgBackground.image = [UIImage imageNamed:@"bg.jpg"];
    
    if(UIInterfaceOrientationIsPortrait(fromInterfaceOrientation))
    {
        _imgBackground.image = [UIImage imageNamed:@"bgl.png"];
    }
    [global SetupHeaderLogo:self.headerLogoWidthConstraint];
}

-(void)setCategoriyButtons
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        switch ((int)[[UIScreen mainScreen] bounds].size.width) {
            case 736:
            {
                _btnHeightConstrarint.constant = 70;
                _btnWidthConstraint.constant = 70;
                _btnUpVerticalConstraint.constant = 10;
                _btnDownVerticalConstraint.constant = 25;
                _headerLogoWidthConstraint.constant = -75;
                _btnSearchVerticalConstraint.constant = 30;
                
                [self.view layoutIfNeeded];
                break;
            }
            case 667:
            {
                _btnHeightConstrarint.constant = 60;
                _btnWidthConstraint.constant = 60;
                _btnUpVerticalConstraint.constant = 10;
                _btnDownVerticalConstraint.constant = 25;
                _headerLogoWidthConstraint.constant = -65;
                _btnSearchVerticalConstraint.constant = 30;

                [self.view layoutIfNeeded];
                break;
            }
            case 568:
            {
                _btnHeightConstrarint.constant = 50;
                _btnWidthConstraint.constant = 50;
                _btnUpVerticalConstraint.constant = 3;
                _btnDownVerticalConstraint.constant = 25;
                _headerLogoWidthConstraint.constant = -50;
                _btnSearchVerticalConstraint.constant = 25;

                [self.view layoutIfNeeded];
                break;
            }
            case 480:
            {
                _btnHeightConstrarint.constant = 50;
                _btnWidthConstraint.constant = 50;
                _btnUpVerticalConstraint.constant = 3;
                _btnDownVerticalConstraint.constant = 25;
                _headerLogoWidthConstraint.constant = -45;
                _btnSearchVerticalConstraint.constant = 25;

                [self.view layoutIfNeeded];
                break;
            }
            case 1024:
            {
                _btnHeightConstrarint.constant = 120;
                _btnWidthConstraint.constant = 120;
                _btnUpVerticalConstraint.constant = 20;
                _btnDownVerticalConstraint.constant = 35;
                _headerLogoWidthConstraint.constant = -100;
                _btnSearchVerticalConstraint.constant = 60;

                [self.view layoutIfNeeded];
                break;
            }
                
            default:
                break;
        }
    }
    else
    {
        switch ((int)[[UIScreen mainScreen] bounds].size.width) {
            case 414:
            {
                _btnHeightConstrarint.constant = 80;
                _btnWidthConstraint.constant = 80;
                _btnUpVerticalConstraint.constant = 30;
                _btnDownVerticalConstraint.constant = 65;
                _headerLogoWidthConstraint.constant = 0;
                _btnSearchVerticalConstraint.constant = 70;
                
                [self.view layoutIfNeeded];
                break;
            }
            case 375:
            {
                _btnHeightConstrarint.constant = 70;
                _btnWidthConstraint.constant = 70;
                _btnUpVerticalConstraint.constant = 20;
                _btnDownVerticalConstraint.constant = 55;
                _headerLogoWidthConstraint.constant = 0;
                _btnSearchVerticalConstraint.constant = 55;
                
                [self.view layoutIfNeeded];
                break;
            }
            case 320:
            {
                _btnHeightConstrarint.constant = 60;
                _btnWidthConstraint.constant = 60;
                _btnUpVerticalConstraint.constant = 20;
                _btnDownVerticalConstraint.constant = 35;
                _headerLogoWidthConstraint.constant = -15;
                _btnSearchVerticalConstraint.constant = 30;

                [self.view layoutIfNeeded];
                break;
            }
            case 768:
            {
                _btnHeightConstrarint.constant = 120;
                _btnWidthConstraint.constant = 120;
                _btnUpVerticalConstraint.constant = 50;
                _btnDownVerticalConstraint.constant = 85;
                _headerLogoWidthConstraint.constant = -30;
                _btnSearchVerticalConstraint.constant = 90;

                [self.view layoutIfNeeded];
                break;
            }
                
            default:
                break;
        }
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark
#pragma mark-Location Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSString *Area = [[NSString alloc]initWithString:placemark.locality];
             NSString *Country = [[NSString alloc]initWithString:placemark.country];
             NSString *state = [[NSString alloc]initWithString:placemark.administrativeArea];
             NSString *CountryArea = [NSString stringWithFormat:@"%@,%@,%@", Area,Country,state];
             [[NSUserDefaults standardUserDefaults] setObject:CountryArea forKey:@"location"];
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
             //return;
         }
     }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@",error.localizedDescription);
}


#pragma mark
#pragma mark-Gesture Method

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
    if([touch.view isDescendantOfView:self.rigthMenuView.view])
    {
        return NO;
    }
    else if ([touch.view isDescendantOfView:self.tblCategoryList])
    {
        CGPoint location = [touch locationInView:self.tblCategoryList];
        
        NSIndexPath *index = [self.tblCategoryList indexPathForRowAtPoint:location];
        
        isFromGesture = YES;

        [self tableView:self.tblCategoryList didDeselectRowAtIndexPath:index];
         
        return YES;
    }
    }
    else if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        if([touch.view isKindOfClass:[UIButton class]])
        {
            return YES;
        }
        
        return NO;
    }
    
    return YES;
}

-(void)longPress:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            UIButton *btn = (UIButton *)[self.view hitTest:[gesture locationInView:self.view] withEvent:nil];
            
            if([btn isKindOfClass:[UIButton class]])
            {
                touchedButton = btn;
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    btn.transform = CGAffineTransformMakeScale(0.7, 0.7);
                    
                }];
            }
            
            break;

        }
         
        case UIGestureRecognizerStateEnded:
        {
            if(touchedButton!= nil)
            {
            [UIView animateWithDuration:0.2 animations:^{
                
                touchedButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    
                    touchedButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
                    
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        
                        touchedButton.transform = CGAffineTransformIdentity;
                        
                    }];
                }];
            }];
            }
            
            break;
            
        }
        default:
            break;
    }
    
}

-(void)tapOnView
{
    [self.view endEditing:YES];
    if(isFromGesture)
    {
        isFromGesture = NO;
    }
    else
    {
        self.tblCategoryList.hidden = YES;
    }
}

#pragma mark
#pragma mark-TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrTimerCategory.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    UILabel *lblCategoryCell = (UILabel *)[cell viewWithTag:101];
    
    lblCategoryCell.text = [arrCategory objectAtIndex:indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return 90;
    }
    return 50;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    UIView *view = (UIView *)cell;
    
    view.transform = CGAffineTransformMakeTranslation(-500, 0);
    
    [UIView animateWithDuration:0.3 animations:^{
        view.transform = CGAffineTransformIdentity;
    }];
}

-(void)tableTimer
{
    if(arrTimerCategory.count != arrCategory.count)
    {
        [arrTimerCategory addObject:[arrCategory objectAtIndex:arrTimerCategory.count]];
        
        [_tblCategoryList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:arrTimerCategory.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [timer invalidate];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _lblCategory.hidden = YES;
    self.txtCategory.text = [arrCategory objectAtIndex:indexPath.row];
    if(isFromGesture)
    {
        isFromGesture = NO;
    }
    else
    {
        self.tblCategoryList.hidden = YES;
        
        isFromGesture = NO;
    }
}

#pragma mark
#pragma mark-Button Methods

-(void)btnViewPressed
{
        if(![global isConnectedToInternet])
        {
            _btnView.userInteractionEnabled = YES;
            [[[UIAlertView alloc] initWithTitle:nil message:@"Can't Operate Offline,Please Connect To Internet" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
        else
        {
            _btnView.userInteractionEnabled = NO;

        }
}

-(void)btnMyVideoPressed
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:0];
    
    if(![global LoadViewControllerwithIndexPath:index])
    {
        [self HideSideMenu:self];
        isReveal = NO;
    }
}

-(void)btnSideMenuPressed
{
    if(isReveal)
    {
        [self HideSideMenu:self];
        isReveal = NO;
    }
    else
    {
        [self movePanelRight:self];
        isReveal = YES;
    }
    
}

-(void)btnCategoryPressed:(UIButton *)sender
{
    sender.transform = CGAffineTransformIdentity;
    
    switch (sender.tag) {
        case 1001:
        {
            global.str_SearchCategory = @"chemistry";
            global.str_SearchKeyword = @"";

            break;
        }
            case 1002:
        {
            global.str_SearchCategory = @"biology";
            global.str_SearchKeyword = @"";


            break;
        }
            case 1003:
        {
            global.str_SearchCategory = @"physics";
            global.str_SearchKeyword = @"";


            break;
        }
            case 1004:
        {
            global.str_SearchCategory = @"math";
            global.str_SearchKeyword = @"";


            break;
        }
            case 1005:
        {
            global.str_SearchCategory = @"business";
            global.str_SearchKeyword = @"";


            break;
        }
            case 1006:
        {
            global.str_SearchCategory = @"english";
            global.str_SearchKeyword = @"";


            break;
        }
            case 1007:
        {
            if(_txtCategory.text.length == 0 && _txtSearchVideo.text.length == 0)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Enter a keyword to search", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                [alert show];
                
                return;
            }
            
            else if(self.txtSearchVideo.text.length > 70)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Keyword Should Be Less Than 70 Characters", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                [alert show];
                
                return;
            }
            
            if(_txtCategory.text.length == 0)
            {
                global.str_SearchCategory = @"";
                global.str_SearchKeyword = _txtSearchVideo.text;
            }
            else if(_txtSearchVideo.text.length == 0 && _txtCategory.text.length > 0)
            {
                global.str_SearchKeyword = @"";
                global.str_SearchCategory = _txtCategory.text;
            }
            else
            {
                global.str_SearchKeyword = _txtSearchVideo.text;
                global.str_SearchCategory = _txtCategory.text;
            }

            break;
        }
        default:
        {
            if(_txtCategory.text.length == 0 && _txtSearchVideo.text.length == 0)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Enter a keyword to search", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                [alert show];
                
                return;
            }
            
            else if(self.txtSearchVideo.text.length > 70)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Keyword Should Be Less Than 70 Characters", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                [alert show];
                
                return;
            }
            
            if(_txtCategory.text.length == 0)
            {
                global.str_SearchCategory = @"";
                global.str_SearchKeyword = _txtSearchVideo.text;
            }
            else if(_txtSearchVideo.text.length == 0 && _txtCategory.text.length > 0)
            {
                global.str_SearchKeyword = @"";
                global.str_SearchCategory = _txtCategory.text;
            }
            else
            {
                global.str_SearchKeyword = _txtSearchVideo.text;
                global.str_SearchCategory = _txtCategory.text;
            }
            break;
        }
            
    }
        [self performSegueWithIdentifier:@"showVideo" sender:self];
}


#pragma mark
#pragma mark-SideMenu Methods

-(void)swipeOnView
{
    [self HideSideMenu:self];
    isReveal = NO;
}

-(void)HideSideMenu:(UIViewController *)SuperView
{
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.userInteractionEnabled = YES;
        
    }];
    _btnSideMenu.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 20);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.rigthMenuView.view.frame = CGRectMake(SuperView.view.frame.size.width, 0, SuperView.view.frame.size.width, SuperView.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         [self.rigthMenuView.view removeFromSuperview];
                         [self.rigthMenuView removeFromParentViewController];
                         self.rigthMenuView = nil;
                    }];
}

-(UIView *)getLeftView:(UIViewController *)SuperView
{
    // init view if it doesn't already exist
    if (self.rigthMenuView == nil)
    {
        self.rigthMenuView = [[RigthSlideMenu alloc] initWithNibName:@"RigthSlideMenu" bundle:nil];
        
        [SuperView.view addSubview:self.rigthMenuView.view];
        
        [SuperView addChildViewController:self.rigthMenuView];
        
        [self.rigthMenuView didMoveToParentViewController:SuperView];
        
        self.rigthMenuView.view.frame = CGRectMake(SuperView.view.frame.size.width, 0, SuperView.view.frame.size.width, SuperView.view.frame.size.height);
    }
    
    // setup view shadows
    
    UIView *view = self.rigthMenuView.view;
    
    return view;
}

-(void)movePanelRight:(UIViewController *)SuperView
{
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
           if(obj.tag != 3456)
           {
               obj.userInteractionEnabled = NO;
           }
        
    }];
    UIView *childView = [self getLeftView:SuperView];
    
    [SuperView.view bringSubviewToFront:childView];
    
    childView.layer.shadowColor = [[UIColor blackColor] CGColor];
    childView.layer.shadowRadius = 20.0;
    childView.layer.masksToBounds = NO;
    childView.layer.shadowOpacity = 1.0;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGRect frame;

    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
        
            frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 900, 0,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        }
        else
        {
            
            if([[UIScreen mainScreen] bounds].size.width == 736)
            {
                frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 650, 0, SuperView.view.frame.size.width, SuperView.view.frame.size.height);
            }
            else if ([[UIScreen mainScreen] bounds].size.width == 667)
            {
                frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 600, 0, SuperView.view.frame.size.width, SuperView.view.frame.size.height);
            }
            else if ([[UIScreen mainScreen] bounds].size.width == 568)
            {
                frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 510, 0, SuperView.view.frame.size.width, SuperView.view.frame.size.height);
            }
            else
            {
                frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 422, 0, SuperView.view.frame.size.width, SuperView.view.frame.size.height);
            }
        }

    }
    else
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 670, 0, SuperView.view.frame.size.width, SuperView.view.frame.size.height);
        }
        else
        {
            if([[UIScreen mainScreen] bounds].size.width == 320)
            {
                frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 260, 0, SuperView.view.frame.size.width, SuperView.view.frame.size.height);
            }
            else if ([[UIScreen mainScreen] bounds].size.width == 375)
            {
                  frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 310, 0, SuperView.view.frame.size.width, SuperView.view.frame.size.height);
            }
            else
            {
                frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 350, 0, SuperView.view.frame.size.width, SuperView.view.frame.size.height);
            }

        }
    }
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.rigthMenuView.view.frame = frame;
    }
                     completion:nil];
}



#pragma mark
#pragma mark-Notification Method

//This method called a global method to load ViewControllers from storyboard according to indexpath of tableview of sideMenu View Controller.... This Notification is fired from didSelect method of tableView of SideMenu View Controller

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *strTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([strTitle isEqualToString:@"Rate Now"])
    {
        
    }
    else if([strTitle isEqualToString:@"Later"])
    {
        double lastTImeStamp = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setValue:[@(lastTImeStamp) stringValue] forKey:@"lastratetimestamp"];
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"durationtype"])
        {
            [[NSUserDefaults standardUserDefaults] setValue:@"months" forKey:@"durationtype"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setValue:@"week" forKey:@"durationtype"];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(buttonIndex == 1)
    {
        [global GotoLogin];
    }
}

-(void)pushNewViewController:(NSNotification *)notification
{
    NSIndexPath *index = [notification.object objectForKey:@"indexPath"];
    
    if(index.row == 7)
    {
        [locationManager startMonitoringSignificantLocationChanges];
        [locationManager startUpdatingLocation];
    }
    if(index.row == 2)
    {
        if(global.str_UserId)
        {
        [self HideSideMenu:self];
        
        isReveal = NO;
        
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Setting"];
        
        global.popOver = [[WYPopoverController alloc]initWithContentViewController:viewController];
        
        [global.popOver presentPopoverAsDialogAnimated:YES];
        }
        else
        {
            alert = [[UIAlertView alloc]initWithTitle:nil message:@"You Need To SignIn or SignUp To Configure Settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"SignIn", nil];
            [alert show];
        }
    }
    else if(![global LoadViewControllerwithIndexPath:index])
    {
        [self HideSideMenu:self];
        isReveal = NO;
    }

}


#pragma mark
#pragma mark-Textfield Delegates

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.txtCategory)
    {
        if(self.tblCategoryList.hidden)
        {
        arrTimerCategory = [[NSMutableArray alloc]initWithObjects:@"Chemistry", nil];
            
        [self.view endEditing:YES];
            
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(tableTimer) userInfo:nil repeats:YES];
            
        self.tblCategoryList.hidden = NO;
        
        [self.view bringSubviewToFront:_tblCategoryList];
            
        [self.tblCategoryList reloadData];
        
        return NO;
        }
        else
        {
            _tblCategoryList.hidden = YES;
            
            return NO;
        }
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.txtSearchVideo)
    {
        self.lblSearchVideo.hidden = YES;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField.text.length > 0)
    {
        [self btnCategoryPressed:nil];
    }
    else
    {
        alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Enter a keyword to search", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
        
        [alert show];
    }
    return YES;
}

#pragma mark
#pragma mark-LoginData Fetching
-(void)GetLoginData
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"])
    {
    global.str_UserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    
    global.str_Image = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_image"];
    
    global.str_Gender = [[NSUserDefaults standardUserDefaults] objectForKey:@"gender"];
    
    global.str_Email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    
    global.str_Education_Level = [[NSUserDefaults standardUserDefaults] objectForKey:@"education"];
    
    global.str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"];
    
    global.str_LoginType = [[NSUserDefaults standardUserDefaults] objectForKey:@"login_type"];
    
    global.str_Password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        
    global.strNotifcationStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_status"];
    }
}

-(void)fetchPrivacyPolicy
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:@"http://mybag.technosoftwares.org/cms.php" parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSArray *arrResponse = responseObject;
        
        global.strAboutUs = [[arrResponse objectAtIndex:0] objectForKey:@"about_us"];

        global.strPrivacyPolicy = [[arrResponse objectAtIndex:0] objectForKey:@"privacy_policy"];

    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        global.strAboutUs = @"Hello Dear User,Welcome to MyBag Application";
        global.strPrivacyPolicy = @"Our Privacy Policy";
        
    }];
}

//- (void)updateUserLoginTime
//{
//    if([[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"])
//    {
//        NSDate *loginDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginTime"];
//        
//        if(loginDate)
//        {
//            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:loginDate];
//            CGFloat timeOnline = interval - timeInterval;
//            timeInterval = interval;
//            if(timeOnline)
//            {
//                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//                
//                manager.responseSerializer = [AFJSONResponseSerializer serializer];
//                
//                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//                
//                NSDictionary *params = @{@"user_id":[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],@"time":[NSString stringWithFormat:@"%f", timeOnline]};
//                
//                [manager GET:@"http://mybag.technosoftwares.org/calculate_time.php" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//                    
//                    if([[responseObject objectForKey:@"result"] isEqualToString:@"logged out"])
//                    {
//                        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//                        
//                        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//                        
//                        [self.navigationController popToRootViewControllerAnimated:YES];
//                        
//                        [[[UIAlertView alloc]initWithTitle:nil message:@"You have been logged out" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
//                    }
//                    else
//                    {
//                    NSLog(@"%@",responseObject);
//                    [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL_TO_UPDATE_LOGIN_DURATION
//                                                     target:self
//                                                   selector:@selector(updateUserLoginTime)
//                                                   userInfo:nil
//                                                    repeats:NO];
//                    }
//                    
//                } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//                    
//                    NSLog(@"%@",error.localizedDescription);
//                    [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL_TO_UPDATE_LOGIN_DURATION
//                                                     target:self
//                                                   selector:@selector(updateUserLoginTime)
//                                                   userInfo:nil
//                                                    repeats:NO];
//                }];
//            }
//        }
//    }
//    else
//    {
//        [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL_TO_UPDATE_LOGIN_DURATION
//                                         target:self
//                                       selector:@selector(updateUserLoginTime)
//                                       userInfo:nil
//                                        repeats:NO];
//    }
//}

@end
