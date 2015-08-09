//  Created by Srikanth Sombhatla
//  Copyright (c) 2014 Deviceworks. All rights reserved.
#import <Foundation/Foundation.h>

@class UIFont;
@class UIColor;
// TODO: Use a protocol
@interface DCTheme : NSObject

+ (UIFont*)fontForHeading;
+ (UIFont*)fontForSubheading;
+ (UIFont*)fontForBody;
+ (UIFont*)fontForSecondaryBody;
+ (UIColor*)colorWithName:(NSString*)colorName;
+ (UIColor*)primaryColor;
+ (UIColor*)secondaryColor;
+ (UIColor*)ternaryColor;

@property (strong, readonly, nonatomic) id color;

@end
