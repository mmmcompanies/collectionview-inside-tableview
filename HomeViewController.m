//
//  HomeViewController.m
//  MPlayer
//
//  Created by Techno Softwares on 27/09/16.
//  Copyright © 2016 Techno Softwares. All rights reserved.
//

#import "HomeViewController.h"
#import "Global.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "SCLAlertView.h"
#import "Reachability.h"
#import "ViewController.h"
#import "detailView.h"
#import "CollectionViewCell.h"

#import "TableViewCell.h"

@interface HomeViewController ()
{
    NSMutableArray *arrSongs;
    NSMutableArray *arrHindiSongs;
    NSMutableArray *arrSanskritSongs;
    NSMutableArray *arrForTblVRow;
    BOOL isConstraintUpdated,isHindi,isSearching;
    
    UIImageView *imgPlay;
    
    NSIndexPath *selectedIndex;
    NSString *selectedSectionname;
    NSString *selectedmain_category;
    Global *global;
    BOOL isNoThanksClicked;
}

@end

@implementation HomeViewController
@synthesize viewPlayerBar;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    global = [Global sharedInstance];
    
    self.navigationController.navigationBar.hidden = YES;
    
        MVYSideMenuController *sideMenu = [self sideMenuController];
        if (sideMenu) {
            [sideMenu disable];
        }

    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
       
    }
    else
    {
//        [aButton setImageEdgeInsets:UIEdgeInsetsMake(2, -200, 2, 2)];
    }
   
    
