//
//  ARRTheme.h
//  Arrows
//
//  Created by totaramudu on 11/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import "DCTheme.h"

@interface ARRTheme : DCTheme

+ (UIColor*)colorForArrowType:(ArrowType)type;
+ (UIColor*)originColor;
+ (UIColor*)topColor;
+ (UIColor*)rightColor;
+ (UIColor*)downColor;
+ (UIColor*)leftColor;
+ (UIColor*)lifeGood;
+ (UIColor*)lifeOk;
+ (UIColor*)lifeBad;
+ (UIColor*)originatorBorderColor;
+ (UIColor*)pointsScoreColor;
+ (UIColor*)positiveColor;
+ (UIColor*)negativeColor;
@end
