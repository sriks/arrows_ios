//
//  ARRGameLogic.m
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <objc/runtime.h>
#import "ARRGameLogic.h"
#import "ARRUtils.h"

#pragma mark - Constants
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

#pragma mark - Game state change KVO
static NSSet* sStateChangeProperties;
NSString* const kKVOKeyPathSpeed            =   @"speed";
NSString* const kKVOKeyPathLife             =   @"life";
NSString* const kKVOKeyPoints               =   @"points";
NSString* const kKVOKeyPathState            =   @"state";

// The complete set of states
typedef enum : NSInteger {
    ARRGameStateInvalid = -1,
    ARRGameStateNotStarted,
    ARRGameStateStarted,
    ARRGameStateResumed,
    ARRGameStatePaused,
    ARRGameStateStopped
} ARRGameState;

@interface ARRGameLogic ()

#pragma mark - Public properties.
@property (nonatomic, assign) int life;
@property (nonatomic, assign) int points;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) int bestScore;

#pragma mark - Internal properties.
@property (nonatomic, assign) ARRGameState state;
@property (nonatomic, weak) ARRArrowView* currentArrow;
@property (nonatomic) NSMutableArray* arrowsInPlayground;
// To hold count continous arrow matches count.
@property (nonatomic, assign) int winningStreakCount;
@property (nonatomic, assign) int pointsBeforeIncreasingSpeed;
@property (nonatomic, assign) BOOL didShowBestScoreFlash;
@end

@implementation ARRGameLogic

#pragma mark - Public