//    [_tblDetail registerClass:[TableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    
    
    [_tblDetail registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"TableViewCell"];
    _tblDetail.backgroundColor = [UIColor clearColor];
    [_tblDetail setShowsHorizontalScrollIndicator:NO];
    [_tblDetail setShowsVerticalScrollIndicator:NO];
    
    arrHindiSongs   = [[NSMutableArray alloc]init];
    arrSanskritSongs = [[NSMutableArray alloc]init];
    arrForTblVRow = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddBannerView) name:@"ShowAdView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAddBannerView) name:@"HideAdView" object:nil];
    
    [_btnHindi addTarget:self action:@selector(btnHindiPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnSanskrit addTarget:self action:@selector(btnSanskritPressed) forControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"%@",global.languagename);
    
    if ([global.languagename isEqualToString:@"Hindi"])
    {
        [_btnSanskrit setBackgroundColor:[UIColor whiteColor]];
        [_btnSanskrit setTitleColor:[UIColor colorWithRed:(185/255.0) green:(19/255.0) blue:(28/255.0) alpha:1.0] forState:UIControlStateNormal];
        isHindi = YES;
   
    }
    else
    {
        isHindi = NO;
        [_btnHindi setBackgroundColor:[UIColor whiteColor]];
        [_btnHindi setTitleColor:[UIColor colorWithRed:(185/255.0) green:(19/255.0) blue:(28/255.0) alpha:1.0] forState:UIControlStateNormal];
        
        [_btnSanskrit setBackgroundColor:[UIColor colorWithRed:(185/255.0) green:(19/255.0) blue:(28/255.0) alpha:1.0]];
        [_btnSanskrit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    for(int i=0;i<global.arrSongs.count;i++)
    {
        if([[[global.arrSongs objectAtIndex:i] objectForKey:@"language"] isEqualToString:@"hindi"])
        {
            [arrHindiSongs addObject:[global.arrSongs objectAtIndex:i]];
        }
        else if([[[global.arrSongs objectAtIndex:i] objectForKey:@"language"] isEqualToString:@"sanskrit"])
        {
            [arrSanskritSongs addObject:[global.arrSongs objectAtIndex:i]];
        }

    }
    if (isHindi) {
         [arrForTblVRow addObjectsFromArray:arrHindiSongs];
    }
    else{
         [arrForTblVRow addObjectsFromArray:arrSanskritSongs];
    }
   
    // Do any additional setup after loading the view.
    
    _arrSectionDetail = [NSMutableArray new];
    
//    [_arrSectionDetail addObject:[global.arrSongs objectAtIndex:0]];
    
    for(int i=0;i<arrHindiSongs.count;i++)
    {
        NSString *section = [[arrHindiSongs objectAtIndex:i] objectForKey:@"main_category"];
        BOOL isFound = NO;
        for(int j=0;j<_arrSectionDetail.count;j++)
        {
            if([[[_arrSectionDetail objectAtIndex:j] objectForKey:@"main_category"] isEqualToString:section])
            {
                isFound = YES;
                break;
            }
        }
        
        if(!isFound)
        {
            [_arrSectionDetail addObject:[arrHindiSongs objectAtIndex:i]];
        }
    }
    
    int checkFor24Hrs = 0;
    BOOL needToShow = NO;
    double timeStamp;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastratetimestamp"])
    {
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"Rated"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"NoThanks"])
        {
            needToShow = NO;
        }
        else
        {
            needToShow = YES;
        }
    }
    else
    {
        double lastTImeStamp = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setValue:[@(lastTImeStamp) stringValue] forKey:@"lastratetimestamp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        timeStamp = 0;
        needToShow = YES;
    }
    
    if(needToShow)
    {
        double lastTImeStamp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastratetimestamp"] doubleValue];
        timeStamp = ([[NSDate date] timeIntervalSince1970]);
        checkFor24Hrs = timeStamp - lastTImeStamp;
        if(checkFor24Hrs >= (SECONDS_IN_24HRS * 5))
        {
            [self showRateNowPopup];
        }
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    isSearching = NO;
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [imgPlay.layer removeAllAnimations];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadPlayer" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RateAppNoThanks" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    viewPlayerBar.hidden = YES;
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
    if (userid) {
        [self playlistname];
    }
    
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"user_type"] isEqualToString:@"paid"])
    {
        _adBannerView.autoloadEnabled = NO;

        if(global.isPlaying)
        {
            [self.btn_playpause setImage: global.playpause.imageView.image forState:UIControlStateNormal] ;
            viewPlayerBar.hidden = NO;
            
            _lblPlayerBarTitle.text = global.lblPlayBarTitle.text;
            _lblPlayerBarTitle.font = global.lblPlayBarTitle.font;
            
            global.playpause = self.btn_playpause;
            global.favorite = self.btn_favorite;
            global.playlist = self.btn_playlist;
            global.download = self.btn_download;
            global.lblPlayBarTitle =  _lblPlayerBarTitle ;
            
            [self.btn_favorite setImage:[UIImage imageNamed:@"favorite_white"] forState:UIControlStateNormal];
            [self.btn_playlist setImage:[UIImage imageNamed:@"playlist_white"] forState:UIControlStateNormal];
            [self.btn_download setImage:[UIImage imageNamed:@"download_white"] forState:UIControlStateNormal];
            NSString *song_Id = [[global.arrPlaySection objectAtIndex:[[global currentSongIndex] row]] objectForKey:@"id"];
            for(int i=0;i<global.arrfavoritelist.count;i++)
            {
                
                if([[[global.arrfavoritelist objectAtIndex:i] objectForKey:@"id"] isEqualToString:song_Id])
                {
                    NSLog(@"chane favorite");
                    [self.btn_favorite setImage:[UIImage imageNamed:@"favorite_done"] forState:UIControlStateNormal];
                    break;
                }
            }
            
            for(int i=0;i<global.arr_playlistAllsongs.count;i++)
            {
                if([[[global.arr_playlistAllsongs objectAtIndex:i] objectForKey:@"id"] isEqualToString:song_Id])
                {
                    NSLog(@"chane playlist icon");
                    [self.btn_playlist setImage:[UIImage imageNamed:@"playlist_done"] forState:UIControlStateNormal];
                    break;
                }
            }
            
            for(int i=0;i<global.arrDownloadAllsongs.count;i++)
            {
                
                if([[[global.arrDownloadAllsongs objectAtIndex:i] objectForKey:@"id"] isEqualToString:song_Id])
                {
                    NSString *Path =[global LoadSongFromLocal:[NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/%@",[[global.arrPlaySection objectAtIndex:[[global currentSongIndex] row]] objectForKey:@"url"]]] ;
                    if ([Path isEqualToString:@"no"] )
                    {
                        
                    }
                    else
                    {
                        NSLog(@"chane download icon");
                        [self.btn_download setImage:[UIImage imageNamed:@"download_done"] forState:UIControlStateNormal];
                    }
                    break;
                }
            }
            

            
            if (IS_IPAD)
            {
                self.bottom_constraint.constant = -90;
            }
            else
            {
                self.bottom_constraint.constant = -52;
            }
            
        }
        else
        {
            if (IS_IPAD)
            {
                self.bottom_constraint.constant = -170;
            }
            else
            {
                self.bottom_constraint.constant = -117;
            }

        }

    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAdView" object:nil];
        NSLog(@"AD id %@",global.ADUnitID);
        _adBannerView.adUnitID = global.ADUnitID;
        _adBannerView.rootViewController = self;
        GADRequest *request = [GADRequest request];
        
//        request.testDevices = @[ @"GAD_SIMULATOR_ID" , @"a4215e0e1537ba53c3924696e7e5d30165025ef0",@"8b2ba0c94dc7243659657dccdae5157a101c5dc2",];
        
        [_adBannerView loadRequest:[GADRequest request]];
        
        if(global.isPlaying)
        {
            [self.btn_playpause setImage: global.playpause.imageView.image forState:UIControlStateNormal] ;
            viewPlayerBar.hidden = NO;
            
            _lblPlayerBarTitle.text = global.lblPlayBarTitle.text;
            _lblPlayerBarTitle.font = global.lblPlayBarTitle.font;
            
            global.playpause = self.btn_playpause;
            global.favorite = self.btn_favorite;
            global.playlist = self.btn_playlist;
            global.download = self.btn_download;
            global.lblPlayBarTitle =  _lblPlayerBarTitle ;

            
            if (IS_IPAD)
            {
                self.bottom_constraint_free.constant = 0;
            }
            else
            {
                self.bottom_constraint_free.constant = 0;
            }
            
        }
        else
        {
            if (IS_IPAD)
            {
                self.bottom_constraint_free.constant = -80;
            }
            else
            {
                self.bottom_constraint_free.constant = -65;
            }
            
        }

    
    }
        switch ((int)[UIScreen mainScreen].bounds.size.height) {
        case 480:
        {
            if(!isConstraintUpdated)
            {
                //_lblListOfferings.font = [UIFont fontWithName:@"Euphemia UCAS" size:17.0];
                isConstraintUpdated = YES;
                
                _view_lng_Hconstraint.constant = 48.0;
                _view_lng_Wconstraint.constant = 280.0;
                self.view_language.frame = CGRectMake(0.0, 0.0, 280.0, 48.0);
                self.tblDetail.frame = CGRectMake(0.0, 0.0, 280.0, 48.0);

            }
            break;
        }
        case 568:
        {
            if(!isConstraintUpdated)
            {
                
                //_lblListOfferings.font = [UIFont fontWithName:@"Euphemia UCAS" size:17.0];
                isConstraintUpdated = YES;
                
                _view_lng_Hconstraint.constant = 56.8;
                _view_lng_Wconstraint.constant = 280.0;
                self.view_language.frame = CGRectMake(0.0, 0.0, 280.0, 56.8);
                self.tblDetail.frame = CGRectMake(0.0, 0.0, 280.0, 56.8 );

            }
            break;
        }
        case 667:
        {
            if(!isConstraintUpdated)
            {
              
                _headerHeightConstraint.constant = _headerHeightConstraint.constant+5;
                _search_width_layout.constant = _search_width_layout.constant+5;
                _search_height_layout.constant = _search_height_layout.constant+5;
                //_lblListOfferings.font = [UIFont fontWithName:@"Euphemia UCAS" size:19.0];
                _btnBackNavigation.imageEdgeInsets = UIEdgeInsetsMake(7, 10, 7, 42);
                
                isConstraintUpdated = YES;
                
                _view_lng_Hconstraint.constant = 66.7;
                _view_lng_Wconstraint.constant = 328.125;
                self.view_language.frame = CGRectMake(0.0, 0.0, 328.125, 66.7);
                self.tblDetail.frame = CGRectMake(0.0, 0.0, 328.125, 66.7);

                
            }
            break;
        }
        case 736:
        {
            if(!isConstraintUpdated)
            {
                 _headerHeightConstraint.constant = _headerHeightConstraint.constant+15;
                _search_width_layout.constant = _search_width_layout.constant+10;
                _search_height_layout.constant = _search_height_layout.constant+10;
                _btnBackNavigation.imageEdgeInsets = UIEdgeInsetsMake(7, 10, 7, 44);
                isConstraintUpdated = YES;
                
                _view_lng_Hconstraint.constant = 73.6;
                _view_lng_Wconstraint.constant = 362.25;
                self.view_language.frame = CGRectMake(0.0, 0.0, 362.25, 73.6);
                self.tblDetail.frame = CGRectMake(0.0, 0.0, 362.25, 73.6);

                
            }
            break;
        }
        case 1024:
        {
            if(!isConstraintUpdated)
            {
                _headerHeightConstraint.constant = _headerHeightConstraint.constant+35;
                _btnBackNavigation.imageEdgeInsets = UIEdgeInsetsMake(5, 16, 5, 50);
                isConstraintUpdated = YES;
                
                _view_lng_Hconstraint.constant = 102.4;
                _view_lng_Wconstraint.constant = 672.0;
                self.view_language.frame = CGRectMake(0.0, 0.0, 672.0, 102.4);
                self.tblDetail.frame = CGRectMake(0.0, 0.0, 672.0, 102.4);
            }
            break;
        }
            
        default:
            break;
    }
   
    NSLog(@"%f", _view_lng_Hconstraint.constant);
    
    NSLog(@"%@",self.tblDetail);
    NSLog(@"%f",_view_lng_Wconstraint.constant);
    
    
    
    [self.tblDetail.parallaxView setDelegate:self];
    [self.tblDetail addParallaxWithView:self.view_language andHeight:_view_lng_Hconstraint.constant andShadow:NO];

    [self.view layoutIfNeeded];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPlayerScreen) name:@"LoadPlayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noThanksClicked) name:@"RateAppNoThanks" object:nil];
    
    //    if([Reachability reachabilityForLocalWiFi])
    //    {
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    //    }
}

