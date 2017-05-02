//
//  CollectionViewCell.h
//  MPlayer
//
//  Created by Techno Softwares on 28/09/16.
//  Copyright © 2016 Techno Softwares. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *img_song;
@property (strong, nonatomic) IBOutlet UILabel *lbl_songname;

@end
