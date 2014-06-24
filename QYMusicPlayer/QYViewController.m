//
//  QYViewController.m
//  QYMusicPlayer
//
//  Created by zhangsf on 14-5-17.
//  Copyright (c) 2014年 zhangsf. All rights reserved.
//

#import "QYViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QYSongsManager.h"
#import "QYSong.h"

@interface QYViewController ()
@property (weak, nonatomic) IBOutlet UISlider *sliderMusicTracker;
@property (weak, nonatomic) IBOutlet UIButton *btnPreMusic;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayMusic;
@property (weak, nonatomic) IBOutlet UIButton *btnNextMusic;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *labelDuration;
@property (weak, nonatomic) IBOutlet UISlider *sliderMusicVolume;
@property (weak, nonatomic) IBOutlet UITableView *songWordTableView;


@property (strong, nonatomic) NSMutableArray *arraySongName;
@property (strong, nonatomic) NSDictionary *dicSongTimeAndLyric;

@property (strong, nonatomic) NSMutableArray *arrayLyric;
@property (strong, nonatomic) NSArray *currentSongTimes;
@property (assign, nonatomic) NSUInteger currentLineNumber;

@property (strong, nonatomic) QYSong *currentSong;

//计时器， 主要用于控制播放歌典的进度
@property (strong, nonatomic) NSTimer *timerForPlayer;

//标识当前播放歌曲在歌曲列表的位置，主要用于下一首，上一首
@property (nonatomic, assign) NSUInteger currentSongIndex;

@end

@implementation QYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化，默认使用第一首歌
    self.currentSongIndex = 0;
    self.currentLineNumber = 0;
    [self.songWordTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"QYMusicCell"];
    
    NSString *path = [[NSBundle mainBundle] resourcePath];
    [[QYSongsManager sharedQYSongManager] parserSongInfoWithPath:path];

    [self resetMusicPlayer];
    
    //初始化音乐进度Slider
    [self.sliderMusicTracker setThumbImage:[UIImage imageNamed:@"sliderThumb_small"] forState:UIControlStateNormal];
    [self.sliderMusicTracker setThumbImage:[UIImage imageNamed:@"sliderThumb_small"] forState:UIControlStateHighlighted];
 
    //实始化声音控制Slider
    [self.sliderMusicVolume setThumbImage:[UIImage imageNamed:@"sliderThumb_small"] forState:UIControlStateNormal];
    [self.sliderMusicVolume setThumbImage:[UIImage imageNamed:@"sliderThumb_small"] forState:UIControlStateHighlighted];
    self.sliderMusicVolume.value = 0.3f;
}
#pragma mark -
#pragma mark UITableView Data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayLyric.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QYMusicCell"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    cell.textLabel.text = self.arrayLyric[indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark Button callback
- (IBAction)onPlayerVolume:(UISlider*)sender
{
    self.musicPlayer.volume = sender.value;
}

- (IBAction)onSliderMusicTracker:(UISlider*)sender
{
    self.musicPlayer.currentTime = sender.value * self.musicPlayer.duration;
    [self.timerForPlayer invalidate];
    self.timerForPlayer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}


- (IBAction)onPreMusic:(id)sender
{
    self.currentLineNumber = 0;
    if ((self.currentSongIndex == 0)) {
        self.currentSongIndex = [QYSongsManager sharedQYSongManager].arraySongList.count-1;
    }else
    {
        self.currentSongIndex--;
    }
    [self resetMusicPlayer];
    [self playCurrentSong];
    [self.songWordTableView reloadData];
    [self updateLyricView];
}

- (IBAction)onNextMusic:(id)sender
{
    self.currentLineNumber = 0;
    self.currentSongIndex++;
    if (self.currentSongIndex > [QYSongsManager sharedQYSongManager].arraySongList.count-1) {
        self.currentSongIndex = 0;
    }
    [self resetMusicPlayer];
    [self playCurrentSong];
    [self.songWordTableView reloadData];
    [self updateLyricView];
}

- (void)resetMusicPlayer
{
    self.currentSong = [[[QYSongsManager sharedQYSongManager] arraySongList] objectAtIndex:self.currentSongIndex];
     self.currentSongTimes = [[self.currentSong.dicTimeAndLyric allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.arrayLyric = [NSMutableArray arrayWithCapacity:20];
   
    for (int i = 0 ; i < self.currentSongTimes.count; i++) {
        NSString *lyric = self.currentSong.dicTimeAndLyric[self.currentSongTimes[i]];
        [self.arrayLyric addObject:lyric];
    }
   
    NSURL *currentMusicURL = [[NSBundle mainBundle] URLForResource:self.currentSong.name withExtension:@"mp3"];
    NSError *error = nil;
    self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:currentMusicURL  error:&error];
    if (error != nil) {
        NSLog(@"INIT music player failure.ERROR:%@",error);
        return;
    }
}

- (IBAction)onPlay:(UIButton*)sender
{
    [self playCurrentSong];
}


- (void)playCurrentSong
{
    if (![self.musicPlayer isPlaying]) {
        [self.musicPlayer play];
        self.timerForPlayer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
        [self.btnPlayMusic setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    } else {
        [self.musicPlayer pause];
        [self.timerForPlayer invalidate];
        [self.btnPlayMusic setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }

}
- (void)onTimer:(NSTimer*)timer
{

    //动态更新进度条时间
    if ((int)self.musicPlayer.currentTime % 60 < 10) {
        self.labelCurrentTime.text = [NSString stringWithFormat:@"%d:0%d",(int)self.musicPlayer.currentTime / 60, (int)self.musicPlayer.currentTime % 60];
    } else {
        self.labelCurrentTime.text = [NSString stringWithFormat:@"%d:%d",(int)self.musicPlayer.currentTime / 60, (int)self.musicPlayer.currentTime % 60];
    }
    //
    if ((int)self.musicPlayer.duration % 60 < 10) {
        self.labelDuration.text = [NSString stringWithFormat:@"%d:0%d",(int)self.musicPlayer.duration / 60, (int)self.musicPlayer.duration % 60];
    } else {
        self.labelDuration.text = [NSString stringWithFormat:@"%d:%d",(int)self.musicPlayer.duration / 60, (int)self.musicPlayer.duration % 60];
    }

    
    NSLog(@"%f,%f",self.musicPlayer.currentTime,self.musicPlayer.duration);
    double result = self.musicPlayer.currentTime / self.musicPlayer.duration;
    NSLog(@"result %f",result);
    [self.sliderMusicTracker setValue:result animated:YES];
    [self updateLyricView];
}

- (void)updateLyricView
{
    //如果是最后一行歌词， 需要处理的办法
    if (self.currentLineNumber >= self.currentSongTimes.count ) {
        self.currentLineNumber= 0;
        [self.timerForPlayer invalidate];
        [self.musicPlayer stop];
    }
    else //如果不是最后一行， 则进行的处理
    {
        double lyricTime = [self.currentSongTimes[self.currentLineNumber] doubleValue];
        NSLog(@"lyricTime is %f,currentTime:%f",lyricTime,self.musicPlayer.currentTime);
        if (self.musicPlayer.currentTime - lyricTime > 0) {
//            浮点数比较，注意事项
            self.currentLineNumber++;
        }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentLineNumber-1 inSection:0];
    [self.songWordTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