#pragma mark - Custom Alert View

- (void)showRateNowPopup
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    [alert addButton:@"YES, Rate Mobile Pandit" target:self selector:@selector(rateNowClicked)];
    
    SCLButton *remindLater = [alert addButton:@"Remind me Later" target:self selector:@selector(remindLaterClicked)];
    remindLater.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        
        buttonConfig[@"backgroundColor"] = [UIColor whiteColor];
        buttonConfig[@"textColor"] = [UIColor blackColor];
        buttonConfig[@"borderWidth"] = @2.0f;
        buttonConfig[@"borderColor"] = UIColorFromHEX(0xB9131C);//[UIColor greenColor];
        
        return buttonConfig;
    };
    
    [alert showSuccess:@"Rate App" subTitle:@"If you are satisfied using Mobile Pandit kindly spare a moment to rate.\n Thanks for your Patronage!" closeButtonTitle:@"No Thanks" duration:0.0f];
    isNoThanksClicked = YES;
}

#pragma mark - Custom Alert Button Selector

- (void)rateNowClicked
{
    NSString *itunes = @"itms://itunes.apple.com/us/app/apple-store/id1087881143?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunes]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Rated"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    isNoThanksClicked = NO;
}

- (void)remindLaterClicked
{
    double lastTImeStamp = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setValue:[@(lastTImeStamp) stringValue] forKey:@"lastratetimestamp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    isNoThanksClicked = NO;
}

