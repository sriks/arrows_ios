//
//  ARRGameLogic.h
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARRArrowView.h"

@class ARRGameLogic;

/************************************************************************
                        The game events protocol
 ************************************************************************/
 
/*!
 Protocol for game events.
 */
@protocol ARRGameEventsProtocol <NSObject>
@required
/*!
 Called only once after the game is started.
 @param logic The game logic.
 */
- (void)didStartGame:(ARRGameLogic*)logic;

/*!
 Called only once after the game is ended.
 @param logic The game logic
 */
- (void)didEndGame:(ARRGameLogic*)logic;
@end


/************************************************************************
                        The playground control protocol
 ************************************************************************/

/*!
 The protocol used to control the playground viewcontroller
 */
@protocol ARRPlaygroundControlProtocol <NSObject>
@required
/*!
 Called to start an arrow animation.
 @param arrowView The arrow view to animate.
 */
- (void)startAnimatingArrowView:(ARRArrowView*)arrowView;

/*!
 Called to remove arrows. All these arrows should be removed from playground.
 This is usually called when game is paused, resumed, or ended.
 @param arrows The arrows to be removed.
 */
- (void)removeArrows:(NSArray*)arrows;

/*!
 Called to show a flash message.
 @param flashText The flash message text.
 @param isPositive true if the message is positive. Like bonus points.
 */
- (void)showFlash:(NSString*)flashText positive:(BOOL)isPositive;

/*!
 Called after scoring points.
 @param points The scored points
 @param totalPoints Total points scored so far.
 */
- (void)didScorePoints:(int)points withTotalPoints:(int)totalPoints;

/*!
 Called after decreasing life.
 @param remaingLife The remaining life.
 @param remaingLifePercentage The remaining life as percentage.
 */
- (void)didDecreaseLifeWithRemainingLife:(int)remaingLife
                              precentage:(float)remaingLifePercentage;

/*!
 Called after game is ended. The playground should reset itself.
 */
- (void)didEndGame:(int)points;
@end


/************************************************************************
                        The game logic engine
 ************************************************************************/

/*!
 The central game logic engine. This is responsible for accepting joystick input,
 generating arrows, maintaining points and life.
 Should use ARRGameEventsProtocol to observe for game events
 */
@interface ARRGameLogic : NSObject

/*!
 The game events delegate. This is used for games events like start, stop.
 */
@property (weak, nonatomic) id<ARRGameEventsProtocol> gameEventsDelegate;

/*!
 The play ground controller protocol. This is used to communicate with playground.
 */
@property (weak, nonatomic) id<ARRPlaygroundControlProtocol> playground;

/*!
 The current life span.
 */
@property (nonatomic, readonly) int life;

/*!
 The current speed at which arrows should complete the path.
 This decreases as the game progresses. 
 */
@property (nonatomic, readonly) float speed;

/*!
 The current points.
 */
@property (nonatomic, readonly) int points;

/*!
 Boolean value that determines if game is ended.
 */
@property (nonatomic, readonly) BOOL gameOver;

/*!
 The best score so far among all attempted games since the app is installed.
 */
@property (nonatomic, readonly) int bestScore;

/*!
 The preferred way to get game logic instance.
 @return The shared game logic instance.
 */
+ (ARRGameLogic*)sharedInstance;

/*!
 Should be called after playground is prepared.
 This is an intimation to start the game.
 */
- (void)startGame;

/*!
 Should be called to pause the game.
 */
- (void)pauseGame;

/*!
 Should be called to resume the game.
 */
- (void)resumeGame;

/*!
 Should be called after the arrow completes 3/4 path.
 @param arrowView The arrow view which completed 3/4 path.
 */
- (void)didFinishThreeFourthPath:(ARRArrowView*)arrowView;

/*!
 Should be called after the arrow completes full path.
 @param arrowView The arrow view which completed full path.
 */
- (void)didFinishCompletePath:(ARRArrowView*)arrowView;

/*!
 Should be called when user clicks on a joy stick arrow.
 @param arrowType The arrow type clicked. See ARRConstants.
 */
- (void)didClickJoystickWithArrowType:(ArrowType)arrowType;

@end
