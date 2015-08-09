//
//  ARRKeyFrameAnimationCompletionListener.h
//  Arrows
//
//  Created by totaramudu on 10/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARRKeyFrameAnimationCompletionListener : NSObject
- (instancetype)initWithTarget:(id)target action:(SEL)selector object:(id)object;
@end
