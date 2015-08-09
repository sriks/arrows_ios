//
//  UIButton+ARRAdditions.m
//  Arrows
//
//  Created by totaramudu on 01/08/15.
//  Copyright (c) 2015 Zippr. All rights reserved.
//

#import "UIButton+ARRAdditions.h"

@implementation UIButton (ARRAdditions)

- (void)styleWithRoundedCorners {
    self.layer.cornerRadius = 4;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [self.tintColor CGColor];
    self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
