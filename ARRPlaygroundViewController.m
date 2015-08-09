//
//  ARRPlaygroundViewController.m
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Zippr. All rights reserved.
//

#import <objc/runtime.h>
#import "ARRPlaygroundViewController.h"
#import "ARRGameLogic.h"
#import "ARRArrowView.h"
#import "ARRKeyFrameAnimationCompletionListener.h"
#import "ARRTheme.h"
#import "ARRUtils.h"
#import "UIButton+ARRAdditions.h"

#define degreesToRadians(x) ((x) * M_PI / 180.0)
typedef void(^CountdownTimerCompletionBlock)(void);

const float LIFE_LEVEL_HEIGHT                         =       6;
const float FLASH_ANIM_DURATION                       =       1;

@interface ARRPlaygroundViewController ()
@property (weak, nonatomic) IBOutlet UILabel *totalPointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *tutorialLabel;
@property (weak, nonatomic) IBOutlet UILabel *flashLabel;
@property (weak, nonatomic) IBOutlet UILabel *tutorialTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *dismissTutorialButton;

@property (nonatomic) UIView* lifeLevel;
@property (nonatomic) ARRArrowView* originatorView;
@property (nonatomic) UILabel* animatedScoreLabel;
@property (nonatomic) UIBezierPath *firstHalfPath;
@property (nonatomic, assign) CGPoint bottomPoint;

@property (nonatomic, copy) ARRPreparePlaygroundCompletionBlock preparationCompletionBlock;
@property (nonatomic) BOOL isTutorialDismissed;
@property (nonatomic) float playgroundHeight;
@property (nonatomic) float playgroundWidth;
@property (nonatomic) BOOL didSetupViews;
@property (nonatomic) BOOL isAnimatingFlashLabel;
@end

@implementation ARRPlaygroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.dismissTutorialButton styleWithRoundedCorners];
    self.flashLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.didSetupViews) {
        [self setupViews];
    }
}

- (IBAction)onDismissTutorial:(id)sender {
    self.isTutorialDismissed = YES;
    self.tutorialLabel.hidden = YES;
    self.tutorialTitleLabel.hidden = YES;
    ((UIButton*)sender).hidden = YES;
    [self preparePlaygroundWithCompletionBlock:self.preparationCompletionBlock];
}

- (void)preparePlaygroundWithCompletionBlock:(ARRPreparePlaygroundCompletionBlock)block {
    if (!self.isTutorialDismissed) {
        // Completion is called after tutorial is dismissed
        self.preparationCompletionBlock = block;
        return;
    }
    
#ifdef TEST_QUICK_GAME_OVER
    block();
#else
    // Showing a countdown timer.
    [self showCountdownTime:3 withCompletionBlock:^{
        block();
    }];
#endif
}

