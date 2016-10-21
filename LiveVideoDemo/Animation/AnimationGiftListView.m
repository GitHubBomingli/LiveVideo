//
//  AnimationGiftListView.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/26.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "AnimationGiftListView.h"
#import "GiftCollectionViewCell.h"

@implementation AnimationGiftListView
{
    NSInteger _selectedIndex;
    
    NSInteger preSelectedIndex;
    
    NSMutableArray *dataSource;
    NSMutableArray *dataSourceLian;
    
    CGFloat cellWidth;
    CGFloat cellHeight;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//    NSArray *gifts = @[@"giftFlower",@"giftFlower",@"plane-flower-1",@"plane-flower-2",
//                       @"plane-flower-3",@"plane-flower-4",@"plane-flower-5",@"plane-flower-6",
//                       @"car1",@"car2",@"car3",@"car4",
//                       @"car5",@"giftFireworks",@"heartFlower",@"Ship",
//                       @"giftMeteor",@"rocket",@"plane-head",@"",
//                       @"",@"",@"",@""
//                       ];
- (instancetype)initWithHeight:(CGFloat)height
{
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:@"AnimationGiftListView" owner:self options:nil].lastObject;
        self.height = height;
        self.height = kScreenWidth / 2.f * 1.25 + 30;
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.height, [UIScreen mainScreen].bounds.size.width, self.height);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        preSelectedIndex = -1;
        _selectedIndex = -1;
        cellWidth = kScreenWidth / 4.f;
        cellHeight = cellWidth * 1.25;
        [self collectionSet];
        
        [self loadData];
        
        [self hide];
    }
    return self;
}

- (void)loadData {
    dataSource = [NSMutableArray array];
    [dataSource addObjectsFromArray:@[@"giftFlower",@"giftFlower",
                                      @"car5",@"giftFireworks",
                                      @"heartFlower",@"bomber",
                                      @"giftMeteor",@"rocket",
                                      @"plane-head",@"",
                                      @"",@"",
                                      @"",@"",
                                      @"",@"",
                                      ]];
    NSInteger pages = 1;
    if (dataSource.count % 8 != 0) {
        pages = dataSource.count / 8 + 1;
    } else {
        pages = dataSource.count / 8;
    }
    self.pageC.numberOfPages = pages;
    
    dataSourceLian = [NSMutableArray array];
    [dataSourceLian addObjectsFromArray:@[@1,@1,
                                          @1,@0,
                                          @0,@1,
                                          @0,@0,
                                          @1,@0,
                                          @0,@0,
                                          @0,@0,
                                          @0,@0,
                                          ]];
    
    [self.collectionView reloadData];
}

- (void)collectionSet {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [_collectionView registerNib:[UINib nibWithNibName:@"GiftCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GiftCollectionViewCell"];
}

#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataSource.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GiftCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"GiftCollectionViewCell" forIndexPath:indexPath];
    
    cell.giftImageView.image = [UIImage imageNamed:dataSource[indexPath.row]];
    NSNumber *lian = dataSourceLian[indexPath.row];
    if ([lian intValue]) {
        cell.lianLabel.text = @"连";
    } else {
        cell.lianLabel.text = @"";
    }
    if (_selectedIndex == indexPath.row) {
        cell.backgroundColor = [UIColor greenColor];
    } else {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){cellWidth,cellHeight};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}
#pragma mark ---- UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了%@",indexPath);
    if (preSelectedIndex >= 0) {
        GiftCollectionViewCell *cell = (GiftCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:preSelectedIndex inSection:0]];
        cell.backgroundColor = [UIColor clearColor];
    }
    _selectedIndex = indexPath.row;
    preSelectedIndex = _selectedIndex;
    GiftCollectionViewCell *cell = (GiftCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
}


- (IBAction)touchSendBtn:(UIButton *)sender {
    if (_selectedIndex >= 0) {
        
        if (_sendCallback) {
            _sendCallback(_selectedIndex);
        }
        
        NSNumber *lian = dataSourceLian[_selectedIndex];
        if ([lian intValue]) {
        } else {
            [self hide];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    
    self.pageC.currentPage = page;
}

- (void)show {
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.height, [UIScreen mainScreen].bounds.size.width, self.height);
        self.hidden = NO;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, self.height);
        self.hidden = YES;
    }];
}


@end
