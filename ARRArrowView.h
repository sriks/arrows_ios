//
//  ARRArrowView.h
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 The basic arrow view
 */
@interface ARRArrowView : UIView

/*!
 @return An arrow view with a random arrow.
 */
+ (instancetype)randomArrow;

/*!
 The designated initializer
 */
- (instancetype)initWithFrame:(CGRect)frame arrowType:(ArrowType)type NS_DESIGNATED_INITIALIZER;

/*!
 Initializes an arrow with arrow type. This view will have default size.
 */
- (instancetype)initWithArrowType:(ArrowType)type;

/*!
 @return A random arrow type.
 */
+ (ArrowType)randomArrowType;

/*!
 The arrow type of this arrow view.
 */
@property (nonatomic, readonly) ArrowType arrowType;

/*!
 The border color.
 */
@property (nonatomic) UIColor* borderColor;

/*!
 This is an internal property.
 The associated arrow type used by game logic.
 */
@property (nonatomic) ArrowType associatedArrowType;

@end
