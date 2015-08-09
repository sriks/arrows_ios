//
//  ARRJoystickViewController.m
//  Arrows
//
//  Created by totaramudu on 11/07/15.
//  Copyright (c) 2015 Zippr. All rights reserved.
//

#import <objc/runtime.h>
#import "ARRJoystickViewController.h"
#import "ARRArrowView.h"
#import "ARRGameLogic.h"
#import "ARRTheme.h"

static char kKeyArrowType;

@interface ARRJoystickViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *topPlaceholder;
@property (weak, nonatomic) IBOutlet UIImageView *rightPlaceholder;
@property (weak, nonatomic) IBOutlet UIImageView *downPlaceholder;
@property (weak, nonatomic) IBOutlet UIImageView *leftPlaceholder;
@end

@implementation ARRJoystickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self prepareControllers];
}

#pragma mark - Private

- (void)prepareControllers {
    [self prepareControl:self.topPlaceholder withType:ARRArrowTypeTop];
    [self prepareControl:self.rightPlaceholder withType:ARRArrowTypeRight];
    [self prepareControl:self.downPlaceholder withType:ARRArrowTypeDown];
    [self prepareControl:self.leftPlaceholder withType:ARRArrowTypeLeft];
}

- (void)prepareControl:(UIImageView*)imageView withType:(ArrowType)type {
    imageView.layer.cornerRadius = 4;
    imageView.image = [UIImage imageNamed:[ARRConstants imageNameForArrowType:type]];
    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.tintColor = [UIColor whiteColor];
    imageView.backgroundColor = [ARRTheme colorForArrowType:type];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onJoystickButtonClicked:)];
    objc_setAssociatedObject(tap, &kKeyArrowType, [NSNumber numberWithInt:type], OBJC_ASSOCIATION_ASSIGN);
    [imageView addGestureRecognizer:tap];
}

- (void)onJoystickButtonClicked:(UIGestureRecognizer*)gesture {
    NSNumber* type = (NSNumber*)objc_getAssociatedObject(gesture, &kKeyArrowType);
    [self.gameLogic didClickJoystickWithArrowType:[type intValue]];
}

@end
