//
//  ARRGameViewController.m
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Zippr. All rights reserved.
//

#import "ARRGameViewController.h"
#import "ARRPlaygroundViewController.h"
#import "ARRJoystickViewController.h"

const int PLAYGROUND_PERCENTAGE         =   70;

@interface ARRGameViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joystickHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playgroundHeightConstraint;
@property (nonatomic, weak) ARRGameLogic* gameLogic;
@property (nonatomic) ARRJoystickViewController* joystickVC;
@property (nonatomic) ARRPlaygroundViewController* playgroundVC;
@end

@implementation ARRGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resizeSubviews];
    [self preparePlaygroundAndStartGame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)resizeSubviews {
    const float hostViewHeight = CGRectGetHeight(self.view.frame);
    float playgroundHeight = (hostViewHeight * PLAYGROUND_PERCENTAGE)/100;
    float joystickHeight = (hostViewHeight - playgroundHeight) - 1;
    self.playgroundHeightConstraint.constant = playgroundHeight;
    self.joystickHeightConstraint.constant = joystickHeight;
    [self.view layoutIfNeeded];
}

- (ARRGameLogic*)gameLogic {
    if (!_gameLogic) {
        self.gameLogic = [ARRGameLogic sharedInstance];
        _gameLogic.gameEventsDelegate = self;
    }
    return _gameLogic;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"playground"]) {
        self.playgroundVC = (ARRPlaygroundViewController*)segue.destinationViewController;
        self.gameLogic.playground = self.playgroundVC;
        self.playgroundVC.gameLogic = self.gameLogic;
    }
    
    else if ([segue.identifier isEqualToString:@"joystick"]) {
        self.joystickVC = (ARRJoystickViewController*)segue.destinationViewController;
        self.joystickVC.gameLogic = self.gameLogic;
    }
    
    else if ([segue.identifier isEqualToString:@"gameover"]) {
        ARRGameOverViewController* gameOverVC = (ARRGameOverViewController*)segue.destinationViewController;
        ARRGameLogic* logic = (ARRGameLogic*)sender;
        gameOverVC.delegate = self;
        gameOverVC.points = logic.points;
        gameOverVC.bestScore = logic.bestScore;
    }
}

#pragma mark - Private

- (void)preparePlaygroundAndStartGame {
    [self.playgroundVC preparePlaygroundWithCompletionBlock:^{
        [self.gameLogic startGame];
    }];
}

#pragma mark - ARRGameEventsProtocol

- (void)didStartGame:(ARRGameLogic *)logic {}

- (void)didEndGame:(ARRGameLogic *)logic {
    [self performSegueWithIdentifier:@"gameover" sender:logic];
}

#pragma mark - ARRGameOverDelegate

- (void)didSelectPlayagain {
    [self preparePlaygroundAndStartGame];
}

@end
