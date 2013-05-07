//
//  HudlVideoPlayerDelegate.h
//  VideoTest
//
//  Created by Brian Kaiser on 5/7/13.
//  Copyright (c) 2013 Brian Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HudlVideoPlayerDelegate <NSObject>

-(void)discoveredDuration:(Float64)duration;
@end
