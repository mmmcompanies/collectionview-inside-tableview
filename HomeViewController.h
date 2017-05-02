//
//  HomeViewController.h
//  MPlayer
//
//  Created by Techno Softwares on 27/09/16.
//  Copyright © 2016 Techno Softwares. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "detailView.h"
#import "UIScrollView+APParallaxHeader.h"
#import "CustomAlertView.h"
#import "ShareingPopupView.h"

@interface HomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,APParallaxViewDelegate,CustomAlertDelegate,ShareingPopupViewDelegate,GADInterstitialDelegate,GADBannerViewDelegate>

{
    NSMutableArray *arrAddPlaylistName;
    NSString *song_idForPlaylist;
    NSMutableArray *arr_playlistAllsongs;
    NSMutableArray *arrDownloadAllsongs;
    NSMutableArray *arrfavoritelist;
    bool ischecked;
    
     NSArray *_products;
    //    ============== playlist popup ========//

    UIAlertView *alert;
    UIAlertView *newplaylistalert;
    NSString *playlistname;
    NSString *song_id;
    NSMutableArray *arr_playlist;
}

//==== player bar=====
@property (strong, nonatomic) IBOutlet UIButton *btn_favorite;
@property (strong, nonatomic) IBOutlet UIButton *btn_playlist;
@property (strong, nonatomic) IBOutlet UIButton *btn_download;
@property (strong, nonatomic) IBOutlet UIButton *btn_playpause;

@property(weak,nonatomic) IBOutlet GADBannerView *adBannerView;

@property(weak,nonatomic) IBOutlet UIView *viewPlayerBar;

@property(weak,nonatomic) IBOutlet UILabel *lblPlayerBarTitle;

-(IBAction)btnPlayerBarPressed:(id)sender;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottom_constraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottom_constraint_free;

//===end===
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *search_width_layout;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *search_height_layout;
@property (strong, nonatomic) IBOutlet UIButton *btn_search;
@property(weak,nonatomic) IBOutlet UITableView *tblDetail;

@property(strong,nonatomic) NSMutableArray *arrSectionDetail;

@property(strong,nonatomic) NSString *sectionName;
@property (strong, nonatomic) IBOutlet UIView *view_language;



@property(weak,nonatomic) IBOutlet UIButton *btnBackNavigation;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *menuWconstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *menuHconstraint;

-(IBAction)btnBackPressed:(id)sender;

@property(weak,nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;

@property(weak,nonatomic) IBOutlet UIButton *btnHindi;

@property(weak,nonatomic) IBOutlet UIButton *btnSanskrit;
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) CGFloat lastContentOffset;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *view_lng_Hconstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *view_lng_Wconstraint;



@end








