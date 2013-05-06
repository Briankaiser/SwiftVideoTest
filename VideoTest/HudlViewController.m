//
//  HudlViewController.m
//  VideoTest
//
//  Created by Brian Kaiser on 5/1/13.
//  Copyright (c) 2013 Brian Kaiser. All rights reserved.
//

#import "HudlViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HudlViewController ()

@end

static NSString* MainUrlString = @"http://static.hudl.com/misc/swift-test/main.mp4";
static NSString* SmallUrlString = @"http://static.hudl.com/misc/swift-test/out-2000f-smallsize.mp4";

@implementation HudlViewController
{
    AVPlayer *_mainPlayer;
    AVPlayer *_smallPlayer;
    AVPlayerLayer *_mainLayer;
    AVPlayerLayer *_smallLayer;
    UISlider *_slider;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGRect videoSize = CGRectMake(0, 0, 1024, 700);
    //Add main video player
    NSURL *mainUrl = [NSURL URLWithString:MainUrlString];
    
    _mainPlayer = [AVPlayer playerWithURL:mainUrl];
    [_mainPlayer setActionAtItemEnd:AVPlayerActionAtItemEndPause];

    _mainLayer = [AVPlayerLayer playerLayerWithPlayer:_mainPlayer];
                   
    _mainLayer.frame = videoSize;
    _mainLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [_mainPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [self.view.layer addSublayer:_mainLayer];
    
    
    //Add small video player
    NSURL *smallUrl = [NSURL URLWithString:SmallUrlString];
    
    _smallPlayer = [AVPlayer playerWithURL:smallUrl];
    //_smallPlayer.currentItem.seekingWaitsForVideoCompositionRendering = YES;
    _smallLayer = [AVPlayerLayer playerLayerWithPlayer:_smallPlayer];
    
    _smallLayer.frame = videoSize;
    _smallLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_smallPlayer.currentItem addObserver:self
                     forKeyPath:@"loadedTimeRanges"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:nil];
    
    _smallLayer.hidden = YES;
    [self.view.layer addSublayer:_smallLayer];


    //add slider
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 705, 1024, 45)];
    _slider.minimumValue = 0;
    _slider.enabled = NO;
    [_slider setContinuous:YES];
    
    //attach action so that you can listen for changes in value
    [_slider addTarget:self action:@selector(sliderValueChangedFor:) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(sliderTouchDownFor:) forControlEvents:UIControlEventTouchDown];
    [_slider addTarget:self action:@selector(sliderTouchUpFor:) forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self action:@selector(sliderTouchUpFor:) forControlEvents:UIControlEventTouchUpOutside];
    
    //add the slider to the view
    [self.view addSubview:_slider];
    
    
    //play main movie
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mainPlayer play];
    });

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == _mainPlayer && [keyPath isEqualToString: @"status"])
    {
        NSLog(@"Found duration %f", CMTimeGetSeconds(_mainPlayer.currentItem.duration));
        _slider.maximumValue= CMTimeGetSeconds(_mainPlayer.currentItem.duration);
        _slider.enabled = YES;
    }else if(object == _smallPlayer.currentItem && [keyPath isEqualToString:@"loadedTimeRanges"])
    {
        
        NSLog(@"Small Video Buffering status: %@", _smallPlayer.currentItem.loadedTimeRanges);
    }
}



- (void)sliderValueChangedFor:(UISlider*)slider
{
    //CMTime tolerance = CMTimeMakeWithSeconds(0.5, 1);
    
    
    [_smallPlayer seekToTime:CMTimeMakeWithSeconds(_slider.value, 100)
             toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    //[_mainPlayer seekToTime:CMTimeMakeWithSeconds(_slider.value, 100)];
}
-(void)sliderTouchDownFor:(UISlider*)slider
{
    [_mainPlayer pause];

    _smallLayer.hidden = NO;

}
-(void)sliderTouchUpFor:(UISlider*)slider
{
    [_smallPlayer pause];

    
    [_mainPlayer seekToTime:_smallPlayer.currentTime  toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            _smallLayer.hidden = YES;
            [_mainPlayer play];
                }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
