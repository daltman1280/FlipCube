//
//  FCCubeView.h
//  FlipCube
//
//  Created by daltman on 11/29/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FCDirection.h"

@interface FCFlippingCubeLayer : CALayer
@end

@interface FCFlippingCubeLayerContainer : CALayer

@property	FCFlippingCubeLayer*			faceTop;
@property	FCFlippingCubeLayer*			faceLeft;
@property	FCFlippingCubeLayer*			faceBottom;
@property	FCFlippingCubeLayer*			faceFront;
@property	FCFlippingCubeLayer*			faceBack;
@property	FCFlippingCubeLayer*			faceRight;

@end

@interface FCCubeView : UIView
@property	FCFlippingCubeLayerContainer*	flippingCubeLayerContainer;
@property	float							rotationInRadians;
@property	float							previousRotationInRadians;					// so we know which direction the cube was previously turned
@property	FCDirection						rotationDirection;
@property	BOOL							isAnimating;

- (void)startAnimation;
- (void)disableAnimation;

@end