- (void)setupViews {
    float width = 60;
    
    // Life level
    CGRect lifeLevelFrame = CGRectMake(0, CGRectGetHeight(self.view.frame) - LIFE_LEVEL_HEIGHT, 0, LIFE_LEVEL_HEIGHT);
    self.lifeLevel = [[UIView alloc] initWithFrame:lifeLevelFrame];
    [self.view addSubview:self.lifeLevel];
    
    // Originator view
    // at top center
    CGRect originatorFrame = CGRectMake((CGRectGetWidth(self.view.bounds)/2 - (width/2)),
                                        20, width, width);
    self.originatorView = [[ARRArrowView alloc] initWithFrame:originatorFrame arrowType:ARRArrowTypeNone];
    self.originatorView.backgroundColor = [UIColor whiteColor];
    self.originatorView.borderColor = [ARRTheme originatorBorderColor];
    [self.view addSubview:self.originatorView];
    
    // Animated score/lost label.
    CGRect labelFrame = self.originatorView.frame;
    self.animatedScoreLabel = [[UILabel alloc] initWithFrame:labelFrame];
    self.animatedScoreLabel.center = self.originatorView.center;
    self.animatedScoreLabel.backgroundColor = [UIColor clearColor];
    self.animatedScoreLabel.textColor = [ARRTheme pointsScoreColor];
    self.animatedScoreLabel.textAlignment = NSTextAlignmentCenter;
    self.animatedScoreLabel.alpha = 0;
    [self.view addSubview:self.animatedScoreLabel];
    
    // Create movement path
    const float viewWidth  = CGRectGetWidth(self.view.bounds);
    const float viewHeight = CGRectGetHeight(self.view.bounds);
    
    CGPoint pointAt12OClock = self.originatorView.center;
    CGPoint pointAt6OClock = CGPointMake((CGRectGetWidth(self.view.bounds)/2) - (width/2),
                                      CGRectGetHeight(self.view.bounds) - (width/2));
    CGPoint pointAt9OClock = CGPointMake(-width, CGRectGetHeight(self.view.bounds)/2);
    CGPoint rightControlPoint = CGPointMake(CGRectGetWidth(self.view.bounds) + (width), CGRectGetHeight(self.view.bounds)/2);
    CGPoint pointAt3OClock = CGPointMake(viewWidth + width, viewHeight/2);
    CGPoint pointAt1OClock = CGPointMake(viewWidth-width, (pointAt3OClock.y - CGRectGetHeight(originatorFrame))/2);
    
    // First half path
    self.firstHalfPath = [UIBezierPath bezierPath];
    [self.firstHalfPath moveToPoint:pointAt12OClock];
    self.firstHalfPath = [UIBezierPath bezierPathWithArcCenter:self.view.center radius:(viewWidth/2)-(width/2) startAngle:degreesToRadians(-90) endAngle:degreesToRadians(-89) clockwise:NO];
    
    self.didSetupViews = YES;
}

#pragma mark ARRPlaygroundControlProtocol

- (void)startAnimatingArrowView:(ARRArrowView*)arrowView {
    CGRect newArrowRect = arrowView.frame;
    newArrowRect.origin = self.originatorView.frame.origin;
    arrowView.frame = newArrowRect;
    arrowView.center = self.originatorView.center;
    [self.view insertSubview:arrowView belowSubview:self.originatorView];
    
    CAKeyframeAnimation *firstAnimation = [self animationWithPath:self.firstHalfPath];

    firstAnimation.duration = self.gameLogic.speed;
    firstAnimation.delegate = [[ARRKeyFrameAnimationCompletionListener alloc] initWithTarget:self action:@selector(didFinishAnimation:) object:arrowView];
    [arrowView.layer addAnimation:firstAnimation forKey:nil];
    // Send this message when animation covers 3/4 of the path.
    [self performSelector:@selector(didFinishThreeFourthPath:) withObject:arrowView
               afterDelay:(0.75)*self.gameLogic.speed];
}

- (void)removeArrows:(NSArray*)arrows {
    for (ARRArrowView* arrow in arrows) {
        [arrow removeFromSuperview];
    }
}

- (void)showFlash:(NSString*)flashText positive:(BOOL)isPositive {
    if (self.isAnimatingFlashLabel) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FLASH_ANIM_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showFlash:flashText positive:isPositive];
        });
        return;
    }
    
    self.flashLabel.text = flashText;
    if (isPositive)
        self.flashLabel.textColor = [ARRTheme positiveColor];
    else
        self.flashLabel.textColor = [ARRTheme negativeColor];
    self.flashLabel.transform = CGAffineTransformMakeScale(0.2, 0.2);
    self.flashLabel.hidden = NO;
    self.isAnimatingFlashLabel = YES;
    [UIView animateWithDuration:FLASH_ANIM_DURATION animations:^{
        self.flashLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
        self.flashLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.flashLabel.hidden = YES;
        self.flashLabel.alpha = 1;
        self.isAnimatingFlashLabel = NO;
    }];
}

- (void)didScorePoints:(int)points withTotalPoints:(int)totalPoints {
    self.totalPointsLabel.text = [NSString stringWithFormat:@"%d",totalPoints];
    [self.totalPointsLabel sizeToFit];
    [self animatePointsWon:points];
}