- (void)noThanksClicked
{
    if(isNoThanksClicked)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NoThanks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Load Player Screen

- (void)loadPlayerScreen
{
    [self.navigationController pushViewController:global.playerViewController animated:YES];
}

#pragma mark - Back Button Pressed

-(IBAction)btnBackPressed:(id)sender
{
    MVYSideMenuController *sideMenu = [self sideMenuController];
    if (sideMenu) {
        [sideMenu openMenu];
    }
}

#pragma mark
#pragma mark-TableView Methods

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
        UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = [UIColor clearColor];
    
    v.textLabel.backgroundColor = [UIColor clearColor];
    v.textLabel.textColor = [UIColor colorWithRed:183.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0];
   
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _arrSectionDetail.count;
    
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [[_arrSectionDetail objectAtIndex:section] objectForKey:@"main_category"];
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewCell";
    TableViewCell *cell = (TableViewCell *)[_tblDetail dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.lbl_title.text = [[_arrSectionDetail objectAtIndex:indexPath.section] objectForKey:@"main_category"];
    return cell;
}

-(void)rotateAnimationOnImageView:(UIImageView *)imgView
{
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    rotateAnimation.cumulative = YES;
    rotateAnimation.duration = 8.0;
    rotateAnimation.repeatCount = INFINITY;
    [imgView.layer addAnimation:rotateAnimation forKey:@"size"];
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    selectedIndex = indexPath;
//    
//    [self performSegueWithIdentifier:@"sublist" sender:self];
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return 350;
    }
    
    return 220;
   
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(TableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    
}


#pragma mark - UICollectionViewDataSource Methods
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 30.0); // top, left, bottom, right
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 30; // This is the minimum inter item spacing, can be more
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(((CGRectGetHeight(collectionView.frame)) - (CGRectGetHeight(collectionView.frame))/4.5), (CGRectGetHeight(collectionView.frame)));
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%ld",(long)collectionView.tag);
    NSString *temp = [[_arrSectionDetail objectAtIndex:collectionView.tag] objectForKey:@"main_category"];
    
    NSMutableArray *sectionSongs = [[NSMutableArray alloc]init];
    
    for(int i=0;i<arrForTblVRow.count;i++)
    {
        if([[[arrForTblVRow objectAtIndex:i] objectForKey:@"main_category"] isEqualToString:temp])
        {
            [sectionSongs addObject:[arrForTblVRow objectAtIndex:i]];
        }
    }
    
    NSMutableArray *arrSections = [[NSMutableArray alloc]init];
    for(int i=0;i<sectionSongs.count;i++)
    {
        NSString *section = [[sectionSongs objectAtIndex:i] objectForKey:@"section"];
        BOOL isFound = NO;
        for(int j=0;j<arrSections.count;j++)
        {
            if([[[arrSections objectAtIndex:j] objectForKey:@"section"] isEqualToString:section])
            {
                isFound = YES;
                break;
            }
        }
        
        if(!isFound)
        {
            [arrSections addObject:[sectionSongs objectAtIndex:i]];
        }
        
    }

    
    return arrSections.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    
