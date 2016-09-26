//
//  PlayCollectionViewController.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/20.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "PlayCollectionViewController.h"
#import "PlayAnchorModel.h"
#import "PlayCollectionViewCell.h"
#import "PlayDetailViewController.h"

#import "AliVcMoiveViewController.h"
//#import "VideoListViewController.h"

@interface PlayCollectionViewController ()


@property (strong, nonatomic) NSMutableArray *source;

@end

@implementation PlayCollectionViewController
@synthesize videolists,datasource;
static NSString * const reuseIdentifier = @"PlayCollectionViewCell";


- (NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:10];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *filename in tmplist) {
        NSString *fullpath = [dirPath stringByAppendingPathComponent:filename];
        if ([self isFileExistAtPath:fullpath]) {
            if ([[filename pathExtension] isEqualToString:type]) {
                [filenamelist  addObject:filename];
            }
        }
    }
    
    return filenamelist;
}

- (BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

- (void)loadLocalVideo
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [pathArray objectAtIndex:0];
    
    NSMutableArray* video_extension = [[NSMutableArray alloc] init];
    [video_extension addObject:@"mp4"];
    [video_extension addObject:@"mkv"];
    [video_extension addObject:@"rmvb"];
    [video_extension addObject:@"rm"];
    [video_extension addObject:@"avs"];
    [video_extension addObject:@"mpg"];
    [video_extension addObject:@"3g2"];
    [video_extension addObject:@"asf"];
    [video_extension addObject:@"mov"];
    [video_extension addObject:@"avi"];
    [video_extension addObject:@"wmv"];
    [video_extension addObject:@"flv"];
    [video_extension addObject:@"m4v"];
    [video_extension addObject:@"swf"];
    [video_extension addObject:@"webm"];
    [video_extension addObject:@"3gp"];
    
    for(NSString* ext in video_extension) {
        
        NSArray *filename = [self getFilenamelistOfType:ext
                                            fromDirPath:docDir];
        
        for (NSString* name in filename) {
            
            NSMutableString* fullname = [NSMutableString stringWithString:docDir];
            [fullname appendString:@"/"];
            [fullname appendString:name];
            
            [videolists setObject:fullname forKey:name];
        }
    }
    
    //    datasource = [videolists allKeys];
}

- (void)loadRemoteVideo
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [pathArray objectAtIndex:0];
    NSString *videolistPath = [docDir stringByAppendingFormat:@"/videolist.txt"];
    FILE *file = fopen([videolistPath UTF8String], "rb");
    if(file == NULL)
        return;
    
    char VideoPath[200] = {0};
    fgets(VideoPath, 200, file);
    
    do{
        VideoPath[strlen(VideoPath)] = '\0';
        NSString *srcFile = [NSString stringWithUTF8String:VideoPath];
        
        NSRange range1 = [srcFile rangeOfString:@"["];
        NSRange range2 = [srcFile rangeOfString:@"]"];
        if(range1.location == NSNotFound || range2.location == NSNotFound)
            continue;
        NSRange rangeName;
        rangeName.location = range1.location+1;
        rangeName.length = range2.location-range1.location-1;
        NSString* filename = [srcFile substringWithRange:rangeName];
        
        NSRange range;
        range = [srcFile rangeOfString:@"http:"];
        if(range.location == NSNotFound){ //m3u8
            range = [srcFile rangeOfString:@"rtmp:"];
            if(range.location == NSNotFound){ //rtmp
                continue;
            }
        }
        
        NSString* m3u8file = [srcFile substringFromIndex:range.location];
        NSRange rangeEnd = [srcFile rangeOfString:@"\n"];
        if(rangeEnd.location != NSNotFound) {
            rangeEnd.location = 0;
            rangeEnd.length = m3u8file.length-1;
            m3u8file = [m3u8file substringWithRange:rangeEnd];
        }
        rangeEnd = [srcFile rangeOfString:@"\r"];
        if(rangeEnd.location != NSNotFound) {
            rangeEnd.location = 0;
            rangeEnd.length = m3u8file.length-1;
            m3u8file = [m3u8file substringWithRange:rangeEnd];
        }
        
        [videolists setObject:m3u8file forKey:filename];
        
        
    }while (fgets(VideoPath, 200, file));
    
    fclose(file);
}
//
NSString* accessKeyID = @"QxJIheGFRL926hFX";
NSString* accessKeySecret = @"hipHJKpt0TdznQG2J4D0EVSavRH7mR";

-(AliVcAccesskey*)getAccessKeyIDSecret
{
    AliVcAccesskey* accessKey = [[AliVcAccesskey alloc] init];
    accessKey.accessKeyId = accessKeyID;
    accessKey.accessKeySecret = accessKeySecret;
    return accessKey;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    
    
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    if (self.source.count) {
        [self.collectionView reloadData];
    }
    
    
    videolists = [[NSMutableDictionary alloc]init];
    [self loadRemoteVideo];
    [self loadLocalVideo];
    
    [AliVcMediaPlayer setAccessKeyDelegate:self];
}

- (NSMutableArray *)source {
    if (!_source) {
        _source = [NSMutableArray array];
        for (NSInteger i = 0; i != 10; i ++) {
            PlayAnchorModel *anchorModel = [[PlayAnchorModel alloc] init];
            anchorModel.anchorName = [NSString stringWithFormat:@"面朝大海，春暖花开%ld",i];
            anchorModel.anchorIcon = [NSString stringWithFormat:@"icon%ld",i % 4];
            anchorModel.anchorAddress = @"长春市南三环与幸福街交汇";
            anchorModel.anchorViewNum = [NSString stringWithFormat:@"%ld",19665 - i * 76];
            anchorModel.abchorID = [NSString stringWithFormat:@"%ld",i];
            
            [_source addObject:anchorModel];
        }
    }
    return _source;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.source.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    PlayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PlayAnchorModel *anchorModel = [self.source objectAtIndex:indexPath.row];
    [cell setAnchorModel:anchorModel];
    
    return cell;
}

#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    return (CGSize){size.width,size.height - 64 - 49};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.f;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeZero;
    } else {
        return (CGSize){0,0};
    }
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    return (CGSize){kScreenWidth,22};
//}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PlayDetailViewController" bundle:nil];
//    PlayDetailViewController *playDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"PlayDetailViewController"];
//    [self.navigationController pushViewController:playDetailVC animated:YES];
    
    
    TBMoiveViewController* currentView = [[TBMoiveViewController alloc] init];
    [currentView SetMoiveSource:[NSURL URLWithString:@"rtmp://live.lovcreate.com/app-name/video-name"]];
    [self presentViewController:currentView animated:YES completion:nil ];
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


@end
