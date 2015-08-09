//
//  ARRPlaygroundViewController.h
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Zippr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARRGameLogic.h"

/*!
 The play ground controller.
 */
@interface ARRPlaygroundViewController : UIViewController <ARRPlaygroundControlProtocol>

/*!
 Should be called to prepare the playground.
 */
- (void)prepareGame;
@property (nonatomic, weak) ARRGameLogic* gameLogic;

@end
