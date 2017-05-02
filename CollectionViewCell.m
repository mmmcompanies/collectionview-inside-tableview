//
//  CollectionViewCell.m
//  MPlayer
//
//  Created by Techno Softwares on 28/09/16.
//  Copyright © 2016 Techno Softwares. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    self.layer.cornerRadius = 5;
//    self.clipsToBounds = true;
    
    self.img_song.layer.borderWidth = 2;
    self.img_song.layer.borderColor = [UIColor colorWithRed:237.0/255.0 green:199.0/255.0 blue:121.0/255.0 alpha:1.0].CGColor;
}

@end
