//
//  QYSond.m
//  QYMusicPlayer
//
//  Created by zhangsf on 14-5-18.
//  Copyright (c) 2014年 zhangsf. All rights reserved.
//

#import "QYSong.h"

@implementation QYSong

- (NSString *)description
{
    return [NSString stringWithFormat:@"Music name is %@,Format:%@,Type:%@,Singer:%@,Lyric:%@", self.name,self.musicFormat,self.type,self.singer,self.dicTimeAndLyric];
}
@end
