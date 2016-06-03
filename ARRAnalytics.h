//
//  ARRAnalytics.h
//  arrows
//
//  Created by Srikanth Sombhatla on 3/6/16.
//  Copyright © 2016 Deviceworks. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 The central analytics collection class. 
 Call these methods to send the respective analytics events.
 */
@interface ARRAnalytics : NSObject

+ (void)logPlayAgainEvent;
+ (void)logShareEvent;
+ (void)logGameEndWithScore:(int)score bestScore:(int)bestScore;

@end
