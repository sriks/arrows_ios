//
//  ARRUtils.m
//  Arrows
//
//  Created by totaramudu on 01/08/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import "ARRUtils.h"

@implementation ARRUtils

+ (float)percentageOfPercent:(float)percent inTotal:(float)total {
    return (total * percent)/100;
}

+ (float)percentageOfValue:(float)value inTotal:(float)total {
    return (value*100)/total;
}

@end
