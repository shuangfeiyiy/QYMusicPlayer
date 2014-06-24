//
//  QYViewController.h
//  QYMusicPlayer
//
//  Created by zhangsf on 14-5-17.
//  Copyright (c) 2014年 zhangsf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVAudioPlayer;
@interface QYViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) AVAudioPlayer *musicPlayer;
@end