//    cell.backgroundColor = [UIColor whiteColor];
    NSString *temp = [[_arrSectionDetail objectAtIndex:collectionView.tag] objectForKey:@"main_category"];
    
    NSMutableArray *sectionSongs = [[NSMutableArray alloc]init];
    
    for(int i=0;i<arrForTblVRow.count;i++)
    {
        if([[[arrForTblVRow objectAtIndex:i] objectForKey:@"main_category"] isEqualToString:temp])
        {
            [sectionSongs addObject:[arrForTblVRow objectAtIndex:i]];
        }
    }
    
    NSMutableArray *arrSections = [[NSMutableArray alloc]init];
    for(int i=0;i<sectionSongs.count;i++)
    {
        NSString *section = [[sectionSongs objectAtIndex:i] objectForKey:@"section"];
        BOOL isFound = NO;
        for(int j=0;j<arrSections.count;j++)
        {
            if([[[arrSections objectAtIndex:j] objectForKey:@"section"] isEqualToString:section])
            {
                isFound = YES;
                break;
            }
        }
        
        if(!isFound )
        {
            [arrSections addObject:[sectionSongs objectAtIndex:i]];
        }
        
    }


    
    cell.lbl_songname.text = [[arrSections objectAtIndex:indexPath.row] objectForKey:@"section"];
    
    NSString *imgName = [[arrSections objectAtIndex:indexPath.row] objectForKey:@"image"];
    
    imgName = [NSString stringWithFormat:@"%@_200.png",imgName];
    
    NSString *url = [NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/song_image/200/%@",imgName];
    
    [global checkImageInLocalDirectory:imgName WithUrl:url OnImageView:cell.img_song];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {

    
    for (CollectionViewCell *Cell in (CollectionViewCell*)[collectionView visibleCells])
    {
        Cell.img_song.layer.borderColor =  [UIColor colorWithRed:237.0/255.0 green:199.0/255.0 blue:121.0/255.0 alpha:1.0].CGColor;
    }
    
    CollectionViewCell *datasetCell =(CollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
     datasetCell.img_song.layer.borderColor =  [UIColor colorWithRed:183.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0].CGColor; // highlight selection

    
    NSString *temp = [[_arrSectionDetail objectAtIndex:collectionView.tag] objectForKey:@"main_category"];
    NSMutableArray *sectionSongs = [[NSMutableArray alloc]init];
    
    for(int i=0;i<arrForTblVRow.count;i++)
    {
        if([[[arrForTblVRow objectAtIndex:i] objectForKey:@"main_category"] isEqualToString:temp])
        {
            [sectionSongs addObject:[arrForTblVRow objectAtIndex:i]];
        }
    }
    
    NSMutableArray *arrSections = [[NSMutableArray alloc]init];
    for(int i=0;i<sectionSongs.count;i++)
    {
        NSString *section = [[sectionSongs objectAtIndex:i] objectForKey:@"section"];
        BOOL isFound = NO;
        for(int j=0;j<arrSections.count;j++)
        {
            if([[[arrSections objectAtIndex:j] objectForKey:@"section"] isEqualToString:section])
            {
                isFound = YES;
                break;
            }
        }
        
        if(!isFound )
        {
            [arrSections addObject:[sectionSongs objectAtIndex:i]];
        }
        
    }

    selectedSectionname = [[arrSections objectAtIndex:indexPath.row] objectForKey:@"section"];
    selectedIndex = indexPath;
    selectedmain_category = temp;
    
    [self performSegueWithIdentifier:@"section" sender:self];
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SectionView *secDetail = segue.destinationViewController;
    
    secDetail.arrSelectedSection = [NSMutableArray new];
    
    secDetail.main_category = selectedmain_category;
    secDetail.SectionIndexpath = selectedIndex;
    secDetail.isselectedlanguage = isHindi;
    secDetail.sectionName = selectedSectionname;
    
    
    for(int i=0;i<global.arrSongs.count;i++)
    {
        if([selectedmain_category isEqualToString:[[global.arrSongs objectAtIndex:i] objectForKey:@"main_category"]])
        {
            [secDetail.arrSelectedSection addObject:[global.arrSongs objectAtIndex:i]];
        }
    }
    
}

#pragma mark
#pragma mark Hindi Sanskrit Button Action

-(void)btnHindiPressed
{
    isHindi = YES;
    
    [arrForTblVRow removeAllObjects];
    [_arrSectionDetail removeAllObjects];
    
    for(int i=0;i<arrHindiSongs.count;i++)
    {
        NSString *section = [[arrHindiSongs objectAtIndex:i] objectForKey:@"main_category"];
        BOOL isFound = NO;
        for(int j=0;j<_arrSectionDetail.count;j++)
        {
            if([[[_arrSectionDetail objectAtIndex:j] objectForKey:@"main_category"] isEqualToString:section])
            {
                isFound = YES;
                break;
            }
        }
        
        if(!isFound)
        {
            [_arrSectionDetail addObject:[arrHindiSongs objectAtIndex:i]];
        }
    }
  
    [arrForTblVRow addObjectsFromArray:arrHindiSongs];

    [_tblDetail reloadData];
    
    [_btnSanskrit setBackgroundColor:[UIColor whiteColor]];
    [_btnSanskrit setTitleColor:[UIColor colorWithRed:(185/255.0) green:(19/255.0) blue:(28/255.0) alpha:1.0] forState:UIControlStateNormal];
    
    [_btnHindi setBackgroundColor:[UIColor colorWithRed:(185/255.0) green:(19/255.0) blue:(28/255.0) alpha:1.0]];
    [_btnHindi setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void)btnSanskritPressed
{
    isHindi = NO;
    
    [arrForTblVRow removeAllObjects];
    [_arrSectionDetail removeAllObjects];
    
    for(int i=0;i<arrSanskritSongs.count;i++)
    {
        NSString *section = [[arrSanskritSongs objectAtIndex:i] objectForKey:@"main_category"];
        BOOL isFound = NO;
        for(int j=0;j<_arrSectionDetail.count;j++)
        {
            if([[[_arrSectionDetail objectAtIndex:j] objectForKey:@"main_category"] isEqualToString:section])
            {
                isFound = YES;
                break;
            }
        }
        
        if(!isFound)
        {
            [_arrSectionDetail addObject:[arrSanskritSongs objectAtIndex:i]];
        }
    }
    
    [arrForTblVRow addObjectsFromArray:arrSanskritSongs];
    [_tblDetail reloadData];
    
    [_btnHindi setBackgroundColor:[UIColor whiteColor]];
    [_btnHindi setTitleColor:[UIColor colorWithRed:(185/255.0) green:(19/255.0) blue:(28/255.0) alpha:1.0] forState:UIControlStateNormal];
    
    [_btnSanskrit setBackgroundColor:[UIColor colorWithRed:(185/255.0) green:(19/255.0) blue:(28/255.0) alpha:1.0]];
    [_btnSanskrit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark
#pragma mark player screen

- (void)showAddBannerView
{
    [_adBannerView setHidden:NO];
}

- (void)hideAddBannerView
{
    [_adBannerView setHidden:YES];
}
-(IBAction)btnPlayerBarPressed:(id)sender
{
    if(global.playerViewController)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadPlayer" object:nil];
        //        [self presentViewController:global.playerViewController animated:YES completion:nil];
    }
}

-(IBAction)btn_1Action:(id)sender
{
    song_id = [[global.arrPlaySection objectAtIndex:[[global currentSongIndex] row]] objectForKey:@"id"];
    NSString *usertype =  [[NSUserDefaults standardUserDefaults] stringForKey:@"user_type"];
    
    if ([usertype isEqualToString:@"paid"])
    {
        UIButton *button = (UIButton*)sender;
        UIImage *image1 = [UIImage imageNamed:@"favorite_red"];
        
        bool compare = [self firstimage:button.imageView.image isEqualTo:image1];
        
        if (compare)
        {
            [sender setImage:[UIImage imageNamed:@"favorite_ok"] forState:UIControlStateNormal];
            [self addToFavorite:song_id];
        }
        else
        {
            [sender setImage:[UIImage imageNamed:@"favorite_red"] forState:UIControlStateNormal];
            [self deletefavorite:song_id];
        }
        
    }
    else
    {
        CustomAlertView *contentVC = [[CustomAlertView alloc]init];
        contentVC.delegate = self;
        contentVC.definesPresentationContext = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"Favorite" forKey:@"Item_value"];
        contentVC.view.backgroundColor = [UIColor clearColor];
        contentVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:contentVC animated:YES completion:nil];

    }
    
}
-(IBAction)btn_2Action:(id)sender
{
    song_id = [[global.arrPlaySection objectAtIndex:[[global currentSongIndex] row]] objectForKey:@"id"];
    NSString *usertype =  [[NSUserDefaults standardUserDefaults] stringForKey:@"user_type"];
    if ([usertype isEqualToString:@"paid"])
    {
        CustomPlaylistView *contentVC = [[CustomPlaylistView alloc]init];
        contentVC.definesPresentationContext = YES;
       
        [[NSUserDefaults standardUserDefaults] setValue:song_id forKey:@"songid"];
        
        contentVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        contentVC.view.backgroundColor = [UIColor clearColor];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:contentVC animated:YES completion:nil];
    }
    else
    {
        CustomAlertView *contentVC = [[CustomAlertView alloc]init];
        contentVC.delegate = self;
        contentVC.definesPresentationContext = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"Playlist" forKey:@"Item_value"];
        contentVC.view.backgroundColor = [UIColor clearColor];
        contentVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:contentVC animated:YES completion:nil];

    }
    
    
}
-(BOOL)BlankTextValidation:(NSString*)text
{
    
    if ([text isEqualToString:@""])
    {
        return false;
    }
    else
    {
        return true;
        
    }
}

