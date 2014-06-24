//
//  QYSond.h
//  QYMusicPlayer
//
//  Created by zhangsf on 14-5-18.
//  Copyright (c) 2014年 zhangsf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYSong : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *musicFormat;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *singer;
//使用字典存在一些问题， 因为字典是基于hash， 所以歌词的顺序可能会存在问题
@property (nonatomic, strong) NSDictionary *dicTimeAndLyric;
//暂时未用， 由效率考虑， 可以使用。
//@property (nonatomic, strong) NSMutableArray *songTimes;
//@property (nonatomic, strong) NSMutableArray *songLyrics;
@end
