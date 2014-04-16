//  Created by Dan Lopez on 4/14/14.
//  Copyright (c) 2014 DevHut. All rights reserved.

#import "AudioPlayerViewController.h"

@interface AudioPlayerViewController ()

@end

@implementation AudioPlayerViewController

- (void)interfaceForView
{
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 160, 200, 200)];
    imageView.image = [UIImage imageNamed:@"transLogo"];
    [self.view addSubview:imageView];
    
    // in order, from top to bottom, left to right
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.playPauseButton addTarget:self action:@selector(playPauseAudio:)
                   forControlEvents:UIControlEventTouchUpInside];
    self.playPauseButton.frame = CGRectMake(40, 65, 55, 50);
    [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    self.playPauseButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.playPauseButton];
    
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.stopButton addTarget:self action:@selector(stopAudio:)
              forControlEvents:UIControlEventTouchUpInside];
    self.stopButton.frame = CGRectMake(230, 65, 50, 50);
    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    self.stopButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.stopButton];
    
    // static volume label
    UILabel *staticLabel;
    staticLabel = [[UILabel alloc]initWithFrame:CGRectMake(139, 110, 42, 20)];
    staticLabel.text = @"Volume";
    staticLabel.font = [UIFont systemFontOfSize:12];
    staticLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:staticLabel];
    
    self.volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(40, 135, 240, 20)];
    [self.volumeSlider addTarget:self action:@selector(adjustVolume:)
                forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.volumeSlider];
    
    
    self.progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(40, 335, 240, 80)];
    [self.progressSlider addTarget:self action:@selector(progressSlider:)
                  forControlEvents:UIControlEventValueChanged];
    [self.progressSlider addTarget:self action:@selector(progressSliderChanged:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.progressSlider];
    
    
    self.currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 390, 42, 20)];
    self.currentTimeLabel.font = [UIFont systemFontOfSize:12];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.currentTimeLabel];
    
    
    self.durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(240, 390, 42, 20)];
    self.durationLabel.font = [UIFont systemFontOfSize:12];
    self.durationLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.durationLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self interfaceForView];
    
    // find the file in the main app bundle
    NSURL *mixURL = [[NSBundle mainBundle]URLForResource:@"DJMix" withExtension:@"mp3"];
    NSLog(@"viewDidLoad mixURL path: %@", mixURL);
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:mixURL error:&error];
    
    if (error) {
        NSLog(@"ERROR: %@", error.localizedDescription);
    } else {
        self.audioPlayer.delegate = self;
        self.volumeSlider.value = 0.1;
        self.audioPlayer.volume = self.volumeSlider.value;
        self.progressSlider.value = 0.0;
        self.durationLabel.text = [self stringFromInterval:self.audioPlayer.duration];
    }
}

// 3600 seconds in an hour
- (NSString *)stringFromInterval:(NSTimeInterval)interval
{
    NSInteger i = (NSInteger)interval;
    
    int second = i % 60;
    int minute = (i / 60) % 60;
    int hour = i / 3600;
    
    if (i <= 3600) {
        return [NSString stringWithFormat:@"%02d:%02d", minute, second];
    }
    
    return [NSString stringWithFormat:@"%d:%02d:%02d", hour, minute, second];
}

- (void)updateSlider
{
    self.progressSlider.value = self.audioPlayer.currentTime;
    self.currentTimeLabel.text = [self stringFromInterval:self.audioPlayer.currentTime];
}

- (IBAction)playPauseAudio:(id)sender
{
    // if the player is playing, update the state for the componets
    if (!self.audioPlayer.playing) {
        
        NSLog(@"IBAction playPauseAudio playing: %@", self.audioPlayer.playing ? @"NO":@"YES");
        self.progressSlider.maximumValue = self.audioPlayer.duration;
        
        self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
        
        [self.progressSlider addTarget:self action:@selector(progressSliderChanged:)
                                  forControlEvents:UIControlEventValueChanged];
        
        [self.audioPlayer play];
        NSLog(@"IBAction playPauseAudio play: %@", [self.audioPlayer play] ? @"NO":@"YES");
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    // if it is not playing
    } else if (self.audioPlayer.playing) {
        
        NSLog(@"IBAction playPauseAudio playing: %@", self.audioPlayer.playing ? @"NO":@"YES");
        [self.audioPlayer pause];
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (IBAction)stopAudio:(id)sender
{
    // stop the player if it's playing (obvi)
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        NSLog(@"IBAction stopAudio isPlaying: %@", self.audioPlayer.isPlaying ? @"NO":@"YES");
    }

    // update components
    self.audioPlayer.currentTime = 0.0;
    [self.sliderTimer invalidate];
    self.progressSlider.value = 0.0;
    
    // if the player is less than or equal to an hours time, else display the hour
    if (self.audioPlayer.duration <= 3600) {
        self.currentTimeLabel.text = [NSString stringWithFormat:@"00:00"];
    } else {
        self.currentTimeLabel.text = [NSString stringWithFormat:@"00:00:00"];
    }
    
    // adjust the size of the current time label and set play button to Play
    [self.currentTimeLabel sizeToFit];
    [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (IBAction)adjustVolume:(id)sender
{
    // set the player volume to the volumeSlider value
    if (self.audioPlayer != nil) {
        self.audioPlayer.volume = self.volumeSlider.value;
    }
}

- (IBAction)progressSlider:(id)sender
{
    [self.audioPlayer stop];
    self.audioPlayer.currentTime = self.progressSlider.value;
    [self.audioPlayer prepareToPlay];
    NSLog(@"IBAction progressSlider prepareToPlay: %@", [self.audioPlayer prepareToPlay] ? @"NO":@"YES");
    [self.audioPlayer play];
    NSLog(@"IBAction progressSlider play: %@", [self.audioPlayer play] ? @"NO":@"YES");
}

- (IBAction)progressSliderChanged:(id)sender
{
    //
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        [self stopAudio:nil];
    }
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    
    NSLog(@"%@", error.localizedDescription);
    
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    
    // Audio Player
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    
    if (flags == AVAudioSessionInterruptionOptionShouldResume && self.audioPlayer != nil) {
        [self.audioPlayer play];
        NSLog(@"EndInterruption play: %@", [self.audioPlayer play] ? @"NO":@"YES");
    }
    
}

@end
