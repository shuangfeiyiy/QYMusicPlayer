//
//  QYSongsManager.h
//  QYMusicPlayer
//
//  Created by zhangsf on 14-5-18.
//  Copyright (c) 2014年 zhangsf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QYSong;

@interface QYSongsManager : NSObject

@property (nonatomic, strong) NSMutableArray *arraySongList;
@property (nonatomic, strong) NSMutableArray *songNameList;

+ (instancetype)sharedQYSongManager;

- (QYSong*)songWithIndex:(NSInteger)index;

//根据路径解析歌曲信息
- (void)parserSongInfoWithPath:(NSString*)path;
- (QYSong*)parserSongInfoWithName:(NSString*)songName;
@end
