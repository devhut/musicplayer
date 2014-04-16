//  Created by Dan Lopez on 4/14/14.
//  Copyright (c) 2014 DevHut. All rights reserved.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayerViewController : UIViewController <AVAudioPlayerDelegate>

@property (strong, nonatomic) UIButton *playPauseButton;
@property (strong, nonatomic) UIButton *stopButton;
@property (strong, nonatomic) UISlider *volumeSlider;
@property (strong, nonatomic) UISlider *progressSlider;
@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) UILabel *durationLabel;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *sliderTimer;

- (IBAction)playPauseAudio:(id)sender;
- (IBAction)stopAudio:(id)sender;
- (IBAction)adjustVolume:(id)sender;
- (IBAction)progressSliderChanged:(id)sender;

@end