-(BOOL)firstimage:(UIImage *)image1 isEqualTo:(UIImage *)image2 {
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqualToData:data2];
}

-(IBAction)btn_3Action:(id)sender
{
    NSString *usertype =  [[NSUserDefaults standardUserDefaults] stringForKey:@"user_type"];
    if ([usertype isEqualToString:@"paid"])
    {
       
        song_id = [[global.arrPlaySection objectAtIndex:[[global currentSongIndex] row]] objectForKey:@"id"];
        
        NSString *Path =[global LoadSongFromLocal:[NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/%@",[[global.arrPlaySection objectAtIndex:[[global currentSongIndex] row]] objectForKey:@"url"]]] ;
        if ([Path isEqualToString:@"no"] )
        {
            
            alert = [[UIAlertView alloc]initWithTitle:@"Mobile Pandit" message:NSLocalizedString(@"Your Song is Downloading...", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Continue", nil) otherButtonTitles:nil, nil];
            
            [alert show];
            BOOL result = [global downloadsong:[NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/%@",[[global.arrPlaySection objectAtIndex:[[global currentSongIndex] row]] objectForKey:@"url"]]];
            if (result)
            {
                NSLog(@"%D",result);
                
                [sender setImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
                [self addToDownload:song_id];
            }
            else
            {
               
            }
            
        }
        
        else
        {
            
            
        }
        
    }
    else
    {
        CustomAlertView *contentVC = [[CustomAlertView alloc]init];
        contentVC.delegate = self;
        contentVC.definesPresentationContext = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"Download" forKey:@"Item_value"];
        contentVC.view.backgroundColor = [UIColor clearColor];
        contentVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:contentVC animated:YES completion:nil];

    }
}
-(IBAction)btn_4Action:(id)sender
{
    
    UIButton *button = (UIButton*)sender;
    UIImage *image1 = [UIImage imageNamed:@"play_white"];
    
    bool compare = [self firstimage:button.imageView.image isEqualTo:image1];
    
    if (compare)
    {
        [sender setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"play_white"] forState:UIControlStateNormal];
    }
    
    ViewController *myVc =  (ViewController *)global.playerViewController;
    
    NSLog(@"%ld",(long)[[global audioPlayer] state]);
    
    if([[global audioPlayer] state] == STKAudioPlayerStatePaused)
    {
        [global.audioPlayer resume];
        [myVc enableTimer:YES];
        
        global.playStatus = global.playStatusOld;
        
        if([global.playStatus containsString:@"bell"])
        {
            [global.playerBell play];
        }
        else if([global.playStatus containsString:@"tanpura"])
        {
            [global.playerTanpura play];
        }
        else if([global.playStatus containsString:@"om"])
        {
            [global.playerOm play];
        }
        
        //         [myVc.btnPlay setImage:[UIImage imageNamed:@"playerpause"] forState:UIControlStateNormal];
    }
    else if([[global audioPlayer] state] == 3)
    {
        
        [global.audioPlayer pause];
        
        [myVc enableTimer:NO];
        
        global.playStatusOld = global.playStatus;
        global.playStatus = @"pause";
        
        [global.playerBell pause];
        [global.playerOm pause];
        [global.playerTanpura pause];
        
        //        [myVc.btnPlay setImage:[UIImage imageNamed:@"playerplay"] forState:UIControlStateNormal];
    }
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}



#pragma mark
#pragma mark playlist name

-(void)playlistname
{
    if([global isConnectedToInternet])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager.requestSerializer setTimeoutInterval:30];
        
        //    http://mplayer.tridentsoftech.com/fetch_user_playlists.php?user_id=5
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        
        NSString *url = [NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/fetch_user_playlists.php"];
        NSDictionary *parameter;
        parameter = @{@"user_id":userid};
        
        [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
           NSLog(@"url:%@ with paramiter = %@   JSONresponce :== %@",url,parameter,responseObject);
            NSArray *temp;
            if([responseObject isKindOfClass:[NSArray class]])
            {
                temp = responseObject;
                
            }
            
            arr_playlist= [[NSMutableArray alloc]init];
            //            [arr_playlist addObject:@"NEW"];
            //            [arrplaylist addObjectsFromArray:[responseObject objectForKey:@"user_playlist"]];
            
            NSArray *tenmp = [responseObject objectForKey:@"user_playlist"];
            
            if (tenmp.count == 0)
            {
                
            }
            else
            {
                for (int i = 0; i<tenmp.count; i++) {
                    NSString *obj = [[tenmp objectAtIndex:i] objectForKey:@"playlist_name"];
                    [arr_playlist addObject:obj];
                    
                }
                
            }
            
            [self UserFavorites];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(error.code == 3840)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Internal Server Error, Try Again", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            else
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Weak internet connection", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            
            NSLog(@"Error: %@", error);
        }];
        
    }
    
    
    
}
#pragma mark
#pragma mark Add to playlist web service
-(void)addtoplaylist:(NSString*)songid
{
    if([global isConnectedToInternet])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager.requestSerializer setTimeoutInterval:30];
        
        //           http://mplayer.tridentsoftech.com/insert_muilti_playlists_songs.php?user_id=199&playlist_name=xyz1,krishna&song_id=11
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        
        NSString *url = [NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/insert_muilti_playlists_songs.php"];
        NSDictionary *parameter;
        parameter = @{@"user_id":userid,@"playlist_name":playlistname,@"song_id":songid};
        
        [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
             NSLog(@"url:%@ with paramiter = %@   JSONresponce :== %@",url,parameter,responseObject);
            
            if ([[responseObject objectForKey:@"result"] isEqualToString:@"success"])
            {
                [self.view endEditing:YES];
                [self updateviewController];
                alert = [[UIAlertView alloc]initWithTitle:@"Mobile Pandit" message:[NSString stringWithFormat:@"Your Song add to your %@",playlistname] delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                [alert show];
            }
            if ([[responseObject objectForKey:@"result"] isEqualToString:@"Email not exists!"])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Mobile Pandit" message:NSLocalizedString(@"Email not exists Please Sign Up First.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                [alert show];
            }
            
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(error.code == 3840)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Internal Server Error, Try Again", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            else
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Weak internet connection", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            
            NSLog(@"Error: %@", error);
        }];
        
    }
    
}