- (void)didDecreaseLifeWithRemainingLife:(int)remaingLife
                              precentage:(float)remaingLifePercentage {
    const float lifeWidth = [ARRUtils percentageOfPercent:remaingLifePercentage
                                                  inTotal:(CGRectGetWidth(self.view.frame))];
    
    //(CGRectGetWidth(self.view.frame) * remaingLifePercentage)/100;
    UIColor* color = [self colorForLifeLevel:remaingLife];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect newFrame = self.lifeLevel.frame;
        newFrame.size.width = lifeWidth;
        self.lifeLevel.frame = newFrame;
        CGPoint newCenter = self.lifeLevel.center;
        newCenter.x = self.view.center.x;
        self.lifeLevel.center = newCenter;
        self.lifeLevel.backgroundColor = color;
    } completion:^(BOOL finished) {}];
}

- (void)didEndGame:(int)points {
    self.totalPointsLabel.text = @"0";
}

#pragma mark Private

- (void)showCountdownTime:(int)countdown
      withCompletionBlock:(CountdownTimerCompletionBlock)block {
    if (countdown < 0) {
        block();
        return;
    }
    
    UILabel* countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    if (countdown > 0)
        countLabel.text = [NSString stringWithFormat:@"%d",countdown];
    else
        countLabel.text = @"GO";
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.center = self.view.center;
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = [ARRTheme colorForArrowType:(countdown+1)];
    countLabel.font = [UIFont boldSystemFontOfSize:55];
    [self.view addSubview:countLabel];
    countLabel.transform = CGAffineTransformMakeScale(0.2, 0.2);
    __weak ARRPlaygroundViewController* welf = self;
    [UIView animateWithDuration:1 delay:0 options:0 animations:^{
        countLabel.transform = CGAffineTransformMakeScale(2, 2);
        countLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [countLabel removeFromSuperview];
        [welf showCountdownTime:(countdown-1) withCompletionBlock:block];
    }];
}

- (CAKeyframeAnimation*)animationWithPath:(UIBezierPath*)path {
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = path.CGPath;
    moveAnim.removedOnCompletion = YES;
    return moveAnim;
}

- (void)didFinishHalfAnimation:(id)object {}

- (void)didFinishThreeFourthPath:(id)object {
    ARRArrowView* arrowView = (ARRArrowView*)object;
    [self.gameLogic didFinishThreeFourthPath:arrowView];
    [UIView animateWithDuration:((0.25)*self.gameLogic.speed) animations:^{
        arrowView.alpha = 0;
    } completion:^(BOOL finished) {}];
}

- (void)didFinishAnimation:(id)object {
    ARRArrowView* arrowView = (ARRArrowView*)object;
    [self.gameLogic didFinishCompletePath:arrowView];
    [arrowView removeFromSuperview];
}

- (void)animatePointsWon:(int)points {
    self.animatedScoreLabel.text = [NSString stringWithFormat:@"+%d",points];
    self.animatedScoreLabel.alpha = 1;
    CGRect newFrame = self.animatedScoreLabel.frame;
    newFrame.origin.y -= 20;
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        self.animatedScoreLabel.alpha = 0;
        self.animatedScoreLabel.frame = newFrame;
    } completion:^(BOOL finished) {
        self.animatedScoreLabel.center = self.originatorView.center;
    }];
    
    const float scaleAnimDuration = 0.25;
    [UIView animateWithDuration:scaleAnimDuration/2
                          delay:0
                        options:0
                     animations:^{
                         self.originatorView.transform = CGAffineTransformMakeScale(1.25, 1.25);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:scaleAnimDuration/2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                             self.originatorView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         } completion:^(BOOL finished) {
                         }];
                     }];
}

- (UIColor*)colorForLifeLevel:(int)level {
    if ((level <= 100) && (level >= 80)) {
        return [ARRTheme lifeGood];
    }
    
    else if ((level < 80) && (level >= 50)) {
        return [ARRTheme lifeOk];
    }
    
    else if ((level < 50)) {
        return [ARRTheme lifeBad];
    }
    
    else {
        return nil;
    }
}

@end
