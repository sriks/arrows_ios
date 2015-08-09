//
//  ARRTheme.m
//  Arrows
//
//  Created by totaramudu on 11/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import "ARRTheme.h"


@implementation ARRTheme

+ (UIColor*)colorForArrowType:(ArrowType)type {
    return [super colorWithName:[ARRConstants imageNameForArrowType:type]];
}

+ (UIColor*)originColor {
    return [super colorWithName:@"origin"];
}

+ (UIColor*)topColor {
    return [super colorWithName:kARRTop];
}

+ (UIColor*)rightColor {
    return [super colorWithName:kARRRight];
}

+ (UIColor*)downColor {
    return [super colorWithName:kARRDown];
}

+ (UIColor*)leftColor {
    return [super colorWithName:kARRLeft];
}

+ (UIColor*)lifeGood {
    return [super colorWithName:@"life_good"];
}

+ (UIColor*)lifeOk {
    return [super colorWithName:@"life_ok"];
}

+ (UIColor*)lifeBad {
    return [super colorWithName:@"life_bad"];
}

+ (UIColor*)pointsScoreColor {
    return [super colorWithName:@"point_score"];
}

+ (UIColor*)originatorBorderColor {
    return [super colorWithName:@"origin"];
}

+ (UIColor*)positiveColor {
    return [super colorWithName:@"positive"];
}

+ (UIColor*)negativeColor {
    return [super colorWithName:@"negative"];
}

@end
