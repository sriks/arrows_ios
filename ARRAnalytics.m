//
//  ARRAnalytics.m
//  arrows
//
//  Created by Srikanth Sombhatla on 3/6/16.
//  Copyright © 2016 Deviceworks. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "ARRAnalytics.h"

NSString* const EVENT_PLAY_AGAIN        =   @"play again";

@implementation ARRAnalytics
+ (void)logPlayAgainEvent {
    [Answers logCustomEventWithName:EVENT_PLAY_AGAIN customAttributes:nil];
}

+ (void)logShareEvent {
    [Answers logShareWithMethod:@"From game over page" contentName:nil contentType:nil contentId:nil customAttributes:nil];
}

+ (void)logGameEndWithScore:(int)score bestScore:(int)bestScore {
    int success = (score >= bestScore)?1:0;
    [Answers logLevelEnd:@"Basic" score:[NSNumber numberWithInteger:score]
                 success:[NSNumber numberWithInteger:success]
        customAttributes:nil];
}

@end
