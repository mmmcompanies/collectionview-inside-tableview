//
//  MBHomeScreenViewController.h
//  MyBag1
//
//  Created by Divyanshu Sharma on 10/08/15.
//  Copyright (c) 2015 Techno Softwares. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface MBHomeScreenViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;

}

@property(weak,nonatomic) IBOutlet UITextField *txtCategory;

@property(weak,nonatomic) IBOutlet UITextField *txtSearchVideo;


@property(weak,nonatomic) IBOutlet UIButton *btnChemistry;
@property(weak,nonatomic) IBOutlet UIButton *btnBiolgy;
@property(weak,nonatomic) IBOutlet UIButton *btnPhysis;
@property(weak,nonatomic) IBOutlet UIButton *btnMath;
@property(weak,nonatomic) IBOutlet UIButton *btnBusiness;
@property(weak,nonatomic) IBOutlet UIButton *btnEnglish;



@property(weak,nonatomic) IBOutlet UIButton * btnSearch;

@property(weak,nonatomic) IBOutlet UILabel *lblSearchVideo;

@property(weak,nonatomic) IBOutlet UIButton *btnSideMenu;

@property(weak,nonatomic) IBOutlet UIButton *btnMyVideo;

@property(weak,nonatomic) IBOutlet UITableView *tblCategoryList;

@property(weak,nonatomic) IBOutlet UILabel *lblCategory;

@property(weak,nonatomic) IBOutlet UIImageView *imgBackground;

@property(weak,nonatomic) IBOutlet UIButton *btnView;

#pragma mark
#pragma mark-AutoLayout Constraint

@property(weak,nonatomic) IBOutlet NSLayoutConstraint *headerLogoWidthConstraint;\

@property(weak,nonatomic) IBOutlet NSLayoutConstraint *btnWidthConstraint;

@property(weak,nonatomic) IBOutlet NSLayoutConstraint *btnHeightConstrarint;

@property(weak,nonatomic) IBOutlet NSLayoutConstraint *btnUpVerticalConstraint;

@property(weak,nonatomic) IBOutlet NSLayoutConstraint *btnDownVerticalConstraint;

@property(weak,nonatomic) IBOutlet NSLayoutConstraint *btnSearchVerticalConstraint;


@end
