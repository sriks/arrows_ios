//
//  ARRGameOverViewController.m
//  Arrows
//
//  Created by totaramudu on 22/07/15.
//  Copyright (c) 2015 Zippr. All rights reserved.
//

#import "ARRGameOverViewController.h"
#import "ARRArrowView.h"
#import "UIButton+ARRAdditions.h"

@interface ARRGameOverViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestScoreLabel;
@end

@implementation ARRGameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pointsLabel.text = [NSString stringWithFormat:@"%d", self.points];
    if (self.points < self.bestScore) {
        self.bestScoreLabel.text = [NSString stringWithFormat:@"Your best score is %d", self.bestScore];
    } else {
        self.bestScoreLabel.text = @"This is your best score.";
    }
    
    self.bestScoreLabel.hidden = ((self.points == 0) && (self.bestScore == 0));
    [self.playAgainButton styleWithRoundedCorners];
}

- (void)viewWillAppear:(BOOL)animated {
    [self startArrowAnimation];
}

- (IBAction)onPlayAgainClicked:(id)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^() {
            [self.delegate didSelectPlayagain];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate didSelectPlayagain];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)startArrowAnimation {
    const float viewWidth = CGRectGetWidth(self.view.frame);
    ARRArrowView* arrow1 = [ARRArrowView randomArrow];
    ARRArrowView* arrow2 = [ARRArrowView randomArrow];
    const float arrowWidth = CGRectGetWidth(arrow1.frame);
    CGPoint arrowCenter = self.view.center;
    arrowCenter.y = 70;
    
    arrow1.center = arrowCenter;
    arrow2.center = arrowCenter;
    
    // Place out of sight towards right. 
    CGRect arrowFrame2 = arrow2.frame;
    arrowFrame2.origin.x = viewWidth + (2*arrowWidth);
    arrow2.frame = arrowFrame2;
    
    CGRect arrow2TargetFrame = arrow1.frame;
    CGRect arrow1TargetFrame = arrow1.frame;
    arrow1TargetFrame.origin.x = -2*arrowWidth;
    
    [self.view addSubview:arrow1];
    [self.view addSubview:arrow2];
    
    __weak ARRGameOverViewController* welf = self;
    [UIView animateWithDuration:1.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:0 animations:^{
        arrow1.frame = arrow1TargetFrame;
        arrow2.frame = arrow2TargetFrame;
    } completion:^(BOOL finished) {
        [arrow1 removeFromSuperview];
        [arrow2 removeFromSuperview];
        [welf startArrowAnimation];
    }];
}

@end
