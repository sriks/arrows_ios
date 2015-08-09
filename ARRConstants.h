//
//  ARRConstants.h
//  Arrows
//
//  Created by totaramudu on 11/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ARRArrowTypeNone,
    ARRArrowTypeTop,
    ARRArrowTypeRight,
    ARRArrowTypeDown,
    ARRArrowTypeLeft
} ArrowType;

extern NSString* const kARRTop;
extern NSString* const kARRRight;
extern NSString* const kARRDown;
extern NSString* const kARRLeft;

extern NSString* const kARRNSUserDefaultsKeyBestScore;

@interface ARRConstants : NSObject

+ (NSString*)imageNameForArrowType:(ArrowType)type;

@end