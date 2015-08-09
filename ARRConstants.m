//
//  ARRConstants.m
//  Arrows
//
//  Created by totaramudu on 11/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import "ARRConstants.h"

NSDictionary* sImageMapping;

NSString* const kARRTop                 =       @"top";
NSString* const kARRRight               =       @"right";
NSString* const kARRDown                =       @"down";
NSString* const kARRLeft                =       @"left";

NSString* const kARRNSUserDefaultsKeyBestScore  =   @"com.deviceworks.arrows.bestscore";

@implementation ARRConstants

+ (void)initialize {
    sImageMapping = @{@(ARRArrowTypeTop)      : kARRTop,
                      @(ARRArrowTypeRight)    : kARRRight,
                      @(ARRArrowTypeDown)     : kARRDown,
                      @(ARRArrowTypeLeft)     : kARRLeft};
}

+ (NSString*)imageNameForArrowType:(ArrowType)type {
    NSString* imageName = sImageMapping[@(type)];
    return [NSString stringWithString:imageName];
}

@end
