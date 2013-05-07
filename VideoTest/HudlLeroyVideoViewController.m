//
//  HudlLeroyVideoViewController.m
//  VideoTest
//
//  Created by Brian Kaiser on 5/7/13.
//  Copyright (c) 2013 Brian Kaiser. All rights reserved.
//

#import "HudlLeroyVideoViewController.h"
#import "HudlVideoPlayerDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface HudlLeroyVideoViewController ()

@property (weak,nonatomic) id<HudlVideoPlayerDelegate> delegate;
@end

static NSString* MainUrlString = @"http://static.hudl.com/misc/swift-test/main.mp4";
static NSString* SmallUrlString = @"http://static.hudl.com/misc/swift-test/out-2000f-smallsize.mp4";
void* AvPlayerStatusContext = &AvPlayerStatusContext;
void* AvPlayerLoadedTimeRangesContext = &AvPlayerLoadedTimeRangesContext;

@implementation HudlLeroyVideoViewController
{
    AVPlayer *_mainPlayer;
    AVPlayer *_smallPlayer;
    AVPlayerLayer *_mainLayer;
    AVPlayerLayer *_smallLayer;
}

-(void)setSwiftSeekingInProgress:(BOOL)swiftSeekingInProgress
{
    if(swiftSeekingInProgress)
    {
        [_mainPlayer pause];
        _smallLayer.hidden = NO;
        
    }else
    {
        [_smallPlayer pause];
        
        [_mainPlayer seekToTime:_smallPlayer.currentTime  toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            _smallLayer.hidden = YES;
            [_mainPlayer play];
        }];
    }

    _swiftSeekingInProgress = swiftSeekingInProgress;
}

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate
{
    self = [super init];
    
    self.view.frame = frame;
    _delegate = delegate;
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Add main video player
    NSURL *mainUrl = [NSURL URLWithString:MainUrlString];
    
    _mainPlayer = [AVPlayer playerWithURL:mainUrl];
    [_mainPlayer setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    
    _mainLayer = [AVPlayerLayer playerLayerWithPlayer:_mainPlayer];
    
    _mainLayer.frame = self.view.frame;
    _mainLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [_mainPlayer addObserver:self forKeyPath:@"status" options:0 context:AvPlayerStatusContext];
    
    [self.view.layer addSublayer:_mainLayer];
    
    
    //Add small video player
    NSURL *smallUrl = [NSURL URLWithString:SmallUrlString];
    
    _smallPlayer = [AVPlayer playerWithURL:smallUrl];
    //_smallPlayer.currentItem.seekingWaitsForVideoCompositionRendering = YES;
    _smallLayer = [AVPlayerLayer playerLayerWithPlayer:_smallPlayer];
    
    _smallLayer.frame = self.view.frame;
    _smallLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_smallPlayer.currentItem addObserver:self
                               forKeyPath:@"loadedTimeRanges"
                                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                  context:AvPlayerLoadedTimeRangesContext];
    
    _smallLayer.hidden = YES;
    [self.view.layer addSublayer:_smallLayer];
    

}

-(void)play
{
    [_mainPlayer play];
}

-(void)swiftScrub:(Float64)time withHighAccuracy:(BOOL)highAccuracy
{
    CMTimeScale timescale = _smallPlayer.currentTime.timescale;
    
    CMTime tolerance = highAccuracy? kCMTimeZero: CMTimeMakeWithSeconds(0.5, timescale);

    [_smallPlayer seekToTime:CMTimeMakeWithSeconds(time, timescale )
                 toleranceBefore:tolerance toleranceAfter:tolerance];

}

-(void)seekToTime:(Float64)time withHighAccuracy:(BOOL)highAccuracy
{
    CMTimeScale timescale = _smallPlayer.currentTime.timescale;
    
    CMTime tolerance = highAccuracy? kCMTimeZero: CMTimeMakeWithSeconds(0.5, timescale);
    
    [_mainPlayer seekToTime:CMTimeMakeWithSeconds(time, timescale )
            toleranceBefore:tolerance toleranceAfter:tolerance];
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == _mainPlayer && context == AvPlayerStatusContext)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(discoveredDuration:)])
        {
            [_delegate discoveredDuration:CMTimeGetSeconds(_mainPlayer.currentItem.duration) ];
        }
    }else if(object == _smallPlayer.currentItem && context == AvPlayerLoadedTimeRangesContext)
    {
        
        NSLog(@"Small Video Buffering status: %@", _smallPlayer.currentItem.loadedTimeRanges);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
