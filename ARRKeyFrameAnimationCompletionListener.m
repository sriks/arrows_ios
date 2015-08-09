//
//  ARRKeyFrameAnimationCompletionListener.m
//  Arrows
//
//  Created by totaramudu on 10/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <QuartzCore/CoreAnimation.h>
#import "ARRKeyFrameAnimationCompletionListener.h"

@interface ARRKeyFrameAnimationCompletionListener ()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic,weak) id object;
@end

@implementation ARRKeyFrameAnimationCompletionListener

- (instancetype)initWithTarget:(id)target action:(SEL)selector object:(id)object {
    self = [super init];
    if (self) {
        [self setTarget:target];
        [self setAction:selector];
        [self setObject:object];
    }
    return self;
}

/* Called when the animation begins its active duration. */
- (void)animationDidStart:(CAAnimation *)anim {}

/* Called when the animation either completes its active duration or
 * is removed from the object it is attached to (i.e. the layer). 'flag'
 * is true if the animation reached the end of its active duration
 * without being removed. */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.target && self.action) {
        [self.target performSelector:self.action withObject:self.object];
    }
}


@end