+ (void)initialize {
    sStateChangeProperties = [NSSet setWithArray:@[
                                kKVOKeyPathSpeed,
                                kKVOKeyPathLife,
                                kKVOKeyPoints,
                                kKVOKeyPathState
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

+ (NSKeyValueObservingOptions)preferredKeyValueObservingOptions {
    return NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        for (NSString* keyPath in sStateChangeProperties) {
            [self addObserver:self forKeyPath:keyPath
                      options:[ARRGameLogic preferredKeyValueObservingOptions] context:nil];
        }
        self.arrowsInPlayground = [NSMutableArray array];
        [self prepareLogic];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"ARRGameLogic: dealloc");
    for (NSString* keyPath in sStateChangeProperties) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (BOOL)gameOver {
    return (self.state == ARRGameStateStopped);
}

- (void)startGame {
    [self dumpStateWithMessage:@"startGame"];
    NSAssert1((ARRGameStateStarted != self.state),
              @"Cannot restart game with state %d", (unsigned)self.state);
    [self reset];
    self.state = ARRGameStateStarted;
}

- (void)pauseGame {
    [self dumpStateWithMessage:@"pauseGame"];
    self.state = ARRGameStatePaused;
}

- (void)resumeGame {
    [self dumpStateWithMessage:@"resumeGame"];
    self.state = ARRGameStateResumed;
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
    if (self.state != ARRGameStateStarted)
        return;
    
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
    if ([keyPath isEqualToString:kKVOKeyPathSpeed] && (self.speed > 0)) {}
    
    // Life
    else if ([keyPath isEqualToString:kKVOKeyPathLife]) {
        float remainingLifePercentage = [ARRUtils percentageOfValue:self.life inTotal:MAX_LIFE];
        [self.playground didDecreaseLifeWithRemainingLife:self.life
                                               precentage:remainingLifePercentage];
    }
    
    // Game state
    else if ([keyPath isEqualToString:kKVOKeyPathState]) {
        
        /*
         Game states
         Start:   ARRGameStateNotStarted->ARRGameStateStarted
         Pause:   ARRGameStatePaused->ARRGameStateResumed->ARRGameStateStarted
         End:     ARRGameStateStarted->ARRGameStateStopped
         Restart: ARRGameStateStopped->ARRGameStateStarted
         */
        
        ARRGameState previousState;
        ARRGameState newState = [change[NSKeyValueChangeNewKey] intValue];
        if (change[NSKeyValueChangeOldKey])
            previousState = [change[NSKeyValueChangeOldKey] intValue];
        else
            previousState = ARRGameStateInvalid;
        
        switch (newState) {
            case ARRGameStateNotStarted: {
                break;
            }
                
            case ARRGameStateStarted: {
                if ((previousState == ARRGameStateNotStarted) ||
                    (previousState == ARRGameStateStopped)) {
                    [self.gameEventsDelegate didStartGame:self];
                }
                [self sendArrow];
                break;
            }
                
            case ARRGameStateResumed: {
                self.state = ARRGameStateStarted;
                break;
            }

            case ARRGameStatePaused: {
                [self.playground removeArrows:self.arrowsInPlayground];
                [self.arrowsInPlayground removeAllObjects];
                break;
            }

            case ARRGameStateStopped: {
                // Game over
                if (![change[NSKeyValueChangeOldKey] isEqual:@(ARRGameStatePaused)]) {
                    // When stopped the state transitions from paused to stopped. This cleans up the arrows.
                    // We silence KVO so that the same state change is not observed.
                    self.state = ARRGameStatePaused;
                    [self removeObserver:self forKeyPath:keyPath];
                    self.state = ARRGameStateStopped;
                    [self addObserver:self
                           forKeyPath:keyPath
                              options:[ARRGameLogic preferredKeyValueObservingOptions]
                              context:nil];
                }
                
                if (self.bestScore < self.points) {
                    self.bestScore = self.points;
                    [self updateBestScoreToUserDefaults:self.bestScore];
                }
                id gameEventsListener = self.gameEventsDelegate;
                [self.playground showFlash:@"GAME OVER" positive:NO];
                // Send this message after a delay so that the flash is shown to user.
                [gameEventsListener performSelector:@selector(didEndGame:)
                                         withObject:self
                                         afterDelay:1];
                [self.playground didEndGame:self.points];
                break;
            }

            default: {
                [NSException raise:NSInvalidArgumentException
                            format:@"Unknown game state %lu", (unsigned long)self.state];
                break;
            }
        }
    }
}

#pragma mark - Private

- (void)dumpStateWithMessage:(NSString*)msg {
#ifdef DEBUG
    NSLog(@"** Game snapshot for %@ **", msg);
    NSLog(@"state: %lu", (unsigned long)self.state);
    NSLog(@"life: %d/%d", self.life, MAX_LIFE);
    NSLog(@"points: %d", self.points);
    NSLog(@"speed: %f", self.speed);
    NSLog(@"arrows in playground: %lu",(unsigned long)self.arrowsInPlayground.count);
#endif
}

- (void) prepareLogic {
    [self reset];
    [self dumpStateWithMessage:@"prepare logic"];
}

- (void)reset {
    self.state = ARRGameStateNotStarted;
    self.bestScore = [[[NSUserDefaults standardUserDefaults]
                       valueForKey:kARRNSUserDefaultsKeyBestScore] intValue];
    self.winningStreakCount = 0;
    self.pointsBeforeIncreasingSpeed = 0;
    self.points = 0;
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
    if(self.state != ARRGameStateStarted)
        return;
    
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
        // Note: Best score is saved when game ends.
    }

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
    if (self.state != ARRGameStateStarted)
        return;
    
    self.winningStreakCount = 0;
    self.life -= DECREASE_LIFE_BY;
    [self dumpStateWithMessage:@"arrow mis-match"];
    
    if (self.life <= 0) {
        self.state = ARRGameStateStopped;
    } else {
        if (self.life == DECREASE_LIFE_BY) {
            [self.playground showFlash:@"LAST CHANCE" positive:NO];
        } else {
            [self.playground showFlash:@"WRONG" positive:NO];
        }
    }
}

- (void)updateBestScoreToUserDefaults:(int)bestScore {
    [[NSUserDefaults standardUserDefaults] setValue:@(bestScore)
                                             forKey:kARRNSUserDefaultsKeyBestScore];

}

@end