#pragma mark
#pragma mark User Favorites web service
-(void)UserFavorites
{
    if([global isConnectedToInternet])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager.requestSerializer setTimeoutInterval:30];
        
        //    http://mplayer.tridentsoftech.com/fetch_user_playlists.php?user_id=5
        
        
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        
        NSString *url = [NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/favourite_user_detail.php"];
        NSDictionary *parameter;
        parameter = @{@"user_id":userid};
        
        [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
             NSLog(@"url:%@ with paramiter = %@   JSONresponce :== %@",url,parameter,responseObject);
             NSString *result = [NSString stringWithFormat:@"%@",[responseObject  objectForKey:@"result"]];
            if ([result isEqualToString:@"success"])
                
                
            {
                arrfavoritelist = [[NSMutableArray alloc]init];
                
                [arrfavoritelist addObjectsFromArray:[responseObject objectForKey:@"favourite_songs"]];
                
                global.arrfavoritelist = [responseObject objectForKey:@"favourite_songs"];
                 [self UserDownloads];
                
            }
            else
            {
                
            }
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self UserDownloads];
            if(error.code == 3840)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Internal Server Error, Try Again", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            else
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Weak internet connection", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            
            NSLog(@"Error: %@", error);
        }];
        
    }
    
    
    
}

#pragma mark
#pragma mark update view controller

-(void)updateviewController
{
    [self playlistname];
}

-(void)loadtbldata
{
    
}

#pragma mark
#pragma mark User playlists songs web service
-(void)UserPlaylistAllsong
{
    if([global isConnectedToInternet])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager.requestSerializer setTimeoutInterval:30];
        
        //          http://mplayer.tridentsoftech.com/fetch_playlist_songs.php?user_id=5
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        
        NSString *url = [NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/fetch_playlist_songs.php"];
        NSDictionary *parameter;
        parameter = @{@"user_id":userid};
        
        [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
             NSLog(@"url:%@ with paramiter = %@   JSONresponce :== %@",url,parameter,responseObject);
            
            arr_playlistAllsongs = [[NSMutableArray alloc]init];
            [arr_playlistAllsongs addObjectsFromArray:responseObject];
            global.arr_playlistAllsongs = responseObject;
            
           
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(error.code == 3840)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Internal Server Error, Try Again", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            else
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Weak internet connection", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            
            NSLog(@"Error: %@", error);
        }];
        
    }
    
}

#pragma mark
#pragma mark User Favorites web service
-(void)UserDownloads
{
    if([global isConnectedToInternet])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager.requestSerializer setTimeoutInterval:30];
        
        //          http://mplayer.tridentsoftech.com/fetch_user_song_downloads.php?user_id=5
        
        
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        
        NSString *url = [NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/fetch_user_song_downloads.php"];
        NSDictionary *parameter;
        parameter = @{@"user_id":userid};
        
        [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
             NSLog(@"url:%@ with paramiter = %@   JSONresponce :== %@",url,parameter,responseObject);
            
            //             result = fail;result = success;
            //            "user_downloads" =
            
            NSString *result = [NSString stringWithFormat:@"%@",[responseObject  objectForKey:@"result"]];
            
            if ([result isEqualToString:@"success"]) {
                NSArray *tenmp = [responseObject objectForKey:@"user_downloads"];
                arrDownloadAllsongs = [[NSMutableArray alloc]init];
                [arrDownloadAllsongs addObjectsFromArray:tenmp];
                global.arrDownloadAllsongs = tenmp;
                
                [self UserPlaylistAllsong];
            }
            else
            {
                
                
            }
            
            [self loadtbldata];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self UserPlaylistAllsong];
            if(error.code == 3840)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Internal Server Error, Try Again", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            else
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Weak internet connection", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            
            NSLog(@"Error: %@", error);
        }];
        
    }
    
}

#pragma mark
#pragma addto favorite
-(void)addToFavorite:(NSString*)sond_id
{
    if([global isConnectedToInternet])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager.requestSerializer setTimeoutInterval:30];
        
        //    http://mplayer.tridentsoftech.com/insert_playlist_songs.php?user_id=5&playlist_name=XYZy&song_id=19
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        
        NSString *url = [NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/favourite.php"];
        NSDictionary *parameter;
        parameter = @{@"user_id":userid,@"song_id":sond_id};
        
        [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
             NSLog(@"url:%@ with paramiter = %@   JSONresponce :== %@",url,parameter,responseObject);
            
            if ([[responseObject objectForKey:@"result"] isEqualToString:@"success"])
            {
                
                alert = [[UIAlertView alloc]initWithTitle:@"Mobile Pandit" message:NSLocalizedString(@"Your Song add to your Favorite list.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
//                [alert show];
            }
            
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(error.code == 3840)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Internal Server Error, Try Again", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            else
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Weak internet connection", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            
            NSLog(@"Error: %@", error);
        }];
        
    }
    
    
}

