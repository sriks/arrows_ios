//
//  ARRArrowView.m
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import "ARRArrowView.h"
#import "ARRTheme.h"

const float ARROW_SIZE                      =   50;
@interface ARRArrowView ()
@property (nonatomic, assign) ArrowType arrowType;
@end

@implementation ARRArrowView

+ (instancetype)randomArrow {
    return [[ARRArrowView alloc] initWithArrowType:[ARRArrowView randomArrowType]];
}

- (instancetype)initWithFrame:(CGRect)frame arrowType:(ArrowType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.arrowType = type;
        [self decorate];
    }
    return self;
}

- (instancetype)initWithArrowType:(ArrowType)type {
    CGRect rect = CGRectMake(0, 0, ARROW_SIZE, ARROW_SIZE);
    return [self initWithFrame:rect arrowType:type];
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = [borderColor CGColor];
}

- (UIColor*)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

#pragma mark Private
- (void)decorate {
    self.layer.cornerRadius = 10;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 2;

    if (self.arrowType != ARRArrowTypeNone) {
        UIColor* arrowColor = [ARRTheme colorForArrowType:self.arrowType];
        self.borderColor = arrowColor;
        NSString* imageName = [ARRConstants imageNameForArrowType:self.arrowType];
        UIImage* arrow = [UIImage imageNamed:imageName];
        UIImageView* arrowImageView = [[UIImageView alloc] initWithImage:arrow];
        const float arrowWidth = ARROW_SIZE - 3;
        CGRect arrowRect = CGRectMake(self.center.x, self.center.y, arrowWidth, arrowWidth);
        arrowImageView.frame = arrowRect;
        arrowImageView.center = self.center;
        arrowImageView.image = [arrowImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        arrowImageView.tintColor = arrowColor;
        [self addSubview:arrowImageView];
    }
}

+ (ArrowType)randomArrowType {
    int randomNumber = 1 + rand() % (5-1);
    return (ArrowType)randomNumber;
}

@end
