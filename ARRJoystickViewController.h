//
//  ARRJoystickViewController.h
//  Arrows
//
//  Created by totaramudu on 11/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARRGameLogic;

/*!
 The joystick controller.
 */
@interface ARRJoystickViewController : UIViewController
@property (nonatomic, weak) ARRGameLogic* gameLogic;
@end
