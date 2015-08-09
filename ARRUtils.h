//
//  ARRUtils.h
//  Arrows
//
//  Created by totaramudu on 01/08/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARRUtils : NSObject

+ (float)percentageOfPercent:(float)percent inTotal:(float)total;
+ (float)percentageOfValue:(float)value inTotal:(float)total;

@end
