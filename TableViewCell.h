//
//  TableViewCell.h
//  MPlayer
//
//  Created by Techno Softwares on 27/09/16.
//  Copyright © 2016 Techno Softwares. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AFIndexedCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@interface TableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@property (strong, nonatomic) IBOutlet AFIndexedCollectionView *collection_view;
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end
