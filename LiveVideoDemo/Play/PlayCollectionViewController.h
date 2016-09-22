//
//  PlayCollectionViewController.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/20.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunPlayerSDK/AliVcMediaPlayer.h>

@interface PlayCollectionViewController : UICollectionViewController<AliVcAccessKeyProtocol>

@property(nonatomic,retain) NSMutableDictionary *videolists;
@property(nonatomic,retain) NSArray *datasource;

-(NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath;
-(BOOL)isFileExistAtPath:(NSString*)fileFullPath;

@end
