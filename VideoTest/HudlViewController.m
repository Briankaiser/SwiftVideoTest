//
//  HudlViewController.m
//  VideoTest
//
//  Created by Brian Kaiser on 5/1/13.
//  Copyright (c) 2013 Brian Kaiser. All rights reserved.
//

#import "HudlViewController.h"
#import "HudlLeroyVideoViewController.h"


@interface HudlViewController ()

@property(strong,nonatomic) HudlLeroyVideoViewController *videoController;

@end

@implementation HudlViewController
{
    UISlider *_slider;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGRect videoSize = CGRectMake(0, 0, 1024, 700);
    
    _videoController = [[HudlLeroyVideoViewController alloc] initWithFrame: videoSize andDelegate:self];
    
    [self.view addSubview:_videoController.view];
    
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
        [_videoController play];
    });

}


-(void)discoveredDuration:(Float64)duration
{
    NSLog(@"Found duration %f", duration);
    _slider.maximumValue= duration;
    _slider.enabled = YES;
}


- (void)sliderValueChangedFor:(UISlider*)slider
{
    [_videoController swiftScrub:_slider.value withHighAccuracy:YES];
}
-(void)sliderTouchDownFor:(UISlider*)slider
{
    _videoController.swiftSeekingInProgress = YES;
}
-(void)sliderTouchUpFor:(UISlider*)slider
{
    _videoController.swiftSeekingInProgress = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
