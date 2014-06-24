//
//  QYSongsManager.m
//  QYMusicPlayer
//
//  Created by zhangsf on 14-5-18.
//  Copyright (c) 2014年 zhangsf. All rights reserved.
//

#import "QYSongsManager.h"

#import "QYSong.h"

@implementation QYSongsManager

//标准的单例写法
+ (instancetype)sharedQYSongManager
{
    static QYSongsManager *songManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        songManager = [[self alloc] init];
    });
    return songManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.arraySongList = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}
- (QYSong*)songWithIndex:(NSInteger)index
{
    return self.arraySongList[index];
}

//根据路径解析歌曲信息
- (void)parserSongInfoWithPath:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:path];
    NSString *fileName = nil;
    self.songNameList = [NSMutableArray arrayWithCapacity:10];
    while ((fileName = [dirEnumerator nextObject]) != nil) {
        if ([fileName hasSuffix:@"mp3" ]) {
            NSString *songName = [fileName stringByDeletingPathExtension];
            [self.songNameList addObject:songName ];
            QYSong *song = [self parserSongInfoWithName:songName];
            [self.arraySongList addObject:song];
        }
    }
}

- (QYSong*)parserSongInfoWithName:(NSString*)songName
{
    QYSong *song = [[QYSong alloc] init];
    song.name = songName;
    song.type = @"mp3";
    song.dicTimeAndLyric = [self parserSongLyricWithSongName:songName];
    NSLog(@"%@",song);
    return song;
}

- (NSDictionary*)parserSongLyricWithSongName:(NSString*)songName
{
    NSMutableDictionary *timeAndLyric = [NSMutableDictionary dictionaryWithCapacity:2];
//    NSMutableArray *times = [NSMutableArray arrayWithCapacity:10];
//    NSMutableArray *lyrics = [NSMutableArray arrayWithCapacity:10];
    NSString *lyricFileName = [[NSBundle mainBundle] pathForResource:songName ofType:@"lrc"];
    
    NSString *contentStr = [NSString stringWithContentsOfFile:lyricFileName
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    //数组里的每一个元素是歌词文件里的每一行数据
    //格式：[00:00.52]情非得已 - 天籁童声
    //中括号里的表示当前行歌词的时间，时 分 秒
    NSArray *lyricsPerLine = [contentStr componentsSeparatedByString:@"\n"];
    
    for (int i = 0; i < [lyricsPerLine count]; i++)
    {
        //取出每一行数据即：格式为[00:00.52]情非得已 - 天籁童声
        NSString *lycPerLine = [lyricsPerLine objectAtIndex:i];
        //从右中括号将每一行歌词信息分成两部份，第一部分表示时间 第二部份是真正的歌词
        NSArray *arrayLineInfos = [lycPerLine componentsSeparatedByString:@"]"];
        
        //length > 8表示时间格式是正确的
        NSString *firstLycPart = arrayLineInfos[0];
        if ( firstLycPart.length > 8) {
            //取出时间格式的第三个位置的字符，如果格式正确则应该是冒号
            NSString *strColon = [firstLycPart substringWithRange:NSMakeRange(3, 1)];
            //取出时间格式的第六个位置的字符，如果格式正确，则应该是点。
            NSString *strDot = [firstLycPart substringWithRange:NSMakeRange(6, 1)];
            
            //如果取出来的strColor是冒号， strDot是点，则表示时间格式是正确的
            if ([strColon isEqualToString:@":"] && [strDot isEqualToString:@"."])
            {
                NSString *lrcStr = [arrayLineInfos objectAtIndex:1];
                NSString *timeStr = [firstLycPart substringWithRange:NSMakeRange(1, 5)];
                NSArray *minuteAndSecond = [timeStr componentsSeparatedByString:@":"];
//                NSString *time = [NSString stringWithFormat:@"%d",[minuteAndSecond[0] intValue] *60 + [minuteAndSecond[1] intValue]];
                NSNumber *key = [NSNumber numberWithInteger:[minuteAndSecond[0] intValue] *60 + [minuteAndSecond[1] intValue]];
                //把时间 和 歌词 加入词典
                [timeAndLyric setObject:lrcStr forKey:key];
                
            }
        }
    }
    return timeAndLyric;
}
@end
