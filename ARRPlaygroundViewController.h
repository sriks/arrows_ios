//
//  ARRPlaygroundViewController.h
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARRGameLogic.h"

typedef void(^ARRPreparePlaygroundCompletionBlock)(void);

/*!
 The play ground controller.
 */
@interface ARRPlaygroundViewController : UIViewController <ARRPlaygroundControlProtocol>

/*!
 Should be called to prepare the playground.
 */
- (void)preparePlaygroundWithCompletionBlock:(ARRPreparePlaygroundCompletionBlock)block;

- (void)resumePlaygroundWithCompletionBlock:(ARRPreparePlaygroundCompletionBlock)block;

@property (nonatomic, weak) ARRGameLogic* gameLogic;

@end
