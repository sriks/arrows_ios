//
//  ARRGameLogic.m
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Zippr. All rights reserved.
//

#import "ARRGameLogic.h"
#import "ARRUtils.h"
#import <objc/runtime.h>

const int INCREASE_POINTS_BY                =   10;
const int WINNING_STREAK_ATTEMPTS           =   8;
const int BONUS_POINTS                      =   INCREASE_POINTS_BY * 4;
const int DECREASE_LIFE_BY                  =   20;
const int MAX_CHANCES                       =   4;
const int MAX_LIFE                          =   MAX_CHANCES * DECREASE_LIFE_BY;
const int INCREASE_SPEED_AFTER_POINTS       =   150;
const float SPEED_INCREASE_FACTOR           =   0.01;
const float INITIAL_SPEED                   =   2.1;
const float MAX_SPEED                       =   1.75;

NSString* const kKVOKeyPathSpeed            =   @"speed";
NSString* const kKVOKeyPathLife             =   @"life";
NSString* const kKVOKeyPoints               =   @"points";
NSString* const kKVOKeyPathGameOver         =   @"gameOver";
NSString* const kKVOKeyPathStopGame         =   @"stopGame";
NSString* const kKVOKeyPathDemoMode         =   @"demoMode";

static NSSet* sStateChangeProperties;

@interface ARRGameLogic ()

@property (nonatomic, assign) int life;
@property (nonatomic, assign) int points;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, assign) int bestScore;

#pragma mark - Internal properties.
@property (nonatomic, assign) BOOL stopGame;
@property (nonatomic, weak) ARRArrowView* currentArrow;
@property (nonatomic) NSMutableArray* arrowsInPlayground;
// To hold count continous arrow matches count.
@property (nonatomic, assign) int winningStreakCount;
@property (nonatomic, assign) int pointsBeforeIncreasingSpeed;
@property (nonatomic, assign) BOOL didShowBestScoreFlash;

@end

@implementation ARRGameLogic

+ (void)initialize {
    sStateChangeProperties = [NSSet setWithArray:@[
                                kKVOKeyPathSpeed,
                                kKVOKeyPathLife,
                                kKVOKeyPoints,
                                kKVOKeyPathGameOver,
                                kKVOKeyPathStopGame,
                                kKVOKeyPathDemoMode
                             ]];
}

