//
//  ARRGameViewController.h
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARRGameLogic.h"
#import "ARRGameOverViewController.h"

/*!
 The main game view controller. This hosts playground and joystick. 
 */
@interface ARRGameViewController : UIViewController <ARRGameEventsProtocol,
                                                     ARRGameOverDelegate>

@end