#pragma mark
#pragma addto download
-(void)addToDownload:(NSString*)sond_id
{
    if([global isConnectedToInternet])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager.requestSerializer setTimeoutInterval:30];
        
        //   http://mplayer.tridentsoftech.com/user_song_download.php?user_id=5&song_id=129
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        
        NSString *url = [NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/user_song_download.php"];
        NSDictionary *parameter;
        parameter = @{@"user_id":userid,@"song_id":sond_id};
        
        [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
             NSLog(@"url:%@ with paramiter = %@   JSONresponce :== %@",url,parameter,responseObject);
            
            if ([[responseObject objectForKey:@"result"] isEqualToString:@"success"])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Mobile Pandit" message:NSLocalizedString(@"Your Song add to your Download list.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                [alert show];
            }
            if ([[responseObject objectForKey:@"result"] isEqualToString:@"Email not exists!"])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Mobile Pandit" message:NSLocalizedString(@"Email not exists Please Sign Up First.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                [alert show];
            }
            
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(error.code == 3840)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Internal Server Error, Try Again", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            else
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Weak internet connection", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            
            NSLog(@"Error: %@", error);
        }];
        
    }
    
    
}

#pragma mark
#pragma delete favorite
-(void)deletefavorite:(NSString*)sond_id
{
    if([global isConnectedToInternet])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager.requestSerializer setTimeoutInterval:30];
        
        //       http://mplayer.tridentsoftech.com/delete_favourite_songs.php?user_id=176&song_id=28
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        
        NSString *url = [NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/delete_favourite_songs.php"];
        NSDictionary *parameter;
        parameter = @{@"user_id":userid,@"song_id":sond_id};
        
        [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
             NSLog(@"url:%@ with paramiter = %@   JSONresponce :== %@",url,parameter,responseObject);
            
            if ([[responseObject objectForKey:@"result"] isEqualToString:@"success"])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Mobile Pandit" message:NSLocalizedString(@"Your Song add to your Download list.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
//                [alert show];
            }
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(error.code == 3840)
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Internal Server Error, Try Again", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            else
            {
                alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Weak internet connection", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
                
                //                [alert show];
            }
            
            NSLog(@"Error: %@", error);
        }];
        
    }
    
    
}

#pragma mark
#pragma mark Actions delegets for popups


- (void)CustomAlertViewController:(CustomAlertView*)viewController
                   didChooseValue:(UIButton*)sender
{
    
    if (sender.tag == 0)
    {
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        if (userid)
        {
            NSLog(@" button first call ");
            
            SKProduct *product = [global.productsIAP objectAtIndex:0];
            
            NSLog(@"Buying %@...", product.productIdentifier);
            [[RageIAPHelper sharedInstance] buyProduct:product];

        }
        else{
        
            alert = [[UIAlertView alloc]initWithTitle:@"Mobile Pandit" message:NSLocalizedString(@"Please Sign in first to buy Mobile Pandit PRO", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
            
            [alert show];
            
            UIStoryboard *MainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];

            LoginView *contentVC = [MainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contentVC];
            [[self sideMenuController] changeContentViewController:navigationController closeMenu:YES];

        }
        
     }
    
    if (sender.tag == 1)
    {
        NSLog(@" button second call ");
        
        ShareingPopupView *contentVC = [[ShareingPopupView alloc]init];
        contentVC.delegate = self;
        contentVC.definesPresentationContext = YES;
        contentVC.view.backgroundColor = [UIColor clearColor];
        
        contentVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:contentVC animated:YES completion:nil];
        
        
    }
    
    
}


- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [global.productsIAP enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            alert = [[UIAlertView alloc]initWithTitle:@"Congratulation" message:NSLocalizedString(@"Please Sign in Again for Mobile Pandit PRO", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
            
                            [alert show];
            
             global.ADUnitID = @"ca4735716";
             global.ADUnitIDInterstitial = @"ca4735716";
            
            [self changeUserStatus];
        }
        
    }];
    
}

- (void)ShareingPopupView:(ShareingPopupView*)viewController
           didChooseValue:(UIButton*)sender{
    //    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIStoryboard *MainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    {
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        if (!userid)
        {
            LoginView *contentVC = [MainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contentVC];
            [[self sideMenuController] changeContentViewController:navigationController closeMenu:YES];
        }
        else
        {
            ReferralPageview *contentVC = [MainStoryboard instantiateViewControllerWithIdentifier:@"ReferralPageview"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contentVC];
            [[self sideMenuController] changeContentViewController:navigationController closeMenu:YES];
        }
        
    }
    
}

#pragma mark
#pragma delete favorite
-(void)changeUserStatus
{
    if([global isConnectedToInternet])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager.requestSerializer setTimeoutInterval:30];
        
        //       http://mplayer.tridentsoftech.com/delete_favourite_songs.php?user_id=176&song_id=28
        
        NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        
        NSString *url = [NSString stringWithFormat:@"http://mplayer.tridentsoftech.com/user_pro.php"];
        NSDictionary *parameter;
        parameter = @{@"user_id":userid};
        
        [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"url:%@ with paramiter = %@   JSONresponce :== %@",url,parameter,responseObject);
            
            if ([[responseObject objectForKey:@"result"] isEqualToString:@"success"])
            {
                UIStoryboard *MainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                LoginView *contentVC = [MainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contentVC];
                [[self sideMenuController] changeContentViewController:navigationController closeMenu:YES];
            }
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
        }];
        
    }
    
    
}

#pragma mark
#pragma mark search button action
- (IBAction)btn_search_clicked:(id)sender
{
    UIStoryboard *MainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    detailView *contentVC = [MainStoryboard instantiateViewControllerWithIdentifier:@"detailView"];
    [self.navigationController pushViewController:contentVC animated:YES];
}



@end
