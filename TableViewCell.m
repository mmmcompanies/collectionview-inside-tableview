//
//  TableViewCell.m
//  MPlayer
//
//  Created by Techno Softwares on 27/09/16.
//  Copyright © 2016 Techno Softwares. All rights reserved.
//

#import "TableViewCell.h"
@implementation AFIndexedCollectionView
@synthesize indexPath;
@end

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

     [self.collection_view registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"] ;
    
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
//    
//    if (IS_IPAD)
//    {
//        layout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 20.0);
//
////        layout.minimumInteritemSpacing = 20;
////        layout.minimumLineSpacing = 20;
//         self.collection_view.collectionViewLayout = layout;
//    }
    
   
    
    [self.collection_view setShowsHorizontalScrollIndicator:NO];
    [self.collection_view setShowsVerticalScrollIndicator:NO];
    // Configure the view for the selected state
}
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.collection_view.dataSource = dataSourceDelegate;
    self.collection_view.delegate = dataSourceDelegate;
    self.collection_view.tag = indexPath.section ;
//    [self.collectionView setContentOffset:self.collectionView.contentOffset animated:NO];
    
    [self.collection_view reloadData];
}


@end
