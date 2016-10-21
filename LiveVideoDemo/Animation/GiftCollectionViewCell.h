//
//  GiftCollectionViewCell.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/11.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *giftImageView;

@property (strong, nonatomic) IBOutlet UILabel *lianLabel;

@property (strong, nonatomic) IBOutlet UILabel *zuanLabel;

@property (strong, nonatomic) IBOutlet UILabel *experLabel;
@end
