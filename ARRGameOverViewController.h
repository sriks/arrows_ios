//
//  ARRGameOverViewController.h
//  Arrows
//
//  Created by totaramudu on 22/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ARRGameOverDelegate <NSObject>
@required
- (void)didSelectPlayagain;
@end

@interface ARRGameOverViewController : UIViewController
@property (nonatomic, weak) id<ARRGameOverDelegate> delegate;
@property (nonatomic, assign) int points;
@property (nonatomic, assign) int bestScore;
@end