+ (ARRGameLogic*)sharedInstance {
    static dispatch_once_t token;
    static ARRGameLogic* theLogic = nil;
    dispatch_once(&token, ^{
        theLogic = [ARRGameLogic new];
    });
    return theLogic;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        for (NSString* keyPath in sStateChangeProperties) {
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
        }
        self.arrowsInPlayground = [NSMutableArray array];
        [self prepareLogic];
        [self addObserver:self forKeyPath:kKVOKeyPathDemoMode options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"ARRGameLogic: dealloc");
    for (NSString* keyPath in sStateChangeProperties) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (void)didPreparePlayground {
    [self reset];
    [self sendArrow];
}

- (void)didFinishThreeFourthPath:(ARRArrowView*)arrowView {
    [self sendArrow];
}

- (void)didFinishCompletePath:(ARRArrowView*)arrowView {
    if (arrowView.associatedArrowType == ARRArrowTypeNone) {
        [self arrowMismatched];
    }
    [self.arrowsInPlayground removeObject:arrowView];
}

- (void)didClickJoystickWithArrowType:(ArrowType)arrowType {
    // Associated arrow is used to check if user did provide any input.
    // This is used to check if a point is lost.
    self.currentArrow.associatedArrowType = arrowType;
    if (self.currentArrow.arrowType == arrowType) {
        [self arrowMatched];
    } else {
        [self arrowMismatched];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    // Speed
    if ([keyPath isEqualToString:kKVOKeyPathSpeed] && (self.speed > 0)) {
        // Left blank
    }
    
    // Life
    else if ([keyPath isEqualToString:kKVOKeyPathLife]) {
        float remainingLifePercentage = [ARRUtils percentageOfValue:self.life inTotal:MAX_LIFE];
        [self.playground didDecreaseLifeWithRemainingLife:self.life
                                               precentage:remainingLifePercentage];
    }
    
    // Gameover
    else if ([keyPath isEqualToString:kKVOKeyPathGameOver] && self.gameOver) {
        if (self.bestScore < self.points) {
            self.bestScore = self.points;
            [self updateBestScoreToUserDefaults:self.bestScore];
        }
        self.stopGame = YES;
        [self.playground didEndGame:self.points];
        id gameEventsListener = self.gameEventsDelegate;
        [self.playground showFlash:@"GAME OVER" positive:NO];
        // Send this message after a delay so that the flash is shown to user.
        [gameEventsListener performSelector:@selector(didEndGame:) withObject:self afterDelay:1];
    }
    
    // Stop game
    else if ([keyPath isEqualToString:kKVOKeyPathStopGame] && self.stopGame) {
        [self.playground removeArrows:self.arrowsInPlayground];
        [self.arrowsInPlayground removeAllObjects];
    }
    
    // Demo mode
    else if ([keyPath isEqualToString:kKVOKeyPathDemoMode]) {
        if (!self.demoMode) {
            self.stopGame = YES;
        }
    }
}

#pragma mark - Private

- (void)dumpStateWithMessage:(NSString*)msg {
    NSLog(@"** State changed for %@ **", msg);
    NSLog(@"life: %d/%d", self.life, MAX_LIFE);
    NSLog(@"points: %d", self.points);
    NSLog(@"speed: %f", self.speed);
}

- (void) prepareLogic {
    [self reset];
    [self dumpStateWithMessage:@"prepare logic"];
}

- (void)reset {
    self.bestScore = [[[NSUserDefaults standardUserDefaults]
                       valueForKey:kARRNSUserDefaultsKeyBestScore] intValue];
    self.winningStreakCount = 0;
    self.pointsBeforeIncreasingSpeed = 0;
    self.points = 0;
    self.gameOver = NO;
    self.stopGame = NO;
    self.didShowBestScoreFlash = NO;
    self.speed = INITIAL_SPEED;
    [self.arrowsInPlayground removeAllObjects];
#ifdef TEST_QUICK_GAME_OVER
    self.life = DECREASE_LIFE_BY;
#else
    self.life = MAX_LIFE;
#endif
}

- (void)sendArrow {
    if(self.stopGame) return;
    
    ARRArrowView* arrow = [self arrowView];
    [self.playground startAnimatingArrowView:arrow];
    self.currentArrow = arrow;
    [self.arrowsInPlayground addObject:arrow];
}

- (ARRArrowView*)arrowView {
    ARRArrowView* arrow = [ARRArrowView randomArrow];
    arrow.associatedArrowType = ARRArrowTypeNone;
    return arrow;
}

- (void)arrowMatched {
    self.winningStreakCount++;
    
    if (self.winningStreakCount >= WINNING_STREAK_ATTEMPTS) {
        self.winningStreakCount = 0;
        int increasePointsBy = (BONUS_POINTS + INCREASE_POINTS_BY);
        self.points += increasePointsBy;
        [self.playground didScorePoints:increasePointsBy withTotalPoints:self.points];
        [self.playground showFlash:@"BONUS POINTS" positive:YES];
    } else {
        self.points += INCREASE_POINTS_BY;
        [self.playground didScorePoints:INCREASE_POINTS_BY withTotalPoints:self.points];
    }
    
    // Check if best score
    if ((self.bestScore > 0) &&
        (!self.didShowBestScoreFlash) &&
        (self.points > self.bestScore)) {
        
        self.bestScore = self.points;
        [self updateBestScoreToUserDefaults:self.bestScore];
        [self.playground showFlash:@"BEST SCORE" positive:YES];
        self.didShowBestScoreFlash = YES;
    }
    // Note: Best score is saved when game ends.

    // Increase speed.
    if (((self.points - self.pointsBeforeIncreasingSpeed) >= INCREASE_SPEED_AFTER_POINTS) &&
        (self.speed > MAX_SPEED)) {
        self.speed -= SPEED_INCREASE_FACTOR;
        self.pointsBeforeIncreasingSpeed = self.points;
        [self dumpStateWithMessage:@"increased speed"];
    }
    
    [self dumpStateWithMessage:@"arrow matched"];
}

- (void)arrowMismatched {
    if (self.stopGame) return;
    
    self.winningStreakCount = 0;
    self.life -= DECREASE_LIFE_BY;
    [self dumpStateWithMessage:@"arrow mis-match"];
    
    if (self.life <= 0) {
        self.gameOver = YES;
    } else if (!self.demoMode) {
        if (self.life == DECREASE_LIFE_BY)
            [self.playground showFlash:@"LAST CHANCE" positive:NO];
        else
            [self.playground showFlash:@"WRONG" positive:NO];
    }
}

- (void)updateBestScoreToUserDefaults:(int)bestScore {
    [[NSUserDefaults standardUserDefaults] setValue:@(bestScore)
                                             forKey:kARRNSUserDefaultsKeyBestScore];

}

@end
