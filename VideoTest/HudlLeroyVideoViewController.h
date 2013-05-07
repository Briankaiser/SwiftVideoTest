//
//  HudlLeroyVideoViewController.h
//  VideoTest
//
//  Created by Brian Kaiser on 5/7/13.
//  Copyright (c) 2013 Brian Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudlLeroyVideoViewController : UIViewController

@property (nonatomic) BOOL swiftSeekingInProgress;

-(id)initWithFrame:(CGRect)frame andDelegate:(id)delegate;
-(void)play;
-(void)swiftScrub:(Float64)time withHighAccuracy:(BOOL)highAccuracy;
-(void)seekToTime:(Float64)time withHighAccuracy:(BOOL)highAccuracy;


@end
